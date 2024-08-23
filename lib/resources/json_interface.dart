import "dart:convert";
import "dart:io";

import "package:frc_7048_motor_testing/resources/log_writer.dart";

import "package:path/path.dart";
import "package:path_provider/path_provider.dart";

/// A static interface to read and write json files.
class JsonInterface {
  static Directory? _dataDirectory;
  static const String _dataFolder = "graphdata";

  // A map where _dataCache[robotName][testType][graphID] is a `Map<int, List<double>>` for each motor and its datapoints.
  static final Map<String, Map<int, Map<int, Map<int, List<double>>>>> _dataCache = {};

  static Future<void> ensureInitialized() async {
    LogWriter.logDebug(message: "Initializing JsonInterface...");

    if (_dataDirectory == null) {
      _dataDirectory = await Directory(join((await getApplicationSupportDirectory()).path, _dataFolder)).create(recursive: true);

      await _initializeDataCache();
      LogWriter.logInfo(message: "JsonInterface initialized.");
    }

    else {
      LogWriter.logDebug(message: "JsonInterface has already been initialized.");
    }
  }

  static Future<void> _initializeDataCache() async {
    LogWriter.logDebug(message: "Caching all stored json data...");

    await for (final FileSystemEntity entity in _dataDirectory!.list(recursive: true)) {
      if (entity is File && entity.path.endsWith(".json")) {
        String? robotName;
        int? testType;
        int? graphID;
        Map<int, List<double>> jsonData;

        LogWriter.logInfo(message: "Caching data from ${entity.path}");

        try {
          final List<String> fileNameData = split(entity.path);

          robotName = fileNameData[fileNameData.length - 3];
          testType = int.parse(fileNameData[fileNameData.length - 2].split("test-")[1]);
          graphID = int.parse(fileNameData[fileNameData.length - 1].split("graph-")[1].split(".json")[0]);
          jsonData = await _readJsonFile(entity);
        }

        catch(error, stackTrace) {
          LogWriter.logError(
            message: "Error while caching a json file, the app will skip this file.",
            error: error,
            stackTrace: stackTrace
          );

          continue;
        }

        _cacheJsonData(robotName: robotName, testType: testType, graphID: graphID, jsonData: jsonData);
        LogWriter.logDebug(message: "File data cached successfully.");
      
      }
    }

    LogWriter.logDebug(message: "Stored data cached successfully.");
  }

  static Future<void> clearRobotBaselines(final String? robotName) async {
    LogWriter.logDebug(message: "Deleting all baselines from $robotName...");

    if (robotName != null) {
      final Directory robotDataDirectory = Directory(join(_dataDirectory!.path, robotName));

      if (await robotDataDirectory.exists()) {
        try {
          await robotDataDirectory.delete(recursive: true);
        }

        on FileSystemException catch(error, stackTrace) {
          LogWriter.logFatal(
            message: "There was a FileSystemException while trying to clear all baselines for the $robotName robot. "
            "The app will exit to avoid loosing data.",
            error: error,
            stackTrace: stackTrace
          );

          exit(1);
        }
        _dataCache[robotName]?.clear();
        LogWriter.logDebug(message: "Robot baselines and cache cleared successfully.");
      }

      else {
        LogWriter.logDebug(message: "The robot ($robotName)s data folder does not exist, so there are no baselines to delete.");
      }
    }

    else {
      LogWriter.logDebug(message: "robotName was null, so there are no baselines to delete.");
    }
  }

  static Future<void> writeJson({
    required final String? robotName,
    required final int? testType,
    required final int graphID,
    required final Map<int, List<double>> jsonData
  }) async {
    if ((robotName != null) && (testType != null)) {
      LogWriter.logDebug(message: "Writing a json file to the disk...");

      try {
        final File jsonFile = await File(join(_dataDirectory!.path, robotName, "test-$testType", "graph-$graphID.json")).create(recursive: true);

        // Converting the keys to `String`s because jsonEncode will throw an exception otherwise.
        final Map<String, List<double>> formattedJsonData = jsonData.map((final int key, final List<double> value) => MapEntry(key.toString(), value));
        await jsonFile.writeAsString(jsonEncode(formattedJsonData));
      }

      on FileSystemException catch(error, stackTrace) {
        LogWriter.logError(
          message: "FileSystemException while writing to a json file. This is most likely due to incorrect write permissions. "
          "The app will exit so the user is aware of the incorrect permissions.",
          error: error,
          stackTrace: stackTrace
        );

        exit(1);
      }

      _cacheJsonData(robotName: robotName, testType: testType, graphID: graphID, jsonData: jsonData);
      LogWriter.logDebug(message: "Json file written successfully.");
    }

    else {
      LogWriter.logDebug(message: "robotName ($robotName) or testType ($testType) were invalid, so the jsonData was not written to the disk.");
    }
  }

  static Future<Map<int, List<double>>> readJson({
    required final String? robotName,
    required final int? testType,
    required final int graphID
  }) async {
    if ((robotName != null) && (testType != null)) {
      LogWriter.logDebug(message: "Reading json data...");

      // Checking if the data is already available from the [_dataCache].
      Map<int, List<double>>? jsonData = _dataCache[robotName]?[testType]?[graphID];

      if (jsonData != null) {
        LogWriter.logInfo(message: "Json data read from the _dataCache.");
      }

      else {
        LogWriter.logInfo(message: "Reading data from the disk...");

        final File jsonFile = File(join(_dataDirectory!.path, robotName, "test-$testType", "graph-$graphID.json"));

        if (await jsonFile.exists()) {
          jsonData = await _readJsonFile(jsonFile);
        }

        _cacheJsonData(robotName: robotName, testType: testType, graphID: graphID, jsonData: jsonData ?? {});
        LogWriter.logDebug(message: "Json data read successfully.");
      }

      return jsonData ?? {};
    }

    else {
      LogWriter.logDebug(message: "robotName ($robotName) or testType ($testType) were invalid, so the app is assuming the data is an empty Map.");
      return {};
    }
  }

  static Future<Map<int, List<double>>> _readJsonFile(final File jsonFile) async {
    Map<int, List<double>> jsonData = {};

    try {
      final String jsonString = await jsonFile.readAsString();
      if (jsonString.isEmpty) return {};

      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      jsonData = jsonMap.map((final String key, final dynamic value) => MapEntry(int.parse(key), _mapJsonValuesToList(value)));
    }

    catch(error, stackTrace) {
      LogWriter.logError(
        message: "Error or Exception while reading a json file. The program will assume the contents "
        "of the file are an empty Map, which will cause the file to be overwritten.",
        error: error,
        stackTrace: stackTrace
      );

      jsonData = {};
    }

    return jsonData;
  }

  static void _cacheJsonData({
    required final String robotName,
    required final int testType,
    required final int graphID,
    required final Map<int, List<double>> jsonData
  }) {
    _dataCache[robotName] ??= {};
    _dataCache[robotName]![testType] ??= {};
    _dataCache[robotName]![testType]![graphID] = jsonData;
  }

  static List<double> _mapJsonValuesToList(final List<dynamic> jsonList) {
    return jsonList.map((final dynamic value) => double.parse(value.toString())).toList();
  }
}
