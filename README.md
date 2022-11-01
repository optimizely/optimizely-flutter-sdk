# Optimizely Flutter SDK
[![Apache 2.0](https://img.shields.io/github/license/nebula-plugins/gradle-extra-configurations-plugin.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![Build Status](https://github.com/optimizely/optimizely-flutter-sdk/actions/workflows/flutter.yml/badge.svg?branch=master)](https://github.com/optimizely/optimizely-flutter-sdk/actions)
[![Pub](https://img.shields.io/pub/v/optimizely_flutter_sdk.svg)](https://pub.dev/packages/optimizely_flutter_sdk)
[![Coverage Status](https://coveralls.io/repos/github/optimizely/optimizely-flutter-sdk/badge.svg?branch=master)](https://coveralls.io/github/optimizely/optimizely-flutter-sdk?branch=master)

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

## Getting Started

### Using the SDK
Refer to the [Flutter SDK developer documentation](https://docs.developers.optimizely.com/experimentation/v4.0.0-full-stack/docs/install-sdk-flutter) for instructions on getting started with using the SDK.

### Requirements

See the [pubspec.yaml](https://github.com/optimizely/optimizely-flutter-sdk/blob/master/pubspec.yaml) file for Flutter version requirements.

On the Android platform, the SDK requires a minimum SDK version of 14 or higher and compile SDK version of 32.

On the iOS platform, the SDK requires a minimum version of 10.0.

Other Flutter platforms are not currently supported by this SDK.

### Installing the SDK

To add the flutter-sdk to your project dependencies, include the following in your app's pubspec.yaml:

```
   optimizely_flutter_sdk: ^1.0.0-beta
```

Then, import the package in your application code:

```
   import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';
```

## Usage

### Instantiation

A sample code for SDK initialization:

```
   var flutterSDK = OptimizelyFlutterSdk("my_sdk_key");
   var response = await flutterSDK.initializeClient();
```

### Feature Rollouts
```
   import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';

   // Also supports eventOptions, datafilePeriodicDownloadInterval, datafileHostOptions and defaultDecideOptions
   var flutterSDK = OptimizelyFlutterSdk("my_sdk_key");

   // instantiate a client
   var response = await flutterSDK.initializeClient();

   // User attributes are optional and used for targeting and results segmentation
   var attributes = {
      "state": "California",
      "likes_donuts": true
   };
   var user = await flutterSDK.createUserContext("optimizely end user", attributes);
   var decideReponse = await user!.decide("binary_feature");
```

## Testing in Terminal

1. To run [unit tests](https://docs.flutter.dev/cookbook/testing/unit/introduction) using terminal, simply use the following command:
`flutter test test/optimizely_flutter_sdk_test.dart`
