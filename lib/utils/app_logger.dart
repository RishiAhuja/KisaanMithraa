import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  static File? _logFile;

  static Future<void> initializeLogger() async {
    final directory = await getApplicationDocumentsDirectory();
    final logDirectory = Directory('${directory.path}/logs');
    if (!await logDirectory.exists()) {
      await logDirectory.create();
    }

    final date = DateTime.now().toIso8601String().split('T')[0];
    _logFile = File('${logDirectory.path}/app_log_$date.log');
  }

  static Future<void> _writeToFile(String level, dynamic message,
      [dynamic error, StackTrace? stackTrace]) async {
    if (_logFile == null) await initializeLogger();

    final timestamp = DateTime.now().toIso8601String();
    final logMessage =
        '$timestamp [$level] $message${error != null ? '\nError: $error' : ''}${stackTrace != null ? '\nStack: $stackTrace' : ''}\n';

    await _logFile?.writeAsString(logMessage, mode: FileMode.append);
  }

  static Future<void> error(dynamic message,
      [dynamic error, StackTrace? stackTrace]) async {
    if (kDebugMode) {
      _logger.e(message, error: error, stackTrace: stackTrace);
      await _writeToFile('ERROR', message, error, stackTrace);
    }
  }

  static Future<void> info(dynamic message) async {
    if (kDebugMode) {
      _logger.i(message);
      await _writeToFile('INFO', message);
    }
  }

  static Future<void> warning(dynamic message) async {
    if (kDebugMode) {
      _logger.w(message);
      await _writeToFile('WARNING', message);
    }
  }

  static Future<void> debug(dynamic message) async {
    if (kDebugMode) {
      _logger.d(message);
      await _writeToFile('DEBUG', message);
    }
  }

  static Future<void> success(dynamic message) async {
    if (kDebugMode) {
      _logger.i('✅ $message');
      await _writeToFile('SUCCESS', '✅ $message');
    }
  }

  static Future<String?> getLogFilePath() async {
    return _logFile?.path;
  }

  static Future<String> getLogs() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return 'No logs available';
    }
    return await _logFile!.readAsString();
  }
}
