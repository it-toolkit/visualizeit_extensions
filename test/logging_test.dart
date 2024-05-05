import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visualizeit_extensions/logging.dart';

void main() {
  final logging = Logging();
  late LogAppender currentAppender;
  late StackTraceAppender currentStackTraceAppender;

  setUp(() {
     currentAppender = logging.appender;
     currentStackTraceAppender = logging.stackTraceAppender;
  });

  tearDown(() {
    logging.appender = currentAppender;
    logging.stackTraceAppender = currentStackTraceAppender;
  });

  test('log synchronously if debug mode', () {
    if (kDebugMode) {
      expect(logging.appender, equals(debugPrintSynchronously));
    } else {
      expect(logging.appender, equals(debugPrintThrottled));
    }
  });

  test('each log calls the proper appenders', () {
    final logger = Logger("fake-category");
    List<String> appenderCalls = [];
    List<StackTrace> stackTraceAppenderCalls = [];
    logging.appender = (String message, {int? wrapWidth}) { appenderCalls.add(message); };
    logging.stackTraceAppender = (stackTrace) { stackTraceAppenderCalls.add(stackTrace); };

    logger.trace(() => "trace message");
    logger.debug(() => "debug message");
    logger.info(() => "info message");
    logger.warn(() => "warn message");
    var currentStackTrace = StackTrace.current;
    logger.error(() => "error message", error: Exception("MyError"), stackTrace: currentStackTrace);

    expect(appenderCalls, hasLength(6));
    for (var message in (appenderCalls.sublist(0, 5))) {
      expect(message, contains("fake-category"));
    }

    expect(appenderCalls[0], contains("trace message"));
    expect(appenderCalls[1], contains("debug message"));
    expect(appenderCalls[2], contains("info message"));
    expect(appenderCalls[3], contains("warn message"));
    expect(appenderCalls[4], contains("error message"));
    expect(appenderCalls[5], contains("MyError"));

    expect(stackTraceAppenderCalls, hasLength(1));
    expect(stackTraceAppenderCalls[0], equals(currentStackTrace));
  });

  test('each log calls the proper appender if log level is enabled', () {
    final logger = Logger("fake-category");
    List<String> appenderCalls = [];
    logging.appender = (String message, {int? wrapWidth}) => appenderCalls.add(message);

    final expectedLogCallsCount = {
      LogLevel.trace: 5,
      LogLevel.debug: 4,
      LogLevel.info: 3,
      LogLevel.warn: 2,
      LogLevel.error: 1,
    };

    expectedLogCallsCount.forEach((minLogLevel, expectedCallsCount) {
      logging.minLogLevel = minLogLevel;
      logger.trace(() => "trace message");
      logger.debug(() => "debug message");
      logger.info(() => "info message");
      logger.warn(() => "warn message");
      logger.error(() => "error message");

      expect(appenderCalls, hasLength(expectedCallsCount));
      appenderCalls.clear();
    });
  });
}
