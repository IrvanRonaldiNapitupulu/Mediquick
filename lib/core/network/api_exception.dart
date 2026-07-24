class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException [$statusCode]: $message';
    }
    return 'ApiException: $message';
  }
}

class NetworkException extends ApiException {
  NetworkException([String msg = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.'])
      : super(msg);
}

class ServerException extends ApiException {
  ServerException([String msg = 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.'])
      : super(msg);
}
