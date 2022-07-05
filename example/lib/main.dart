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
    Map<String, TypedValue> attributes = {"age": TypedValue(20, ValueType.int)};
    response = await flutterSDK.createUserContext(randomUserName, attributes);

    // To add decide listener
    var cancelDecideListener =
        await flutterSDK.addNotificationListener((notification) {
      print(notification);
      print("decide notification received");
    }, ListenerType.decision);

    // Decide call
    response = await flutterSDK.decide('flag1');

    // To cancel decide listener
    // cancelDecideListener();

    // To add track listener
    var cancelTrackListener =
        await flutterSDK.addNotificationListener((notification) {
      print(notification);
      print("track notification received");
    }, ListenerType.track);

    // Track call
    response = await flutterSDK.trackEvent("myevent");

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
