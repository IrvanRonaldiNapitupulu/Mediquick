import 'package:mediquick/core/security/input_sanitizer.dart';

class InputValidator {
  InputValidator._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    final sanitized = InputSanitizer.sanitize(value);
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );

    if (!emailRegex.hasMatch(sanitized)) {
      return 'Format email tidak valid (contoh: user@domain.com)';
    }

    return null;
  }

  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi';
    }

    if (value.length < minLength) {
      return 'Kata sandi minimal $minLength karakter';
    }

    if (RegExp(r"('|\bOR\b|--|;)", caseSensitive: false).hasMatch(value)) {
      return 'Kata sandi mengandung karakter terlarang';
    }

    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }

    final sanitized = InputSanitizer.sanitize(value);
    if (sanitized.isEmpty) {
      return '$fieldName mengandung karakter tidak valid';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon wajib diisi';
    }

    final clean = value.trim().replaceAll(' ', '').replaceAll('-', '');
    final phoneRegex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,10}$');

    if (!phoneRegex.hasMatch(clean)) {
      return 'Nomor telepon tidak valid';
    }

    return null;
  }
}
