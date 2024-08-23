/// A static interface for String parsers for data from the NTInterface.
class NTParser {
  static bool parseBoolString(final Object? data) {
    final String dataString = data.toString();
    if (dataString.isEmpty || dataString == "true") return true;

    return false;
  }

  // TODO: Rewrite this to be simpler (is not ChatGPT).
  /// Returns a `Map<int, String>` parsed from the [data.toString()].
  static Map<int, String> parseIntStringMapString(final Object? data) {
    final Map<int, String> dataMap = {};
    String dataString = data.toString();

    if (dataString.isEmpty) return dataMap;

    dataString = dataString.substring(1, dataString.length - 1);
    final List<String> dataPairs = dataString.split(", ");

    for (final String dataPair in dataPairs) {
      final List<String> data = dataPair.split("=");

      final int dataKey = int.parse(data[0]);
      final String dataValue = data[1];

      dataMap[dataKey] = dataValue;
    }

    return dataMap;
  }

  // TODO: Rewrite this to be simpler (is chatGPT).
  /// Returns a `Map<int, Map<int, List<double>>>` parsed from the [data.toString()].
  static Map<int, Map<int, List<double>>> parseResultsMapString(final Object? data) {
    final Map<int, Map<int, List<double>>> resultsMap = {};
    String dataString = data.toString();

    if (dataString.isEmpty) return resultsMap;

    dataString = dataString.substring(1, dataString.length - 1);
    final List<String> dataMaps = dataString.split("}, ");

    for (final String dataMap in dataMaps) {
      final List<String> data = dataMap.split("={");
      final int outerKey = int.parse(data[0]);
      final String innerDataString = data[1];

      if (innerDataString.endsWith("]")) innerDataString.substring(0, innerDataString.length - 1);

      final List<String> innerMaps = innerDataString.split("], ");
      resultsMap[outerKey] ??= {};

      for (final String innerMap in innerMaps) {
        final List<String> innerData = innerMap.split("=");
        final int innerKey = int.parse(innerData[0]);
        List<double> innerValues = [];

        final String valuesString = innerData[1].replaceAll("[", "").replaceAll("]", "").replaceAll("}", "");
        final List<String> valuesList = valuesString.split(", ");
        innerValues = valuesList.map(double.parse).toList();

        resultsMap[outerKey] ? [innerKey] = innerValues;
      }
    }
    
    return resultsMap;
  }
}
