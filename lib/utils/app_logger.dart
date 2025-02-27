import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static Logger? _logger;
  static File? _logFile;

  static Future<void> initializeLogger() async {
    if (kIsWeb) {
      // Web-specific logger initialization
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 5,
          lineLength: 50,
          colors: false,
          printEmojis: true,
          printTime: true,
        ),
      );
    } else {
      // Mobile-specific logger initialization with file output
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final logDirectory = Directory('${directory.path}/logs');
      if (!await logDirectory.exists()) {
        await logDirectory.create();
      }

      final date = DateTime.now().toIso8601String().split('T')[0];
      _logFile = File('${logDirectory.path}/app_log_$date.log');
    }
  }

  static Future<void> _writeToFile(String level, dynamic message,
      [dynamic error, StackTrace? stackTrace]) async {
    if (_logFile == null) await initializeLogger();

    final timestamp = DateTime.now().toIso8601String();
    final logMessage =
        '$timestamp [$level] $message${error != null ? '\nError: $error' : ''}${stackTrace != null ? '\nStack: $stackTrace' : ''}\n';

    await _logFile?.writeAsString(logMessage, mode: FileMode.append);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.e(message, error: error, stackTrace: stackTrace);
    if (!kIsWeb) {
      _writeToFile('ERROR', message, error, stackTrace);
    }
  }

  static void info(String message) {
    _logger?.i(message);
    if (!kIsWeb) {
      _writeToFile('INFO', message);
    }
  }

  static void warning(String message) {
    _logger?.w(message);
    if (!kIsWeb) {
      _writeToFile('WARNING', message);
    }
  }

  static void debug(String message) {
    _logger?.d(message);
    if (!kIsWeb) {
      _writeToFile('DEBUG', message);
    }
  }

  static void success(String message) {
    _logger?.i('✅ $message');
    if (!kIsWeb) {
      _writeToFile('SUCCESS', '✅ $message');
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
