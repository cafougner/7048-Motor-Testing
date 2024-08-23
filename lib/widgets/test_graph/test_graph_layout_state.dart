import "package:flutter/material.dart";

import "package:frc_7048_motor_testing/resources/json_interface.dart";
import "package:frc_7048_motor_testing/resources/log_writer.dart";
import "package:frc_7048_motor_testing/resources/preferences.dart";

/// State management for the [TestGraphLayout] with getters and setters.
class TestGraphLayoutState extends ChangeNotifier {
  factory TestGraphLayoutState() => _instance;
  TestGraphLayoutState._();

  static final TestGraphLayoutState _instance = TestGraphLayoutState._();

  Map<int, Map<int, List<double>>> _testResults = {};
  Map<int, Map<int, List<double>>> get testResults => _testResults;
  set testResults(final Map<int, Map<int, List<double>>> newTestResults) {
    if (newTestResults != _testResults) {
      _testResults = newTestResults;
      _scheduleBaselineUpdate();

      LogWriter.logDebug(message: "_testResults updated successfully.");
    }
  }

  int? _testResultsKey;
  int? get testResultsKey => _testResultsKey;
  set testResultsKey(final int? newTestResultsKey) {
    if (newTestResultsKey != _testResultsKey) {
      _testResultsKey = newTestResultsKey;
    }
  }

  Map<int, Map<int, List<double>>> _baselineResults = {};
  Map<int, Map<int, List<double>>> get baselineResults => _baselineResults;

  Map<int, String> _graphNames = {};
  Map<int, String> get graphNames => _graphNames;
  set graphNames(final Map<int, String> newGraphNames) {
    if (newGraphNames != _graphNames) {
      _graphNames = newGraphNames;
      _scheduleNotifyingListeners();

      LogWriter.logDebug(message: "_graphNames updated successfully.");
    }
  }

  Map<int, String> _motorNames = {};
  Map<int, String> get motorNames => _motorNames;
  set motorNames(final Map<int, String> newMotorNames) {
    if (newMotorNames != _motorNames) {
      _motorNames = newMotorNames;
      _scheduleNotifyingListeners();

      LogWriter.logDebug(message: "_motorNames updated successfully.");
    }
  }

  String? _robotName;
  String? get robotName => _robotName;
  set robotName(final String? newRobotName) {
    if (newRobotName != _robotName) {
      _robotName = newRobotName;

      LogWriter.logDebug(message: "_robotName updated successfully.");
    }
  }

  double _graphYRange = Preferences.graphYRange;
  double get graphYRange => _graphYRange;
  set graphYRange(final double newGraphYRange) {
    if (newGraphYRange != _graphYRange) {
      _graphYRange = newGraphYRange;
      _scheduleNotifyingListeners();

      LogWriter.logDebug(message: "_graphYRange updated successfully.");
    }
  }

  int _graphQuality = Preferences.graphQuality;
  int get graphQuality => _graphQuality;
  set graphQuality(final int newGraphQuality) {
    if (newGraphQuality != _graphQuality) {
      _graphQuality = newGraphQuality;
      _scheduleNotifyingListeners();

      LogWriter.logDebug(message: "_graphQuality updated successfully.");
    }
  }

  bool _graphTouchData = Preferences.graphTouchData;
  bool get graphTouchData => _graphTouchData;
  set graphTouchData(final bool newGraphTouchData) {
    if (newGraphTouchData != _graphTouchData) {
      _graphTouchData = newGraphTouchData;
      _scheduleNotifyingListeners();

      LogWriter.logDebug(message: "_graphTouchData updated successfully.");
    }
  }

  bool _expandGraphs = Preferences.expandGraphs;
  bool get expandGraphs => _expandGraphs;
  set expandGraphs(final bool newExpandGraphs) {
    if (newExpandGraphs != _expandGraphs) {
      _expandGraphs = newExpandGraphs;
      _scheduleNotifyingListeners();

      LogWriter.logDebug(message: "_expandGraphs updated successfully.");
    }
  }

  bool _baselineUpdateScheduled = false;

  void _scheduleBaselineUpdate() async {
    if (!_baselineUpdateScheduled) {
      LogWriter.logDebug(message: "Updating baselines...");
      _baselineUpdateScheduled = true;

      // await Future<void>.delayed(const Duration(milliseconds: 20));
      final List<Map<int, List<double>>> futureBaselines = await Future.wait([
        JsonInterface.readJson(robotName: _robotName, testType: _testResultsKey, graphID: 1),
        JsonInterface.readJson(robotName: _robotName, testType: _testResultsKey, graphID: 2),
        JsonInterface.readJson(robotName: _robotName, testType: _testResultsKey, graphID: 3),
        JsonInterface.readJson(robotName: _robotName, testType: _testResultsKey, graphID: 4),
        JsonInterface.readJson(robotName: _robotName, testType: _testResultsKey, graphID: 5),
        JsonInterface.readJson(robotName: _robotName, testType: _testResultsKey, graphID: 6)
      ]);

      final Map<int, Map<int, List<double>>> mappedBaselines = {};
      mappedBaselines[1] = futureBaselines[0];
      mappedBaselines[2] = futureBaselines[1];
      mappedBaselines[3] = futureBaselines[2];
      mappedBaselines[4] = futureBaselines[3];
      mappedBaselines[5] = futureBaselines[4];
      mappedBaselines[6] = futureBaselines[5];

      for (int i = 1; i <= 6; i++) {
        if (_testResults[i]?.length != mappedBaselines[i]?.length && _testResults[i] != null) {
          LogWriter.logDebug(message: "Invalid baseline length for graph $i, this will be overwitten.");

          mappedBaselines[i] = _testResults[i]!;
          JsonInterface.writeJson(robotName: _robotName, testType: _testResultsKey, graphID: i, jsonData: _testResults[i]!); // ignore: unawaited_futures

          LogWriter.logDebug(message: "Baseline overwritten.");
        }
      }

      _baselineResults = mappedBaselines;
      _scheduleNotifyingListeners();

      _baselineUpdateScheduled = false;
      LogWriter.logDebug(message: "Baselines updated.");
    }

    else {
      LogWriter.logDebug(message: "Attempted to schedule an update for the baselines while one was already scheduled.");
    }
  } 

  bool _listenerNotificationScheduled = false;

  void _scheduleNotifyingListeners() async {
    if (!_listenerNotificationScheduled) {
      LogWriter.logDebug(message: "Scheduling TestGraphLayout update...");
      _listenerNotificationScheduled = true;

      await Future<void>.delayed(const Duration(milliseconds: 5));
      notifyListeners();

      _listenerNotificationScheduled = false;
      LogWriter.logDebug(message: "TestGraphLayout updated.");
    }

    else {
      LogWriter.logDebug(message: "Attempted to schedule an update for the TestGraphLayout while one was already scheduled.");
    }
  }

  Future<void> clearAllBaselineResults() async {
    await JsonInterface.clearRobotBaselines(_robotName);
    setBaselineResultsAsCurrent();
  }

  void setBaselineResultsAsCurrent() {
    LogWriter.logDebug(message: "Updating baselines to the current _testResults...");

    for (int i = 1; i <= 6; i++) {
      JsonInterface.writeJson(robotName: _robotName, testType: _testResultsKey, graphID: i, jsonData: _testResults[i] ?? {}); // ignore: discarded_futures
    }

    _baselineResults = _testResults;
    _scheduleNotifyingListeners();

    LogWriter.logDebug(message: "Baselines updated successfully.");
  }
}
