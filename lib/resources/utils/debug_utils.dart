import "dart:io";

import "package:flutter/foundation.dart";

import "package:frc_7048_motor_testing/resources/log_writer.dart";

void printDebug(final Object? object) {
  if (kDebugMode) print(object);
}

/// The default handling of flutter errors, which is to log and exit.
void handleFlutterError(final FlutterErrorDetails errorDetails) {
  FlutterError.presentError(errorDetails);
  LogWriter.logFatal(message: "Fatal Flutter error. The program will now exit", error: errorDetails.exception, stackTrace: errorDetails.stack);
    
  exit(1);
}
