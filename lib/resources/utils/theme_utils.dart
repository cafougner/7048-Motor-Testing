import "package:flutter/material.dart";

import "package:google_fonts/google_fonts.dart";

ThemeData darkTheme({final Color seedColor = const Color.fromARGB(255, 29, 29, 32)}) {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: seedColor
  );

  // Shifting the color of the appBar so it is slightly lighter than the background of the MotorTestingPage.
  // The shifted color is also used by all app dialogs and the decorated boxes containing the TestGraphs.
  final HSLColor surfaceColor = HSLColor.fromColor(colorScheme.surface);
  Color shiftedSurfaceColor = surfaceColor.toColor();

  shiftedSurfaceColor = surfaceColor.withLightness(surfaceColor.lightness + 0.0225)
    .withSaturation(surfaceColor.saturation - 0.05).toColor();

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,

    // fontFamily does not seem to handle the fontWeight properly, so these have to be declared individually.
    textTheme: TextTheme(
      titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600), // Used for the titlebar title text.
      titleMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600), // Used for the dialog titles text.
      titleSmall: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600), // Used for the graph titles text.

      bodyLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500), // Used for the selected dropdown text.
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500), // Used for the primary text.
      bodySmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500), // Used for the waiting text.

      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600), // Used for the selecting dropdown text and button text.
      labelMedium: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600), // Used for the graph labels text.
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600) // Used for the graph scales and graph keys.
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: shiftedSurfaceColor
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
        )
      )
    ),

    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          // This makes the color slightly darker (it should always be ontop of a dialog or appbar, so alpha can be used).
          colorScheme.surfaceContainerHigh.withAlpha(225)
        ),

        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
        )
      )
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(4)
      ),

      textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),

      waitDuration: const Duration(milliseconds: 150),
      showDuration: const Duration(milliseconds: 350),
      exitDuration: const Duration(milliseconds: 200)
    )
  );
}
