import "dart:io";
import "dart:ui";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart" hide Image;
import "package:flutter/rendering.dart";

import "package:frc_7048_motor_testing/resources/log_writer.dart";

import "package:path/path.dart";
import "package:path_provider/path_provider.dart";

const String _screenshotsFolder = "screenshots";

/// Renders a [globalKey] with a [pixelRatio] and saves it to the disk.
/// 
/// The image resolution is affected by the window size as well as the [pixelRatio].
/// If an [Error] or [Exception] is thrown, the program logs it and fails gracefully.
/// 
/// Example:
/// ```
/// class SomeWidget extends StatelessWidget {
///   // [screenshotGlobalKey()] can be called with the [_screenshotKey] as the [globalKey],
///   // which will save [SomeWidgetToScreenshot] as a ".png" file in the [_screenshotsFolder].
///   static final GlobalKey _screenshotKey = GlobalKey();
/// 
///   @override
///   Widget build(final BuildContext context) {
///     return RepaintBoundary(
///       key: _screenshotKey,
///       child: SomeWidgetToScreenshot()
///     );
///   }
/// }
/// ```
/// 
/// See also:
/// * Flutter API for [[RenderRepaintBoundary.toImage()]](https://api.flutter.dev/flutter/rendering/RenderRepaintBoundary/toImage.html).
Future<void> screenshotGlobalKey({required final GlobalKey globalKey, final double pixelRatio = 1.0}) async {
  try {
    LogWriter.logDebug(message: "Screenshotting globalKey...");

    final RenderRepaintBoundary repaintBoundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final Image boundaryImage = await repaintBoundary.toImage(pixelRatio: pixelRatio);

    final ByteData? byteData = await boundaryImage.toByteData(format: ImageByteFormat.png);
    final Uint8List bytes = byteData!.buffer.asUint8List();
    
    final File screenshotFile = await
      File(join((await getApplicationSupportDirectory()).path, _screenshotsFolder, "${_getFormattedDateTime()}.png")).create(recursive: true);
    
    await screenshotFile.writeAsBytes(bytes);
    LogWriter.logInfo(message: "Screenshotted [globalKey] to ${screenshotFile.path}");
  }

  catch(error, stackTrace) {
    LogWriter.logError(
      message: "Error or Exception while screenshotting a globalKey. The program "
      "will fail gracefully, since this is not a critical program function.",
      error: error,
      stackTrace: stackTrace
    );
  }
}

String _getFormattedDateTime() {
  final DateTime dateTime = DateTime.now();
  final dateTimeYear = dateTime.year.toString().padLeft(4, "0");
  final dateTimeMonth = dateTime.month.toString().padLeft(2, "0");
  final dateTimeDay = dateTime.day.toString().padLeft(2, "0");
  final dateTimeHour = dateTime.hour.toString().padLeft(2, "0");
  final dateTimeMinute = dateTime.minute.toString().padLeft(2, "0");
  final dateTimeSecond = dateTime.second.toString().padLeft(2, "0");
  final dateTimeMillisecond = dateTime.millisecond.toString().padLeft(4, "0");

  return "$dateTimeYear-$dateTimeMonth-$dateTimeDay $dateTimeHour-$dateTimeMinute-$dateTimeSecond.$dateTimeMillisecond";
}
