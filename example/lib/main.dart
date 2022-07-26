import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String optimizelyConfig = 'Unknown';

  @override
  void initState() {
    super.initState();
    runOptimizelySDK();
  }

  Future<void> runOptimizelySDK() async {
    var flutterSDK = OptimizelyFlutterSdk("X9mZd2WDywaUL9hZXyh9A");
    var response = await flutterSDK.initializeClient();

    setState(() {
      optimizelyConfig = json.encode(response);
    });

    var rng = Random();
    var randomUserName = "${rng.nextInt(1000)}";

    // Create user context
    response = await flutterSDK.createUserContext(randomUserName);

    // Set attributes
    response = await flutterSDK.setAttributes({
      "age": 5,
      "doubleValue": 12.12,
      "boolValue": false,
      "stringValue": "121"
    });

    // To add decide listener
    var cancelDecideListener =
        await flutterSDK.addDecisionNotificationListener((notification) {
      print(notification);
      print("decide notification received");
    });

    // Decide call
    response = await flutterSDK.decide('flag1');

    // should return following response without forced decision
    // flagKey: flag1
    // ruleKey: default-rollout-7371-20896892800
    // variationKey: off

    // Setting forced decision
    flutterSDK.setForcedDecision("flag1", "flag1_experiment", "variation_a");

    // Decide call
    response = await flutterSDK.decide('flag1');

    // should return following response with forced decision
    // flagKey: flag1
    // ruleKey: flag1_experiment
    // variationKey: variation_a

    // removing forced decision
    flutterSDK.removeForcedDecision("flag1", "flag1_experiment");

    // Decide call
    response = await flutterSDK.decide('flag1');

    // should return original response without forced decision
    // flagKey: flag1
    // ruleKey: default-rollout-7371-20896892800
    // variationKey: off

    // To cancel decide listener
    // cancelDecideListener();

    // To add track listener
    var cancelTrackListener =
        await flutterSDK.addTrackNotificationListener((notification) {
      print(notification);
      print("track notification received");
    });

    // Track call
    response = await flutterSDK.trackEvent("myevent", {
      "age": 20,
      "doubleValue": 12.12,
      "boolValue": false,
      "stringValue": "121"
    });

    // To cancel track listener
    // cancelTrackListener();

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('OptimizelyConfig: $optimizelyConfig'),
        ),
      ),
    );
  }
}
