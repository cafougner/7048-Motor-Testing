import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "package:frc_7048_motor_testing/build_info.dart";
import "package:frc_7048_motor_testing/pages/motor_testing_page.dart";
import "package:frc_7048_motor_testing/resources/json_interface.dart";
import "package:frc_7048_motor_testing/resources/log_writer.dart";
import "package:frc_7048_motor_testing/resources/nt/nt_interface.dart";
import "package:frc_7048_motor_testing/resources/preferences.dart";
import "package:frc_7048_motor_testing/resources/utils/debug_utils.dart";
import "package:frc_7048_motor_testing/resources/utils/theme_utils.dart";

import "package:window_manager/window_manager.dart";

const WindowOptions _windowOptions = WindowOptions(
  size: Size(1100, 650),
  center: true,

  minimumSize: Size(1100, 650),
  title: "7048 Motor Testing"
);

void main() async {
  await LogWriter.ensureInitialized();
  LogWriter.logInfo(
    message: "Initializing app version ${BuildInfo.version}-${BuildInfo.date} "
    "${(kDebugMode || BuildInfo.includeDebugInfo) ? "with debugging." : "without debugging."}"
  );

  FlutterError.onError = handleFlutterError;
  WidgetsFlutterBinding.ensureInitialized();

  // Preferences, JsonInterface, and WindowManager do not depend on each other and can be initialized at the same time.
  await Future.wait([
    Preferences.ensureInitialized(),
    JsonInterface.ensureInitialized(),
    windowManager.ensureInitialized()
  ]);

  NTInterface.ensureInitialized();

  await windowManager.waitUntilReadyToShow(_windowOptions);

  LogWriter.logInfo(message: "Showing app.");
  runApp(const Frc7048MotorTesting());
}

class Frc7048MotorTesting extends StatelessWidget {
  const Frc7048MotorTesting({super.key});

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      home: const MotorTestingPage(),

      title: "7048 Motor Testing",
      theme: darkTheme(),

      debugShowCheckedModeBanner: false,
    );
  }
}
