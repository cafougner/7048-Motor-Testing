import "dart:io";

import "package:flutter/foundation.dart";

import "package:frc_7048_motor_testing/build_info.dart";

import "package:logger/logger.dart";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";

/// A static interface to a [Logger].
///
/// Based off of M. Jansen (FRC 3015)'s [PathPlanner logging](https://github.com/mjansen4857/pathplanner/blob/main/lib/services/log.dart).
class LogWriter {
  static Logger? _logger;
  static const String _logFileExtension = "log.txt";

  static Future<void> ensureInitialized() async {
    if (_logger == null) {
      final File logFile = File(join((await getApplicationSupportDirectory()).path, _logFileExtension));

      _logger = Logger(
        filter: ProductionFilter(),

        // Colors don't work for logging to the file, but they make the console output clearer.
        printer: SimplePrinter(printTime: true, colors: kDebugMode),
        output: MultiOutput([
          if (kDebugMode) ConsoleOutput(),
          FileOutput(file: logFile, overrideExisting: true)
        ]),

        level: (kDebugMode || BuildInfo.includeDebugInfo) ? LogLevel.all : LogLevel.info
      );
    }
  }
  
  static void log({required final Level logLevel, final dynamic message, final DateTime? time, final Object? error, final StackTrace? stackTrace}) {
    // If _logger is null, the log is discarded since logging isn't critical to the programs function.
    _logger?.log(logLevel, message, time: time, error: error, stackTrace: stackTrace);
  }

  static void logFatal({final dynamic message, final DateTime? time, final Object? error, final StackTrace? stackTrace}) {
    log(logLevel: LogLevel.fatal, message: message, time: time, error: error, stackTrace: stackTrace);
  }

  static void logError({final dynamic message, final DateTime? time, final Object? error, final StackTrace? stackTrace}) {
    log(logLevel: LogLevel.error, message: message, time: time, error: error, stackTrace: stackTrace);
  }

  static void logWarning({final dynamic message, final DateTime? time, final Object? error, final StackTrace? stackTrace}) {
    log(logLevel: LogLevel.warning, message: message, time: time, error: error, stackTrace: stackTrace);
  }

  static void logInfo({final dynamic message, final DateTime? time, final Object? error, final StackTrace? stackTrace}) {
    log(logLevel: LogLevel.info, message: message, time: time, error: error, stackTrace: stackTrace);
  }

  /// Logs debug information that is not included in release builds.
  static void logDebug({final dynamic message, final DateTime? time, final Object? error, final StackTrace? stackTrace}) {
    log(logLevel: LogLevel.debug, message: message, time: time, error: error, stackTrace: stackTrace);
  }
}

class LogLevel {
  static const Level off = Level.off;
  static const Level fatal = Level.fatal;
  static const Level error = Level.error;
  static const Level warning = Level.warning;
  static const Level info = Level.info;
  static const Level debug = Level.debug;
  static const Level trace = Level.trace;
  static const Level all = Level.all;
}
