import "dart:async";

import "package:flutter/material.dart";

import "package:frc_7048_motor_testing/resources/log_writer.dart";
import "package:frc_7048_motor_testing/resources/nt/nt_parser.dart";
import "package:frc_7048_motor_testing/resources/preferences.dart";
import "package:frc_7048_motor_testing/widgets/test_graph/test_graph_layout_state.dart";

import "package:nt4/nt4.dart";

/// A static interface for an [NT4Client] to communicate to and from the connected robot.
class NTInterface {
  static NT4Client? _client;
  static const NT4SubscriptionOptions _subcriptionOptions = NT4SubscriptionOptions();

  static final TestGraphLayoutState _testGraphLayoutState = TestGraphLayoutState();

  static NT4Topic? _dartTestType;
  static NT4Topic? _dartTestSignal;
  static NT4Subscription? _robotTestTypes;
  static NT4Subscription? _robotTestStatus;

  static NT4Subscription? _robotName;
  static NT4Subscription? _robotTestType;

  static NT4Subscription? _robotMotorNames;
  static NT4Subscription? _robotGraphNames;
  static NT4Subscription? _robotTestResults;

  static final ValueNotifier<bool> connectionNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<String> testStatusNotifier = ValueNotifier<String>("Waiting");
  static final ValueNotifier<Map<int, String>> testTypesNotifier = ValueNotifier<Map<int, String>>({});

  static int? selectedTestType;

  static void ensureInitialized() {
    LogWriter.logDebug(message: "Initializing NTInterface...");

    if (_client == null) {
      _client = NT4Client(
        serverBaseAddress: Preferences.ntHost,

        onConnect: () {
          connectionNotifier.value = true;
          LogWriter.logDebug(message: "_client connected.");
        },

        onDisconnect: () {
          connectionNotifier.value = false;
          LogWriter.logDebug(message: "_client disconnected.");
        },

        clientName: "Frc7048MotorTesting"
      );

      _createTopics();
      _createSubscribers();

      LogWriter.logInfo(message: "NTInterface initialized.");
    }

    else {
      LogWriter.logDebug(message: "NTInterface has already been initialized.");
    }
  }

  static void _createTopics() {
    LogWriter.logDebug(message: "Creating _client topics...");

    _dartTestType = _client!.publishNewTopic("/FRC7048MotorTesting/.dart/TestType", NT4TypeStr.typeInt);
    _dartTestSignal = _client!.publishNewTopic("/FRC7048MotorTesting/.dart/TestSignal", NT4TypeStr.typeBool);

    LogWriter.logDebug(message: "_client topics created successfully.");
  }

  static void _createSubscribers() {
    LogWriter.logDebug(message: "Creating _client subscribers and listeners.");

    _robotTestTypes = _client!.subscribe("/FRC7048MotorTesting/.robot/TestTypes", _subcriptionOptions);
    _robotTestStatus = _client!.subscribe("/FRC7048MotorTesting/.robot/TestStatus", _subcriptionOptions);

    _robotName = _client!.subscribe("/FRC7048MotorTesting/.robot/Name", _subcriptionOptions);
    _robotTestType = _client!.subscribe("/FRC7048MotorTesting/.robot/.data/TestType", _subcriptionOptions);

    _robotMotorNames = _client!.subscribe("/FRC7048MotorTesting/.robot/MotorNames", _subcriptionOptions);
    _robotGraphNames = _client!.subscribe("/FRC7048MotorTesting/.robot/.data/GraphNames", _subcriptionOptions);
    _robotTestResults = _client!.subscribe("/FRC7048MotorTesting/.robot/.data/TestResults", _subcriptionOptions);

    _robotTestTypes!.listen((final data) => testTypesNotifier.value = NTParser.parseIntStringMapString(data));
    _robotTestStatus!.listen((final data) => testStatusNotifier.value = data.toString());

    _robotName!.listen((final data) {
      if (data == null) _testGraphLayoutState.robotName = null;
      _testGraphLayoutState.robotName = data.toString();
    });

    _robotTestType!.listen((final data) => _testGraphLayoutState.testResultsKey = int.parse(data.toString()));

    _robotMotorNames!.listen((final data) => _testGraphLayoutState.motorNames = NTParser.parseIntStringMapString(data));
    _robotGraphNames!.listen((final data) => _testGraphLayoutState.graphNames = NTParser.parseIntStringMapString(data));
    _robotTestResults!.listen((final data) => _testGraphLayoutState.testResults = NTParser.parseResultsMapString(data));

    LogWriter.logDebug(message: "_client subscribers and listeners created successfully.");
  }

  static void updateNTHost() {
    LogWriter.logDebug(message: "Updating NTInterface serverBaseAddress...");

    if (_client != null) {
      // I'm pretty sure this is a memory leak, but its faster to connect than _client!.setServerBaseAddress() (~15 seconds).
      connectionNotifier.value = false;

      try {
        // This WILL throw an error.
        _client!.setServerBaseAddress("");
      }

      catch(_, __) {}

      _client = null;
      ensureInitialized();

      LogWriter.logDebug(message: "_client with the new serverBaseAddress created successfully.");
    }

    else {
      LogWriter.logDebug(message: "NTInterface does not have a client, so no serverBaseAddress was changed.");
    }
  }

  static Future<void> sendTestSignal() async {
    LogWriter.logDebug(message: "Sending test signal...");

    Future<void> testRunning() async {
      final Completer<void> completer = Completer<void>();

      void listener() {
        if (testStatusNotifier.value == "Running") {
          testStatusNotifier.removeListener(listener);
          completer.complete();
        }
      }

      testStatusNotifier.addListener(listener);
      await completer.future;
    }

    if (selectedTestType != null) {
      testStatusNotifier.value = "Starting";

      // If a test signal is sent while it is already true, it wont change, so the listener wont run the test.
      // This makes it so if it is true for some reason, it will set it to false and then to true again.
      if (NTParser.parseBoolString(_client!.getLastAnnouncedValueByTopic(_dartTestSignal!))) {
        LogWriter.logDebug(message: "Test signal was already true, setting to false...");
        _client!.addSample(_dartTestSignal!, false);
      }

      _client!.addSample(_dartTestType!, selectedTestType);
      _client!.addSample(_dartTestSignal!, true);

      await testRunning();

      _client!.addSample(_dartTestSignal!, false);

      LogWriter.logDebug(message: "Test signal sent successfully.");
    }
  }
}
