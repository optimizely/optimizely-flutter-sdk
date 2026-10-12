# Contract: Consumer Platform Requirements

The SDK's public Dart API is **unchanged**. The contract that changes is what an app must provide to integrate the plugin on iOS.

| Requirement | Before (3.x) | After (4.0.0) | Enforced by | Failure signal |
|---|---|---|---|---|
| Flutter SDK | ≥2.5.0 | ≥3.44.0 | `pubspec.yaml` `environment.flutter` | `flutter pub get` fails, naming the Flutter constraint |
| iOS deployment target | ≥10.0 | ≥15.0 | `Package.swift` `platforms` | Flutter raises the app target to 15.0 automatically and prints "Updating minimum iOS deployment target to 15.0" |
| iOS dependency manager | CocoaPods or SPM | SPM only | No podspec shipped | Flutter reports that the plugin has no CocoaPods support when SPM is disabled |
| Android | API 21+ | API 21+ (unchanged) | — | — |
| Dart API surface | — | Unchanged | — | — |

## Migration steps for app developers (source for README note)

1. Use Flutter 3.44 or later (SPM is on by default; otherwise run `flutter config --enable-swift-package-manager`).
2. Set the iOS deployment target to 15.0 or higher (Xcode Runner target, plus `platform :ios` in the Podfile if one remains).
3. Run `flutter pub get` and `flutter build ios`. Flutter migrates the Xcode project to SPM automatically.
4. If no other CocoaPods plugins remain, you may run `pod deintegrate` and delete the Podfile.
