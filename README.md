# Optimizely Flutter SDK
[![Pub Version](https://img.shields.io/pub/v/optimizely_flutter_sdk?color=blueviolet)](https://pub.dev/packages/optimizely_flutter_sdk)
[![Pub](https://img.shields.io/pub/v/optimizely_flutter_sdk.svg)](https://pub.dev/packages/optimizely_flutter_sdk)
[![Apache 2.0](https://img.shields.io/github/license/nebula-plugins/gradle-extra-configurations-plugin.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![Build Status](https://github.com/optimizely/optimizely-flutter-sdk/actions/workflows/flutter.yml/badge.svg?branch=master)](https://github.com/optimizely/optimizely-flutter-sdk/actions)
[![Coverage Status](https://coveralls.io/repos/github/optimizely/optimizely-flutter-sdk/badge.svg?branch=master)](https://coveralls.io/github/optimizely/optimizely-flutter-sdk?branch=master)

This repository houses the Flutter SDK for use with Optimizely Feature Experimentation and Optimizely Full Stack (legacy).

Optimizely Feature Experimentation is an A/B testing and feature management tool for product development teams that enables you to experiment at every step. Using Optimizely Feature Experimentation allows for every feature on your roadmap to be an opportunity to discover hidden insights. Learn more at [Optimizely.com](https://www.optimizely.com/products/experiment/feature-experimentation/), or see the [developer documentation](https://docs.developers.optimizely.com/experimentation/v4.0.0-full-stack/docs/welcome).

Optimizely Rollouts is [free feature flags](https://www.optimizely.com/free-feature-flagging/) for development teams. You can easily roll out and roll back features in any application without code deploys, mitigating risk for every feature on your roadmap.

## Get Started

Refer to the [Flutter SDK's developer documentation](https://docs.developers.optimizely.com/experimentation/v4.0.0-full-stack/docs/flutter-sdk) for detailed instructions on getting started with using the SDK.

### Requirements

See the [pubspec.yaml](https://github.com/optimizely/optimizely-flutter-sdk/blob/master/pubspec.yaml) file for Flutter version requirements.

On the Android platform, the SDK requires a minimum SDK version of 21 or higher and compile SDK version of 32.

On the iOS platform, the SDK requires a minimum version of 10.0.

Other Flutter platforms are not currently supported by this SDK.

### Install the SDK

To add the flutter-sdk to your project dependencies, include the following in your app's pubspec.yaml:

```
   optimizely_flutter_sdk: ^3.1.0
```

Then run 

```bash
   flutter pub get
```

## Use the Flutter SDK

### Initialization

Import the package in your application code:

```dart
   import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';
```

Instantiate the SDK, adding your SDK Key and initializing the client:

```dart
   var flutterSDK = OptimizelyFlutterSdk("your_sdk_key");
   var response = await flutterSDK.initializeClient();
```

### Feature Rollouts
```dart
   import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';

   // Also supports eventOptions, datafilePeriodicDownloadInterval, datafileHostOptions and defaultDecideOptions
   var flutterSDK = OptimizelyFlutterSdk("your_sdk_key");

   var response = await flutterSDK.initializeClient();

   // User attributes are optional and used for targeting and results segmentation
   var attributes = {
      "state": "California",
      "likes_donuts": true
   };
   var user = await flutterSDK.createUserContext("user_id", attributes);
   var decideReponse = await user!.decide("binary_feature");
```

## SDK Development

### Unit Tests

To run [unit tests](https://docs.flutter.dev/cookbook/testing/unit/introduction) using terminal, simply use the following command:

```bash
flutter test test/optimizely_flutter_sdk_test.dart
```

### Contributing

Please see [CONTRIBUTING](CONTRIBUTING.md).

### Other Optimizely SDKs

- Agent - https://github.com/optimizely/agent

- Android - https://github.com/optimizely/android-sdk

- C# - https://github.com/optimizely/csharp-sdk

- Flutter - https://github.com/optimizely/optimizely-flutter-sdk

- Go - https://github.com/optimizely/go-sdk

- Java - https://github.com/optimizely/java-sdk

- JavaScript - https://github.com/optimizely/javascript-sdk

- PHP - https://github.com/optimizely/php-sdk

- Python - https://github.com/optimizely/python-sdk

- React - https://github.com/optimizely/react-sdk

- Ruby - https://github.com/optimizely/ruby-sdk

- Swift - https://github.com/optimizely/swift-sdk
