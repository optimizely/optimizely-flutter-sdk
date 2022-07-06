# optimizely_flutter_sdk

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

## Getting Started

1. [Install Dart](https://dart.dev/get-dart#install) for your platform.
2. Configure your IDE to point to the Dart SDK directory listed from the installation instructions. <br/> e.g. Windows: C:\tools\dart-sdk
3. [Install Flutter](https://docs.flutter.dev/get-started/install) for your platform.
*Note*: The download is big. Extract using an archive tool if needed. 
4. Ensure your PATH includes the `bin` directory of your Flutter installation. <br/> e.g. Windows: `C:\src\flutter\binC:\src\flutter\bin`
5. For users of IntelliJ, install the following plugins:
   1. Dart by JetBrains 
   2. Flutter by flutter.dev
6. In your IDE and in the path of this repo, open a terminal and run <br/>`flutter packages get`
7. For users of IntelliJ, configure Flutter settings
   1. Go to File > Settings...
      ![](docs/intellij-settings-menu.png)
   2. Configure the Flutter SDK and additional settings
      ![](docs/intellij-settings-flutter.png)

## Testing In IntelliJ

1. Click Edit Configurations... in the Run/Debug configurations menu
   ![](docs/edit-config.png)
2. Click the + button and add a Flutter Test configuration
   ![](docs/add-flutter-test-config.png)
3. Configure the settings for the test run
   ![](docs/flutter-test-config-values.png)
4. Run the test suite to ensure correct settings
   ![](docs/run-flutter-test.png)