class BuildInfo {
  // Both these and the pubspec.yaml need to be updated manually to
  // match. version is major.minor.patch and buildDate is YYYY.MM.DD.
  static const String version = "1.0.0";
  static const String date = "2024.08.23";

  // This applies to LogWriter, if the additional debug
  // information should be included in a release build.
  static const bool includeDebugInfo = true;
}
