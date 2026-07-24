class CorsConfig {
  CorsConfig._();

  static const List<String> allowedOrigins = [
    'https://mediquick.my.id',
    'http://localhost',
    'http://127.0.0.1',
  ];

  static Map<String, String> get clientCorsHeaders => {
        'Access-Control-Allow-Origin': 'https://mediquick.my.id',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers':
            'Origin, Content-Type, Accept, Authorization, X-Requested-With',
        'Access-Control-Allow-Credentials': 'true',
      };

  static bool isOriginAllowed(String origin) {
    return allowedOrigins.any((allowed) => origin.startsWith(allowed));
  }
}
