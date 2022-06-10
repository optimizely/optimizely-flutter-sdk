import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

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
    var response =
        await OptimizelyFlutterSdk.initializeClient("X9mZd2WDywaUL9hZXyh9A");
    // print('$response');
    response = await OptimizelyFlutterSdk.getOptimizelyConfig();
    // print('$response');
    // response = await OptimizelyFlutterSdk.createUserContext("1234");
    // print('$response');
    // response = await OptimizelyFlutterSdk.decide(['flag1']);
    // print('$response');
    // response = await OptimizelyFlutterSdk.trackEvent('myevent');
    // print('$response');

    if (!mounted) return;

    setState(() {
      optimizelyConfig = json.encode(response);
    });
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
