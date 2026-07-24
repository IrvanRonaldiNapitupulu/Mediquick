// core/utils/logger.dart
import 'package:flutter/foundation.dart';

/// Centralized logging utility for the MediQuick application.
/// Wraps [debugPrint] to ensure logs are only shown in debug mode
/// and provides consistent formatting across the codebase.
class AppLogger {
  AppLogger._(); // Prevent instantiation

  /// Log debug-level messages (only in debug mode).
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('🐛 $prefix$message');
    }
  }

  /// Log info-level messages.
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('ℹ️ $prefix$message');
    }
  }

  /// Log warning-level messages.
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('⚠️ $prefix$message');
    }
  }

  /// Log error-level messages with optional error object and stack trace.
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('❌ $prefix$message');
      if (error != null) {
        debugPrint('   Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('   StackTrace: $stackTrace');
      }
    }
  }
}
