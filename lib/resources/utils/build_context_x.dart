import "package:flutter/material.dart";

/// [BuildContext] extensions for accessing themes.
///
/// Instead of doing `Theme.of(context)` or `Theme.of(context).textTheme.titleLarge`,
/// The shorter and easier to read `context.theme` and `context.titleLarge` can be used instead.
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;

  TextStyle get titleLarge => theme.textTheme.titleLarge!;
  TextStyle get titleMedium => theme.textTheme.titleMedium!;
  TextStyle get titleSmall => theme.textTheme.titleSmall!;

  TextStyle get bodyLarge => theme.textTheme.bodyLarge!;
  TextStyle get bodyMedium => theme.textTheme.bodyMedium!;
  TextStyle get bodySmall => theme.textTheme.bodySmall!;

  TextStyle get labelLarge => theme.textTheme.labelLarge!;
  TextStyle get labelMedium => theme.textTheme.labelMedium!;
  TextStyle get labelSmall => theme.textTheme.labelSmall!;
}
