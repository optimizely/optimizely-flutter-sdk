# Optimizely Flutter SDK
[![Apache 2.0](https://img.shields.io/github/license/nebula-plugins/gradle-extra-configurations-plugin.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![Build Status](https://github.com/optimizely/optimizely-flutter-sdk/actions/workflows/flutter.yml/badge.svg?branch=master)](https://github.com/optimizely/optimizely-flutter-sdk/actions)
[![Pub](https://img.shields.io/pub/v/optimizely_flutter_sdk.svg)](https://pub.dev/packages/optimizely_flutter_sdk)
[![Coverage Status](https://coveralls.io/repos/github/optimizely/optimizely-flutter-sdk/badge.svg?branch=master)](https://coveralls.io/github/optimizely/optimizely-flutter-sdk?branch=master)

This repository houses the Flutter SDK for use with Optimizely Feature Experimentation and Optimizely Full Stack (legacy).

Optimizely Feature Experimentation is an A/B testing and feature management tool for product development teams that enables you to experiment at every step. Using Optimizely Feature Experimentation allows for every feature on your roadmap to be an opportunity to discover hidden insights. Learn more at [Optimizely.com](https://www.optimizely.com/products/experiment/feature-experimentation/), or see the [developer documentation](https://docs.developers.optimizely.com/experimentation/v4.0.0-full-stack/docs/welcome).

Optimizely Rollouts is [free feature flags](https://www.optimizely.com/free-feature-flagging/) for development teams. You can easily roll out and roll back features in any application without code deploys, mitigating risk for every feature on your roadmap.

## Get Started

Refer to the [Flutter SDK's developer documentation](https://docs.developers.optimizely.com/experimentation/v4.0.0-full-stack/docs/flutter-sdk) for detailed instructions on getting started with using the SDK.

### Requirements

See the [pubspec.yaml](https://github.com/optimizely/optimizely-flutter-sdk/blob/master/pubspec.yaml) file for Flutter version requirements.

On the Android platform, the SDK requires a minimum SDK version of 14 or higher and compile SDK version of 32.

On the iOS platform, the SDK requires a minimum version of 10.0.

Other Flutter platforms are not currently supported by this SDK.

### Install the SDK

### Packages

To add the flutter-sdk to your project dependencies, include the following in your app's pubspec.yaml:

```
   optimizely_flutter_sdk: ^1.0.1-beta
```

Then run 

```
flutter pub get
```

### Configuration options

{{ List any configuration options, if the SDK has any (for example, Agent's configuration can be overwritten by a yaml config file) }}

## Use the Flutter SDK

A sample code for SDK initialization:

```
   var flutterSDK = OptimizelyFlutterSdk("my_sdk_key");
   var response = await flutterSDK.initializeClient();
```

### Initialization

Then, import the package in your application code:

```
   import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';
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

## SDK Development

### Unit Tests

1. To run [unit tests](https://docs.flutter.dev/cookbook/testing/unit/introduction) using terminal, simply use the following command:
`flutter test test/optimizely_flutter_sdk_test.dart`

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
