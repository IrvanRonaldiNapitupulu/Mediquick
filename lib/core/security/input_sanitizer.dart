class InputSanitizer {
  InputSanitizer._();

  static String sanitize(String input) {
    if (input.isEmpty) return input;

    String clean = input.trim();
    clean = clean.replaceAll(RegExp(r'<script[^>]*>([\s\S]*?)<\/script>', caseSensitive: false), '');
    clean = clean.replaceAll(RegExp(r'<[^>]*>', caseSensitive: false), '');
    clean = clean.replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '');
    clean = clean.replaceAll(RegExp(r"('\s*OR\s*'1'\s*=\s*'1)", caseSensitive: false), '');
    clean = clean.replaceAll(RegExp(r"(--|;|/\*|\*/)", caseSensitive: false), '');

    return clean;
  }

  static String escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }
}
