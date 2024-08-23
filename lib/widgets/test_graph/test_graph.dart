import "package:fl_chart/fl_chart.dart";

import "package:flutter/material.dart";

import "package:frc_7048_motor_testing/resources/utils/build_context_x.dart";
import "package:frc_7048_motor_testing/resources/utils/text_utils.dart";
import "package:frc_7048_motor_testing/widgets/test_graph/test_graph_layout_state.dart";

/// The graph that is drawn by a [TestGraphBuilder], an interface for an FlChart [LineChart].
class TestGraph extends StatelessWidget {
  const TestGraph({
    super.key,
    required this.graphName,
    required this.testLength,
    required this.lineChartBarData,
    required this.testGraphLayoutState
  });

  final String graphName;
  final double testLength;
  final List<LineChartBarData> lineChartBarData;
  final TestGraphLayoutState testGraphLayoutState;

  @override
  Widget build(final BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: testLength,

        minY: -testGraphLayoutState.graphYRange,
        maxY: testGraphLayoutState.graphYRange,

        clipData: const FlClipData(top: true, bottom: true, left: true, right: true),
        borderData: FlBorderData(border: Border.all(color: const Color.fromARGB(255, 125, 125, 125), width: 0.5, strokeAlign: BorderSide.strokeAlignOutside)),

        gridData: FlGridData(
          horizontalInterval: testGraphLayoutState.graphYRange / 2,
          verticalInterval: testLength / 6,

          getDrawingHorizontalLine: (final double value) {
            if (value == 0) {
              return const FlLine(
                color: Color.fromARGB(255, 125, 125, 125),
                strokeWidth: 1
              );
            }

            else {
              return const FlLine(
                color: Color.fromARGB(50, 125, 125, 125),
                strokeWidth: 1
              );
            }
          },

          getDrawingVerticalLine: (final _) {
            return const FlLine(
              color: Color.fromARGB(50, 125, 125, 125),
              strokeWidth: 1
            );
          }
        ),

        lineTouchData: LineTouchData (
          enabled: testGraphLayoutState.graphTouchData,

          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            maxContentWidth: 180,

            tooltipPadding: const EdgeInsets.all(4),
            getTooltipColor: (final _) {return context.theme.colorScheme.surfaceBright;}
          )
        ),

        titlesData: FlTitlesData(
          topTitles: AxisTitles(
            axisNameSize: getTextHeight(text: graphName, style: context.labelMedium) + 4,
            axisNameWidget: Text(graphName, style: context.labelMedium)
          ),

          bottomTitles: AxisTitles(
            axisNameSize: getTextHeight(text: "Time (s)", style: context.labelMedium),
            axisNameWidget: Text("Time (s)", style: context.labelMedium)
,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: getTextHeight(text: "0", style: context.labelSmall) + 4,

              interval: testLength / 3,
              getTitlesWidget: (final _, final TitleMeta meta) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(meta.formattedValue, style: context.labelSmall)
                );
              }
            )
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: getTextWidth(text: "-4.3", style: context.labelSmall) + 8,

              interval: testGraphLayoutState.graphYRange / 2,
              getTitlesWidget: (final _, final TitleMeta meta) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(meta.formattedValue, style: context.labelSmall)
                  )
                );
              }
            )
          ),

          rightTitles: AxisTitles(
            // Unneccessary axis size so that the titles and keys are centered
            // axisNameSize: getTextHeight(text: "Error (A)", style: context.labelMedium) + 4,
            // TODO: Find the largest text in the interval instead of the largest possible, or use the height of Error (A)
            axisNameSize: getTextWidth(text: "-4.3", style: context.labelSmall) + 8,
            axisNameWidget: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 4, left: getTextHeight(text: "0", style: context.labelSmall) + 4),
                child: Text("Error (A)", style: context.labelMedium)
              )
            )
          )
        ),

        lineBarsData: lineChartBarData
      )
    );
  }
}
