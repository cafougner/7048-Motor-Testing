import "package:flutter/material.dart";

import "package:frc_7048_motor_testing/resources/log_writer.dart";
import "package:frc_7048_motor_testing/resources/nt/nt_interface.dart";
import "package:frc_7048_motor_testing/resources/utils/build_context_x.dart";
import "package:frc_7048_motor_testing/widgets/test_graph/test_graph_layout_state.dart";

class MotorTestingDialog extends StatelessWidget {
  const MotorTestingDialog({super.key});

  static final TestGraphLayoutState _testGraphLayoutState = TestGraphLayoutState();

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: <Widget> [
          Text("Motor Testing", style: context.titleMedium),

          IconButton(
            color: context.colorScheme.onSurface,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded)
          )
        ]
      ),

      content: SizedBox(
        width: 480,
        height: 96,

        child: Column(
          children: <Widget> [
            Row(
              children: <Widget> [
                ValueListenableBuilder(
                  valueListenable: NTInterface.testTypesNotifier,
                  builder: (final BuildContext context, final Map<int, String> testTypes, final _) {
                    if (testTypes.isNotEmpty) {
                      return DropdownMenu(
                        enabled: true,

                        width: (480 - 16) / 2,
                        label: const Text("Test Routine"),

                        initialSelection: NTInterface.selectedTestType,
                        onSelected: (final int? selection) => NTInterface.selectedTestType = selection,

                        requestFocusOnTap: false,

                        dropdownMenuEntries: testTypes.entries.map((final MapEntry<int, String> entry) =>
                          DropdownMenuEntry(value: entry.key, label: entry.value)
                        ).toList()
                      );
                    }

                    else {
                      return const Tooltip(
                        message: "There are no test routines to select from.",
                        child: DropdownMenu(
                          enabled: false,

                          width: (480 - 16) / 2,
                          label: Text("Test Routine"),

                          requestFocusOnTap: false,
                          dropdownMenuEntries: <DropdownMenuEntry<int>> []
                        )
                      );
                    }
                  }
                ),

                const SizedBox(width: 16),

                const Expanded(child: TestCommandButton())
              ]
            ),

            const SizedBox(height: 16),

            Row(
              children: <Widget> [
                Expanded(
                  child: Tooltip(
                    message: "Clears all saved test baselines (for the current robot) from the local device.",
                    child: OutlinedButton(
                      onPressed: () => _testGraphLayoutState.clearAllBaselineResults(), // ignore: discarded_futures
                      child: const Text("Clear Robot Test Baselines")
                    )
                  )
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: ListenableBuilder(
                    listenable: _testGraphLayoutState,
                    builder: (final BuildContext context, final _) {
                      if (_testGraphLayoutState.testResults.isNotEmpty) {
                        return Tooltip(
                          message: "Saves the current test results as the baseline for that test, on the local device.",
                          child: OutlinedButton(
                            onPressed: () => _testGraphLayoutState.setBaselineResultsAsCurrent(),
                            child: const Text("Save New Test Baselines")
                          )
                        );
                      }

                      else {
                        return const Tooltip(
                          message: "There are no test results to save as baselines.",
                          child: OutlinedButton(
                            onPressed: null,
                            child: Text("Save New Test Baselines")
                          )
                        );
                      }
                    }
                  )
                )
              ]
            )
          ],
        )
      ),

      backgroundColor: context.theme.appBarTheme.backgroundColor
    );
  }
}

class TestCommandButton extends StatelessWidget {
  const TestCommandButton({super.key});

  @override
  Widget build(final BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: NTInterface.connectionNotifier,
      builder: (final BuildContext context, final bool connected, final _) {
        if (connected) {
          return ValueListenableBuilder(
            valueListenable: NTInterface.testStatusNotifier,
            builder: (final BuildContext context, final String testStatus, final _) {
              switch (testStatus) {
                case "Waiting":
                  return Tooltip(
                    message: "Sends the command to run the selected test routine and graph the results.",
                    child: OutlinedButton(
                      onPressed: () => NTInterface.sendTestSignal(), // ignore: discarded_futures
                      child: const Text("Send Test Command")
                    )
                  );

                case "Starting":
                  return Tooltip(
                    message: "Resends the command to run the selected test routine and graph the results.",
                    child: OutlinedButton(
                      onPressed: () => NTInterface.sendTestSignal(), // ignore: discarded_futures
                      child: const Text("Resend Test Command")
                    )
                  );

                case "Running":
                  return const Tooltip(
                    message: "You cannot resend the command to run the selected test while one is currently running.",
                    child: OutlinedButton(
                      onPressed: null,
                      child: Text("Resend Test Command")
                    )
                  );

                default:
                  LogWriter.logError(message: "Invalid app status: $testStatus");

                  return const Tooltip(
                    message: "You cannot send the test command while the app has an invalid status.",
                    child: OutlinedButton(
                      onPressed: null,
                      child: Text("Send Test Command")
                    )
                  );
              }
            }
          );
        }

        else {
          return const Tooltip(
            message: "You cannot send the test command while there is no NT4 connection.",
            child: OutlinedButton(
              onPressed: null,
              child: Text("Send Test Command")
            )
          );
        }
      }
    );
  }
}
