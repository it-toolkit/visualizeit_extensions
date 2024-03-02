
import 'package:flutter/foundation.dart';

abstract class LogEventHandler {
  void handle(LogLevel level, String category, String Function() msgBuilder, {Exception? error, StackTrace? stackTrace});
}

class Logging implements LogEventHandler {
  static final Logging _instance = Logging._internal();

  Map<String, Logger> _loggers = {};

  factory Logging() {
    return _instance;
  }

  Logging._internal() {
    // initialization logic
  }

  Logger? _getLogger(String category) => _loggers[category];

  void _registerLogger(Logger logger) {
    if (!_loggers.containsKey(logger.category)) {
      final loggers = Map<String,Logger>.from(_loggers);
      loggers[logger.category] = logger;
      _loggers = loggers;
    }
  }

  @override
  void handle(LogLevel level, String category, String Function() msgBuilder, {Exception? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint("${DateTime.now()} ${level.name.toUpperCase()} [$category] - ${msgBuilder()}");
      if (error != null) {
        debugPrint(" >>>> ${error.toString()}");
      }
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }
}

enum LogLevel {
  error, warn, info, debug, trace;
}

class Logger {
  String category;
  late LogEventHandler _logEventHandler;

  factory Logger(String category) {
    final logging = Logging();
    var logger = logging._getLogger(category);
    if (logger != null) return logger;

    logger = Logger._internal(category);
    logger._logEventHandler = logging;
    logging._registerLogger(logger);
    return logger;
  }

  Logger._internal(this.category);

  void trace(String Function() msgBuilder){
    _logEventHandler.handle(LogLevel.trace, category, msgBuilder);
  }

  void debug(String Function() msgBuilder) {
    _logEventHandler.handle(LogLevel.debug, category, msgBuilder);
  }

  void info(String Function() msgBuilder) {
    _logEventHandler.handle(LogLevel.info, category, msgBuilder);
  }

  void warn(String Function() msgBuilder) {
    _logEventHandler.handle(LogLevel.warn, category, msgBuilder);
  }

  void error(String Function() msgBuilder, {Exception? error, StackTrace? stackTrace}){
    _logEventHandler.handle(LogLevel.error, category, msgBuilder, error: error, stackTrace: stackTrace);
  }
}