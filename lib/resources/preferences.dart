import "package:flutter/foundation.dart";

import "package:frc_7048_motor_testing/resources/log_writer.dart";
import "package:frc_7048_motor_testing/resources/nt/nt_interface.dart";
import "package:frc_7048_motor_testing/resources/utils/ipv4_utils.dart";
import "package:frc_7048_motor_testing/widgets/test_graph/test_graph_layout_state.dart";

import "package:shared_preferences/shared_preferences.dart";

/// A static interface to a [SharedPreferencesWithCache] instance to save and load values with getters and setters.
class Preferences {
  static SharedPreferencesWithCache? _prefs;
  static const SharedPreferencesWithCacheOptions _cacheOptions = SharedPreferencesWithCacheOptions(
    allowList: {_Key.ntHost, _Key.graphYRange, _Key.graphQuality, _Key.graphTouchData, _Key.expandGraphs}
  );

  static final TestGraphLayoutState _testGraphLayoutState = TestGraphLayoutState();

  static Future<void> ensureInitialized() async {
    LogWriter.logDebug(message: "Initializing Preferences...");

    if (_prefs == null) {
      _prefs = await SharedPreferencesWithCache.create(cacheOptions: _cacheOptions);
      _initializePreferences();

      LogWriter.logInfo(
        message: "Preferences initialized.\n"
        "${_Key.ntHost} preference: $_ntHost\n"
        "${_Key.graphYRange} preference: $_graphYRange\n"
        "${_Key.graphQuality} preference: $_graphQuality\n"
        "${_Key.graphTouchData} preference: $_graphTouchData\n"
        "${_Key.expandGraphs} preference: $_expandGraphs"
      );
    }

    else {
      LogWriter.logDebug(message: "Preferences has already been initialized.");
    }
  }

  static void _initializePreferences() {
    // Since the setters for the preferences will save to the disk when a different and valid valid is given, the nullable results
    // from _prefs!.get are used first. If the preference has not been saved before, it will be null. When the initial value (from the function)
    // is passed to the setter, since it is a new value, it will be saved to the disk. If it has already been saved, both of the values will match and will not change.
    LogWriter.logDebug(message: "Reading stored preferences...");
    _ntHost = _prefs!.getString(_Key.ntHost);
    _graphYRange = _prefs!.getDouble(_Key.graphYRange);
    _graphQuality = _prefs!.getInt(_Key.graphQuality);
    _graphTouchData = _prefs!.getBool(_Key.graphTouchData);
    _expandGraphs = _prefs!.getBool(_Key.expandGraphs);

    ntHost = _initialNTHost();
    graphYRange = _initialGraphYRange();
    graphQuality = _initialGraphQuality();
    graphTouchData = _initialGraphTouchData();
    expandGraphs = _initialExpandGraphs();
    LogWriter.logDebug(message: "Stored preferences read successfully.");
  }

  static String? _ntHost;
  static String get ntHost => _ntHost ?? Default.ntHost;
  static set ntHost(final String newNTHost) {
    LogWriter.logDebug(message: "Updating ${_Key.ntHost} preference...");

    if ((newNTHost != _ntHost) && (validIPv4Address(newNTHost))) {
      _ntHost = newNTHost;
      NTInterface.updateNTHost();
      _prefs!.setString(_Key.ntHost, newNTHost); // ignore: discarded_futures

      LogWriter.logInfo(message: "newNTHost ($newNTHost) applied to _ntHost, NTInterface, and _prefs.");
    }

    else {
      LogWriter.logDebug(message: "newNTHost ($newNTHost) was the same as the current _ntHost, so no preferences were changed.");
    }
  }

  static double? _graphYRange;
  static double get graphYRange => _graphYRange ?? Default.graphYRange;
  static set graphYRange(double newGraphYRange) {
    LogWriter.logDebug(message: "Updating ${_Key.graphYRange} preference...");

    newGraphYRange = clampDouble(newGraphYRange, 0.5, 10.0);

    if (newGraphYRange != _graphYRange) {
      _graphYRange = newGraphYRange;
      _testGraphLayoutState.graphYRange = newGraphYRange;
      _prefs!.setDouble(_Key.graphYRange, newGraphYRange); // ignore: discarded_futures

      LogWriter.logInfo(message: "newGraphYRange ($newGraphYRange) applied to _graphYRange, _testGraphLayoutState, and _prefs.");
    }

    else {
      LogWriter.logDebug(message: "newGraphYRange ($newGraphYRange) was the same as the current _graphYRange, so no preferences were changed.");
    }
  }

