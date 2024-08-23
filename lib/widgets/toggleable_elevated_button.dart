import "package:flutter/material.dart";

import "package:frc_7048_motor_testing/resources/utils/build_context_x.dart";

class ToggleableElevatedButton extends StatefulWidget {
  const ToggleableElevatedButton({super.key, required this.buttonText, required this.onPressed, required this.toggled});

  final String buttonText;
  final Function onPressed;
  final bool toggled;

  @override
  State<ToggleableElevatedButton> createState() => _ToggleableElevatedButtonState();
}

class _ToggleableElevatedButtonState extends State<ToggleableElevatedButton> {
  bool? toggled;

  @override
  Widget build(final BuildContext context) {
    toggled ??= widget.toggled;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          toggled = !toggled!;
        });

        widget.onPressed(toggled);
      },

      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color?> (
          // If the button is toggled, it has a brighter color than if it is not toggled.
          toggled! ? context.theme.colorScheme.surfaceBright : context.theme.colorScheme.surfaceContainerHigh.withAlpha(225)
        )
      ),

      child: Text(widget.buttonText)
    );
  }
}
