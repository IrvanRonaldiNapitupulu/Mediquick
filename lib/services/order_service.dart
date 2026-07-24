// services/order_service.dart

import 'package:mediquick/core/constants/api_constants.dart';
import 'package:mediquick/core/network/api_client.dart';
import 'package:mediquick/core/utils/logger.dart';

/// Service handling checkout order submission and Midtrans payment Snap token generation.
class OrderService {
  /// Sends order details to backend and retrieves Midtrans Snap URL token.
  static Future<Map<String, dynamic>> createOrderAndGetSnap({
    required String userId,
    required int apotekId,
    required String name,
    required String email,
    required String phone,
    required String address,
    String? note,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final payload = {
        'user_id': userId,
        'apotek_profile_id': apotekId,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'note': note ?? '',
        'items': items,
      };

      AppLogger.debug("KIRIM DATA PESANAN: $payload");

      final response = await ApiClient.post(
        ApiConstants.orderSnapToken,
        body: payload,
      );

      if (response is Map<String, dynamic>) {
        return response;
      } else {
        return {
          'success': false,
          'message': 'Format respon server tidak valid.',
        };
      }
    } catch (e) {
      AppLogger.error('Error saat membuat pesanan', error: e);
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat mengirim pesanan: $e',
      };
    }
  }
}
