import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';
import 'package:optimizely_flutter_sdk_example/custom_logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String uiResponse = 'Unknown';

  @override
  void initState() {
    super.initState();
    runOptimizelySDK();
  }

  Future<void> runOptimizelySDK() async {
    Set<OptimizelyDecideOption> defaultOptions = {
      OptimizelyDecideOption.includeReasons,
      OptimizelyDecideOption.excludeVariables
    };

    final customLogger = CustomLogger();

    var flutterSDK = OptimizelyFlutterSdk(
      "X9mZd2WDywaUL9hZXyh9A",
      datafilePeriodicDownloadInterval: 10 * 60,
      eventOptions: const EventOptions(
          batchSize: 1, timeInterval: 60, maxQueueSize: 10000),
      defaultLogLevel: OptimizelyLogLevel.debug,
      defaultDecideOptions: defaultOptions,
      logger: customLogger,
    );
    var response = await flutterSDK.initializeClient();

    setState(() {
      uiResponse = "[Optimizely] Client initialized: ${response.success} ";
    });

    var rng = Random();
    var randomUserName = "${rng.nextInt(1000)}";

    // Create user context
    var userContext =
        await flutterSDK.createUserContext(userId: randomUserName);

    // Set attributes
    response = await userContext!.setAttributes({
      "age": 5,
      "doubleValue": 12.12,
      "boolValue": false,
      "stringValue": "121"
    });

    // Add decide listener
    var decideListenerId =
        await flutterSDK.addDecisionNotificationListener((notification) {
      print("Parsed decision event ....................");
      print(notification.type);
      print(notification.userId);
      print(notification.decisionInfo);
      print("decide notification received");
    });

    Set<OptimizelyDecideOption> options = {
      OptimizelyDecideOption.ignoreUserProfileService,
    };

    // Decide call
    var decideResponse = await userContext.decide('flag1', options);
    uiResponse +=
        "\nFirst decide call variationKey: ${decideResponse.decision!.variationKey}";

    // Set forced decision
    await userContext.setForcedDecision(
        OptimizelyDecisionContext("flag1", "flag1_experiment"),
        OptimizelyForcedDecision("variation_a"));

    // Decide call
    decideResponse = await userContext.decide('flag1');
    uiResponse +=
        "\nSecond decide call variationKey: ${decideResponse.decision!.variationKey}";

    // removing forced decision
    await userContext.removeForcedDecision(
        OptimizelyDecisionContext("flag1", "flag1_experiment"));

    // Decide call
    decideResponse = await userContext.decide('flag1');
    uiResponse +=
        "\nThird decide call variationKey: ${decideResponse.decision!.variationKey}";

    setState(() {
      uiResponse = uiResponse;
    });

    // To add track listener
    var trackListenerID =
        await flutterSDK.addTrackNotificationListener((notification) {
      print("Parsed track event ....................");
      print(notification.attributes);
      print(notification.eventKey);
      print("track notification received");
    });

    // To add logEvent listener
    var logEventListenerId =
        await flutterSDK.addLogEventNotificationListener((notification) {
      print("Parsed log event ....................");
      print(notification.url);
      print(notification.params);
      print("log event notification received");
    });

    // Track call with nested objects
    response = await userContext.trackEvent("myevent", {
      "revenue": 99.99,
      "user": {
        "id": "user123",
        "premium": true,
        "tags": ["vip", "loyal"]
      },
      "items": [
        {"name": "Product A", "quantity": 2, "price": 49.99},
        {"name": "Product B", "quantity": 1, "price": 50.00}
      ],
      "metadata": {"source": "mobile_app", "platform": "ios"}
    });

    // To cancel track listener
    await flutterSDK.removeNotificationListener(trackListenerID);

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
          child: Text(uiResponse),
        ),
      ),
    );
  }
}
