import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mediquick/core/network/api_exception.dart';
import 'package:mediquick/core/network/cors_config.dart';
import 'package:mediquick/core/security/secure_storage_service.dart';
import 'package:mediquick/core/utils/logger.dart';

class ApiClient {
  static const Duration _timeoutDuration = Duration(seconds: 15);

  static Future<Map<String, String>> _getHeaders(
      Map<String, String>? customHeaders) async {
    final token = await SecureStorageService.getAuthToken();

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'X-Content-Type-Options': 'nosniff',
      'X-XSS-Protection': '1; mode=block',
      ...CorsConfig.clientCorsHeaders,
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  static Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    final uri = Uri.parse(url);
    AppLogger.debug('HTTP GET: $url');

    try {
      final requestHeaders = await _getHeaders(headers);
      final response =
          await http.get(uri, headers: requestHeaders).timeout(_timeoutDuration);

      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('Koneksi waktu habis. Silakan coba lagi.');
    } catch (e) {
      AppLogger.error('Error on GET $url: $e');
      rethrow;
    }
  }

  static Future<dynamic> post(
    String url, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    AppLogger.debug('HTTP POST: $url');

    try {
      final requestHeaders = await _getHeaders(headers);
      final response = await http
          .post(
            uri,
            headers: requestHeaders,
            body: body is String ? body : json.encode(body),
          )
          .timeout(_timeoutDuration);

      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException('Koneksi waktu habis. Silakan coba lagi.');
    } catch (e) {
      AppLogger.error('Error on POST $url: $e');
      rethrow;
    }
  }

  static dynamic _processResponse(http.Response response) {
    AppLogger.debug('HTTP Response status: ${response.statusCode}');

    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) return null;
        try {
          return json.decode(response.body);
        } catch (_) {
          return response.body;
        }
      case 400:
        throw ApiException('Permintaan tidak valid (400)', 400);
      case 401:
        SecureStorageService.clearSession();
        throw ApiException('Sesi telah berakhir, silakan login kembali', 401);
      case 403:
        throw ApiException('Akses ditolak (403)', 403);
      case 404:
        throw ApiException('Data tidak ditemukan (404)', 404);
      case 500:
      default:
        throw ServerException('Server error (${response.statusCode})');
    }
  }
}
