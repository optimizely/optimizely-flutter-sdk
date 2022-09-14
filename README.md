# Optimizely Flutter SDK
[![Apache 2.0](https://img.shields.io/github/license/nebula-plugins/gradle-extra-configurations-plugin.svg)](http://www.apache.org/licenses/LICENSE-2.0)
[![Build Status](https://github.com/optimizely/optimizely-flutter-sdk/actions/workflows/flutter.yml/badge.svg?branch=master)](https://github.com/optimizely/optimizely-flutter-sdk/actions)
[![Pub](https://img.shields.io/pub/v/optimizely_flutter_sdk.svg)](https://pub.dev/packages/optimizely_flutter_sdk)

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

## Getting Started

### Using the SDK
Refer to the [Flutter SDK developer documentation](https://docs.developers.optimizely.com/experimentation/v4.0.0-full-stack/docs/install-sdk-flutter) for instructions on getting started with using the SDK.

### Requirements

See the [pubspec.yaml](https://github.com/optimizely/optimizely-flutter-sdk/blob/master/pubspec.yaml) file for Flutter version requirements.

On the Android platform, the SDK requires a minimum SDK version of 21.

On the iOS platform, the SDK requires a minimum version of 10.0.

Other Flutter platforms are not currently supported by this SDK.

### Installing the SDK

To add the flutter-sdk to your project dependencies, include the following in your app's pubspec.yaml:

```
   optimizely_flutter_sdk: ^1.0.0
```

Then, import the package in your application code:

```
   import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';
```

### Samples

A sample code for SDK initialization and experiments:

```
   var flutterSDK = OptimizelyFlutterSdk("my_sdk_key");
   var response = await flutterSDK.initializeClient();
```

## Testing in Terminal

1. To run [unit tests](https://docs.flutter.dev/cookbook/testing/unit/introduction) using terminal, simply use the following command:
`flutter test test/optimizely_flutter_sdk_test.dart`
