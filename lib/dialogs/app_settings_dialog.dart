import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "package:frc_7048_motor_testing/build_info.dart";
import "package:frc_7048_motor_testing/resources/preferences.dart";
import "package:frc_7048_motor_testing/resources/utils/build_context_x.dart";
import "package:frc_7048_motor_testing/widgets/toggleable_elevated_button.dart";

class AppSettingsDialog extends StatelessWidget {
  const AppSettingsDialog({super.key});

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: <Widget> [
          Text("App Settings", style: context.titleMedium),
          
          IconButton(
            color: context.colorScheme.onSurface,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          )
        ]
      ),

      content: SizedBox(
        width: 507.3,
        height: 144,

        child: Column(
          children: <Widget> [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: <Widget> [
                Expanded(child: NTHostField()),

                SizedBox(width: 16),

                Expanded(child: GraphRangeSlider())
              ]
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: <Widget> [
                DropdownMenu(
                  label: const Text("Graph Quality"),

                  initialSelection: Preferences.graphQuality,
                  onSelected: (final int? selection) => Preferences.graphQuality = selection ?? Default.graphQuality,

                  requestFocusOnTap: false,

                  dropdownMenuEntries: const <DropdownMenuEntry<int>> [
                    // When the graph is drawn, the value is used as a modulo. For example, `Full`
                    // would graph every `i % 1 = 0` point, and `Low` would graph every `i % 6 = 0` point.
                    DropdownMenuEntry(label: "Full", value: 1),
                    DropdownMenuEntry(label: "High", value: 2),
                    DropdownMenuEntry(label: "Normal", value: 4),
                    DropdownMenuEntry(label: "Low", value: 6),
                    DropdownMenuEntry(label: "Very Low", value: 8),
                  ],
                ),

                const SizedBox(width: 16),

                ToggleableElevatedButton(
                  buttonText: "Expand Graphs",
                  onPressed: (final bool toggled) => Preferences.expandGraphs = toggled,
                  toggled: Preferences.expandGraphs
                ),

                const SizedBox(width: 16),

                ToggleableElevatedButton(
                  buttonText: "Graph Touch Data",
                  onPressed: (final bool toggled) => Preferences.graphTouchData = toggled,
                  toggled: Preferences.graphTouchData
                )
              ]
            ),

            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: Text(
                "App version ${BuildInfo.version}-${BuildInfo.date} "
                "${(kDebugMode || BuildInfo.includeDebugInfo) ? "with debugging." : "without debugging."}",
                style: context.labelSmall,
                textAlign: TextAlign.left
              )
            )
          ],
        ),
      ),

      backgroundColor: context.theme.appBarTheme.backgroundColor,
    );
  }
}

class NTHostField extends StatelessWidget {
  const NTHostField({super.key});

  @override
  Widget build(final BuildContext context) {
    final TextEditingController controller = TextEditingController(
      // The default text every time it is built (the dialog is opened) is the currently saved ntHost.
      text: Preferences.ntHost
    );

    return TextField(
      controller: controller,

      decoration: InputDecoration(
        labelText: "NetworkTables Host IP",
        
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4))
      ),

      onChanged: (final String text) => Preferences.ntHost = text
    );
  }
}

class GraphRangeSlider extends StatefulWidget {
  const GraphRangeSlider({super.key});

  @override
  State<GraphRangeSlider> createState() => _GraphRangeSliderState();
}

class _GraphRangeSliderState extends State<GraphRangeSlider> {
  double graphRangeValue = Preferences.graphYRange;

  @override
  Widget build(final BuildContext context) {
    return Slider(
      value: graphRangeValue,

      onChanged: (final double value) {
        setState(() => graphRangeValue = value);
        Preferences.graphYRange = value;
      },

      min: 0.5,
      max: 10,

      // Getting the amount of divisions using the range and the step size (0.5 to 10, step size of 0.5)
      divisions: (10 - 0.5) ~/ 0.5,

      label: "Graph Y Range (+-): $graphRangeValue"
    );
  }
}
