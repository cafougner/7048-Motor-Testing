import "dart:async";

import "package:flutter/material.dart";

import "package:frc_7048_motor_testing/dialogs/app_settings_dialog.dart";
import "package:frc_7048_motor_testing/dialogs/motor_testing_dialog.dart";
import "package:frc_7048_motor_testing/resources/log_writer.dart";
import "package:frc_7048_motor_testing/resources/nt/nt_interface.dart";
import "package:frc_7048_motor_testing/resources/utils/screenshot_utils.dart";
import "package:frc_7048_motor_testing/widgets/test_graph/test_graph_layout.dart";
import "package:frc_7048_motor_testing/widgets/test_graph/test_graph_layout_state.dart";

class MotorTestingPage extends StatelessWidget {
  const MotorTestingPage({super.key});

  static final GlobalKey _graphScreenshotKey = GlobalKey();
  static final TestGraphLayoutState _testGraphLayoutState = TestGraphLayoutState();

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 32 + 16,
        leadingWidth: 246,

        title: Tooltip(
          message: "Open app settings dialog.",
          child: TextButton(
            onPressed: () {_showAppSettingsDialog(context);},
            child: Text("7048 Motor Testing", style: Theme.of(context).textTheme.titleLarge),
          )
        ),

        leading: const Padding(
          padding: EdgeInsets.all(8),

          child: AppInfoWidget()
        ),

        actions: <Widget> [
          ListenableBuilder(
            listenable: _testGraphLayoutState,
            builder: (final BuildContext context, final _) {
              if (_testGraphLayoutState.testResults.isEmpty) {
                return SizedBox(
                  width: 32,
                  height: 32,

                  child: Tooltip(
                    message: "There are no graphed results to screenshot.",
                    child: IconButton(
                      icon: Image.asset("lib/resources/icons/saveGraphs.png", color: Theme.of(context).colorScheme.onSurface.withAlpha(25)),
                      padding: const EdgeInsets.all(6),
                      onPressed: null,
                    )
                  )
                );
              }

              else {
                return SizedBox(
                  width: 32,
                  height: 32,

                  child: Tooltip(
                    message: "Screenshot graphed results to roaming appdata.",
                    child: IconButton(
                      icon: Image.asset("lib/resources/icons/saveGraphs.png", color: Theme.of(context).colorScheme.onSurface),
                      padding: const EdgeInsets.all(6),
                      onPressed: () {unawaited(screenshotGlobalKey(globalKey: _graphScreenshotKey, pixelRatio: 4.0));},
                    )
                  )
                );
              }
            }
          ),

          const VerticalDivider(width: 16 + 2, thickness: 2, indent: 4 + 8, endIndent: 4 + 8),

          Padding(
            padding: const EdgeInsets.only(right: 8),

            child: SizedBox(
              width: 32,
              height: 32,

              child: Tooltip(
                message: "Open motor testing dialog.",
                child: IconButton(
                  icon: Image.asset("lib/resources/icons/openDialog.png", color: Theme.of(context).colorScheme.onSurface),
                  padding: const EdgeInsets.all(6),
                  onPressed: () {_showMotorTestingDialog(context);},
                )
              )
            )
          )
        ],
      ),

      body: RepaintBoundary(
        key: _graphScreenshotKey,
        child: TestGraphLayout()
      )
    );
  }

  void _showMotorTestingDialog(final BuildContext context) {
    unawaited(showDialog(
      context: context,
      builder: (final BuildContext context) {
        return const MotorTestingDialog();
      },

      barrierColor: const Color.fromARGB(125, 0, 0, 0)
    ));
  }

  void _showAppSettingsDialog(final BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (final BuildContext context) {
        return const AppSettingsDialog();
      },

      barrierColor: const Color.fromARGB(125, 0, 0, 0)
    );
  }
}

class AppInfoWidget extends StatelessWidget {
  const AppInfoWidget({super.key});

  @override
  Widget build(final BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: NTInterface.connectionNotifier,
      builder: (final BuildContext context, final bool connected, final _) {
        if (connected) {
          return Row(
            children: <Widget> [
              const Tooltip(
                message: "NetworkTables status. Currently, there is a connection.",
                child: Text("NT4", style: TextStyle(color: Color.fromARGB(255, 0, 200, 0), fontWeight: FontWeight.w700))
              ),

              const VerticalDivider(width: 16 + 2, thickness: 2, indent: 4, endIndent: 4),

              ValueListenableBuilder(
                valueListenable: NTInterface.testStatusNotifier,
                builder: (final BuildContext context, final String testStatus, final _) {
                  switch (testStatus) {
                    case "Waiting":
                      return const Tooltip(
                        message: "App status. Currently, it is waiting for a test to be ran.",
                        child: Text("Waiting for Test Command")
                      );
                    
                    case "Starting":
                      return const Tooltip(
                        message: "App status. Currently, it is attempting to start a test.",
                        child: Text("Starting Test Routine")
                      );
                    
                    case "Running":
                      return const Tooltip(
                        message: "App status. Currently, it is waiting for test results.",
                        child: Text("Waiting for Test Results")
                      );
                    
                    default:
                      LogWriter.logError(message: "Invalid app status: $testStatus");
                      
                      return const Tooltip(
                        message: "App status. Currently, the app does not have a valid status.",
                        child: Text("Invalid App Status")
                      );
                  }
                }
              )
            ]
          );
        }

        else {
          return const Row(
            children: <Widget> [
              Tooltip(
                message: "NetworkTables status. Currently, there is no connection",
                child: Text("NT4", style: TextStyle(color: Color.fromARGB(255, 225, 0, 0), fontWeight: FontWeight.w700))
              ),

              VerticalDivider(width: 16 + 2, thickness: 2, indent: 4, endIndent: 4),

              Tooltip(
                message: "App status. Currently, it is watiing for an NT4 connection.",
                child: Text("Waiting for Connection")
              )
            ],
          );
        }
      }
    );
  }
}
