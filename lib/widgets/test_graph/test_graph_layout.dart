import "package:flutter/material.dart";

import "package:frc_7048_motor_testing/resources/log_writer.dart";
import "package:frc_7048_motor_testing/resources/nt/nt_interface.dart";
import "package:frc_7048_motor_testing/resources/utils/build_context_x.dart";
import "package:frc_7048_motor_testing/widgets/test_graph/test_graph_builder.dart";
import "package:frc_7048_motor_testing/widgets/test_graph/test_graph_layout_state.dart";

class TestGraphLayout extends StatelessWidget {
  TestGraphLayout({super.key});

  final TestGraphLayoutState _testGraphLayoutState = TestGraphLayoutState();

  @override
  Widget build(final BuildContext context) {
    return ListenableBuilder(
      listenable: _testGraphLayoutState,
      builder: (final BuildContext context, final _) {
        return Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: <Widget> [
              // The graphs are drawn if they don't expand, or if they do expand and there is valid data for any of them.
              if ((_anyDataIsValid(_testGraphLayoutState, [1, 2, 3]) && _testGraphLayoutState.expandGraphs) || !_testGraphLayoutState.expandGraphs)
                Expanded(
                  child: Row(
                    children: <Widget> [
                      TestGraphBuilder(
                        testGraphID: 1,
                        testGraphLayoutState: _testGraphLayoutState,
                        motorBaselineDatapoints: _testGraphLayoutState.baselineResults[1],
                      ),

                      TestGraphBuilder(
                        testGraphID: 2,
                        testGraphLayoutState: _testGraphLayoutState,
                        motorBaselineDatapoints: _testGraphLayoutState.baselineResults[2]
                      ),

                      TestGraphBuilder(
                        testGraphID: 3,
                        testGraphLayoutState: _testGraphLayoutState,
                        motorBaselineDatapoints: _testGraphLayoutState.baselineResults[3]
                      )
                    ]
                  )
                ),

              if ((_anyDataIsValid(_testGraphLayoutState, [4, 5, 6]) && _testGraphLayoutState.expandGraphs) || !_testGraphLayoutState.expandGraphs)
                Expanded(
                  child: Row(
                    children: <Widget> [
                      TestGraphBuilder(
                        testGraphID: 4,
                        testGraphLayoutState: _testGraphLayoutState,
                        motorBaselineDatapoints: _testGraphLayoutState.baselineResults[4],
                      ),

                      TestGraphBuilder(
                        testGraphID: 5,
                        testGraphLayoutState: _testGraphLayoutState,
                        motorBaselineDatapoints: _testGraphLayoutState.baselineResults[5]
                      ),

                      TestGraphBuilder(
                        testGraphID: 6,
                        testGraphLayoutState: _testGraphLayoutState,
                        motorBaselineDatapoints: _testGraphLayoutState.baselineResults[6]
                      )
                    ]
                  )
                ),

              if ((_anyDataIsValid(_testGraphLayoutState, [1, 2, 3, 4, 5, 6]) && _testGraphLayoutState.expandGraphs) || !_testGraphLayoutState.expandGraphs)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    color: context.theme.appBarTheme.backgroundColor,
                    width: double.infinity,

                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        !_robotDataIsValid(_testGraphLayoutState)  ? "" :
                        "Results graphed from ${_testGraphLayoutState.robotName}'s ${NTInterface.testTypesNotifier.value[_testGraphLayoutState.testResultsKey]}.",
                        
                        style: context.labelSmall,
                        textAlign: TextAlign.center
                      )
                    )
                  )
                )
            ]
          )
        );
      }
    );
  }

  bool _anyDataIsValid(final TestGraphLayoutState testGraphLayoutState, final List<int> graphIDs) {
    LogWriter.logDebug(message: "Checking any graph in the given range for valid data...");

    bool dataIsValid(final String graphName, final Map<int, String> motorNames, final Map<int, List<double>> motorDatapoints) {
      if (graphName.isEmpty || motorNames.isEmpty || motorDatapoints.isEmpty) {
        LogWriter.logDebug(
          message: "graphName, motorNames, or motorDatapoints is not valid data.\n"
          "graphName: $graphName\n"
          "motorNames.isEmpty: ${motorNames.isEmpty}\n"
          "motorDatapoints.isEmpty: ${motorDatapoints.isEmpty}"
        );

        return false;
      }

      // Checking if each motor has a valid name.
      for (final datapointEntry in motorDatapoints.entries) {
        if (!motorNames.containsKey(datapointEntry.key)) {
          LogWriter.logDebug(message: "Motor ${datapointEntry.key} does not have a valid name.");

          return false;
        }
      }

      return true;
    }

    for (final graphID in graphIDs) {
      LogWriter.logDebug(message: "Checking graph $graphID...");

      if (dataIsValid(testGraphLayoutState.graphNames[graphID] ?? "", testGraphLayoutState.motorNames, testGraphLayoutState.testResults[graphID] ?? {})) {
        LogWriter.logDebug(message: "A graph within the range had valid data, completed successfully.");

        return true;
      }
    }

    LogWriter.logDebug(message: "No graph within the range had valid data, completed successfully.");

    return false;
  }

  bool _robotDataIsValid(final TestGraphLayoutState testGraphLayoutState) {
    // True or false if the robot has a name, a test results key, and the test has a name.
    return (
      (testGraphLayoutState.robotName != null) && (testGraphLayoutState.testResultsKey != null) && (NTInterface.testTypesNotifier.value[testGraphLayoutState.testResultsKey] != null)
    );
  }
}
