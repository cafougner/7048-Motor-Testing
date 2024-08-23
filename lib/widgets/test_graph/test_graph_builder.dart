import "package:fl_chart/fl_chart.dart";

import "package:flutter/material.dart";

import "package:frc_7048_motor_testing/widgets/test_graph/test_graph.dart";
import "package:frc_7048_motor_testing/widgets/test_graph/test_graph_layout_state.dart";

class TestGraphBuilder extends StatelessWidget {
  const TestGraphBuilder({
    super.key,
    required this.testGraphID,
    required this.testGraphLayoutState,
    required this.motorBaselineDatapoints
  });

  final int testGraphID;
  final TestGraphLayoutState testGraphLayoutState;
  final Map<int, List<double>>? motorBaselineDatapoints; // This can also be from testGraphLayoutState[testGraphID]

  static const List<Color> _graphColors = <Color> [
    Color.fromARGB(180, 220, 30, 30), // Modified Colors.red
    Color.fromARGB(180, 0, 135, 255), // Modified Colors.blue
    Color.fromARGB(180, 255, 190, 5), // Modified Colors.amber
    Color.fromARGB(180, 50, 175, 50), // Modified Colors.green
    Color.fromARGB(180, 115, 70, 210) // Modified Colors.deepPurple
  ];

  @override
  Widget build(final BuildContext context) {
    final String graphName = testGraphLayoutState.graphNames[testGraphID] ?? "";

    final Map<int, List<double>> testResults = testGraphLayoutState.testResults[testGraphID] ?? {};

    if (!_dataIsValid(testGraphID, testGraphLayoutState, motorBaselineDatapoints)) {
      if (!testGraphLayoutState.expandGraphs) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),

            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).appBarTheme.backgroundColor
              )
            )
          )
        );
      }

      else {
        return const SizedBox.shrink();
      }
    }

    final double testLength = _testLength(testResults);
    final List<Row> lineChartColorKeys = _getLineChartColorKeys(context, testGraphLayoutState.motorNames, testResults);
    final List<LineChartBarData> lineChartBarData = _getLineChartBarData(testResults, motorBaselineDatapoints!, testGraphID);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).appBarTheme.backgroundColor
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: <Widget> [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),

                  child: TestGraph(
                    testGraphLayoutState: testGraphLayoutState,
                    graphName: graphName,
                    testLength: testLength,
                    lineChartBarData: lineChartBarData
                  )
                )
              ),

              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: <Widget> [
                    for (final Row lineChartColorKey in lineChartColorKeys)
                      lineChartColorKey
                  ]
                )
              )
            ]
          )
        )
      )
    );
  }

  /// Returns false if there is no graph name, motor names, test results, or baseline results.
  bool _dataIsValid(final int testGraphID, final TestGraphLayoutState testGraphLayoutState, final Map<int, List<double>>? motorBaselineDatapoints) {
    if (
      (testGraphLayoutState.graphNames[testGraphID] ?? "").isEmpty ||
      testGraphLayoutState.motorNames.isEmpty ||
      (testGraphLayoutState.testResults[testGraphID] ?? {}).isEmpty ||
      motorBaselineDatapoints == null
    ) {
      return false;
    }

    else {
      return true;
    }
  }

  double _testLength(final Map<int, List<double>> testResults) {
    double testLength = 0;

    for (final MapEntry<int, List<double>> entry in testResults.entries) {
      final double entryLength = entry.value.length / 50 - 0.02;
      if (entryLength > testLength) testLength = entryLength;
    }

    return testLength;
  }

  List<LineChartBarData> _getLineChartBarData(final Map<int, List<double>> motorDatapoints, Map<int, List<double>> motorBaselineDatapoints, final int testGraphID) {
    // Is there a way we can do these without the color index, like the spots loop?
    final List<LineChartBarData> lineChartBarData = <LineChartBarData> [];
    int colorIndex = 0;

    for (final MapEntry<int, List<double>> entry in motorBaselineDatapoints.entries) {
      if (!motorDatapoints.containsKey(entry.key)) {
        motorBaselineDatapoints = {};
        break;
      }
    }

    for (final MapEntry<int, List<double>> entry in motorDatapoints.entries) {
      final List<double> datapoints = entry.value;
      final List<double> baseline = motorBaselineDatapoints[entry.key] ?? entry.value;

      // If the length of the entry v the saved baselines are not equal, we overwrite the new baselines with the current data
      // else, we subtract the baselines from the current, making a new map with the quality modulo

      lineChartBarData.add(
        LineChartBarData(
          color: _graphColors[colorIndex % _graphColors.length],
          dotData: const FlDotData(show: false),

          barWidth: 1.25,

          spots: <FlSpot> [
            for (int i = 0; i < datapoints.length; i++)
              // Here is where we change the "quality"
              // we also make sure to always graph the last point in the graph
              if (i % testGraphLayoutState.graphQuality == 0 || i + 1 == datapoints.length)
                FlSpot(i / 50, datapoints[i] - baseline[i])
          ]
        )
      );

      colorIndex++;
    }

    return lineChartBarData;
  }

  List<Row> _getLineChartColorKeys(final BuildContext context, final Map<int, String> motorNames, final Map<int, List<double>> motorDatapoints) {
    final List<Row> lineChartColorKeys = <Row> [];
    int colorIndex = 0;

    for (final MapEntry<int, List<double>> entry in motorDatapoints.entries) {
      final int entryKey = entry.key;
      String entryName = motorNames[entryKey] ?? "MISSING-ID$entryKey";

      if (entryName.isEmpty) entryName = "MISSING_ID$entryKey";

      lineChartColorKeys.add(
        Row(
          children: <Widget> [
            Container(
              width: 12,
              height: 3,

              // Since the text is on the bottom of the container, we have to add an offset
              // to the color swatch to vertically align it to the text
              margin: EdgeInsets.only(top: Theme.of(context).textTheme.labelSmall?.height ?? 0),
              color: _graphColors[colorIndex % _graphColors.length],
            ),

            const SizedBox(width: 8),

            // These should overflow when there isnt enough room, but they dont
            Text(entryName, style: Theme.of(context).textTheme.labelSmall)
          ]
        )
      );

      colorIndex++;
    }

    return lineChartColorKeys;
  }
}