  static int? _graphQuality;
  /// The quality or resolution of the graphs.
  /// 
  /// When parsing the test results, every point where `i % graphQuality != 0` is skipped.
  static int get graphQuality => _graphQuality ?? Default.graphQuality;
  static set graphQuality(int newGraphQuality) {
    LogWriter.logDebug(message: "Updating ${_Key.graphQuality} preference...");

    newGraphQuality = newGraphQuality.clamp(1, 8);

    if (newGraphQuality != _graphQuality) {
      _graphQuality = newGraphQuality;
      _testGraphLayoutState.graphQuality = newGraphQuality;
      _prefs!.setInt(_Key.graphQuality, newGraphQuality); // ignore: discarded_futures

      LogWriter.logInfo(message: "newGraphQuality ($newGraphQuality) applied to _graphQuality, _testGraphLayoutState, and _prefs.");
    }

    else {
      LogWriter.logDebug(message: "newGraphQuality ($newGraphQuality) was the same as the current _graphQuality, so no preferences were changed.");
    }
  }

  static bool? _graphTouchData;
  /// Whether the touch data should be graphed when mousing over a TestGraph.
  static bool get graphTouchData => _graphTouchData ?? Default.graphTouchData;
  static set graphTouchData(final bool newGraphTouchData) {
    LogWriter.logDebug(message: "Updating ${_Key.graphTouchData} preference...");

    if (newGraphTouchData != _graphTouchData) {
      _graphTouchData = newGraphTouchData;
      _testGraphLayoutState.graphTouchData = newGraphTouchData;
      _prefs!.setBool(_Key.graphTouchData, newGraphTouchData); // ignore: discarded_futures

      LogWriter.logInfo(message: "newGraphTouchData ($newGraphTouchData) applied to _graphTouchData, _testGraphLayoutState, and _prefs.");
    }

    else {
      LogWriter.logDebug(message: "newGraphTouchData ($newGraphTouchData) was the same as the current _graphTouchData, so no preferences were changed.");
    }
  }

  static bool? _expandGraphs;
  /// Whether the TestGraphLayout should expand the TestGraphBuilders to fit the available space.
  static bool get expandGraphs => _expandGraphs ?? Default.expandGraphs;
  static set expandGraphs(final bool newExpandGraphs) {
    LogWriter.logDebug(message: "Updating ${_Key.expandGraphs} preference...");

    if (newExpandGraphs != _expandGraphs) {
      _expandGraphs = newExpandGraphs;
      _testGraphLayoutState.expandGraphs = newExpandGraphs;
      _prefs!.setBool(_Key.expandGraphs, newExpandGraphs); // ignore: discarded_futures

      LogWriter.logInfo(message: "newExpandGraphs ($newExpandGraphs) applied to _expandGraphs, _testGraphLayoutState, and _prefs.");
    }

    else {
      LogWriter.logDebug(message: "newExpandGraphs ($newExpandGraphs) was the same as the current _expandGraphs, so no preferences were changed.");
    }
  }

  static String _initialNTHost() {
    final String? ntHost = _prefs!.getString(_Key.ntHost);
    if (ntHost == null) return Default.ntHost;
    if (validIPv4Address(ntHost)) return ntHost;

    return Default.ntHost;
  }

  static double _initialGraphYRange() {
    final double? graphYRange = _prefs!.getDouble(_Key.graphYRange);
    if (graphYRange == null) return Default.graphYRange;

    return clampDouble(graphYRange, 0.5, 10.0);
  }

  static int _initialGraphQuality() {
    final int? graphQuality = _prefs!.getInt(_Key.graphQuality);
    if (graphQuality == null) return Default.graphQuality;

    return graphQuality.clamp(1, 8);
  }

  static bool _initialGraphTouchData() {
    final bool? graphTouchData = _prefs!.getBool(_Key.graphTouchData);
    if (graphTouchData == null) return Default.graphTouchData;

    return graphTouchData;
  }

  static bool _initialExpandGraphs() {
    final bool? expandGraphs = _prefs!.getBool(_Key.expandGraphs);
    if (expandGraphs == null) return Default.expandGraphs;

    return expandGraphs;
  }
}

class _Key {
  static const String ntHost = "ntHost";
  static const String graphYRange = "graphYRange";
  static const String graphQuality = "graphQuality";
  static const String graphTouchData = "graphTouchData";
  static const String expandGraphs = "expandGraphs";
}

class Default {
  static const String ntHost = "127.0.0.1";
  static const double graphYRange = 8.0;
  static const int graphQuality = 4;
  static const bool graphTouchData = false;
  static const bool expandGraphs = true;
}
