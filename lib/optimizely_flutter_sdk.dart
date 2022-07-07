library optimizely_flutter_sdk;

import 'dart:async';
import './src/optimizely_client_wrapper.dart';
export './src/optimizely_client_wrapper.dart' show ListenerType;

class OptimizelyFlutterSdk {
  final String _sdkKey;
  OptimizelyFlutterSdk(this._sdkKey);

  Future<Map<String, dynamic>> initializeClient() async {
    return await OptimizelyClientWrapper.initializeClient(_sdkKey);
  }

  Future<Map<String, dynamic>> getOptimizelyConfig() async {
    return await OptimizelyClientWrapper.getOptimizelyConfig(_sdkKey);
  }

  Future<Map<String, dynamic>> createUserContext(String userId,
      [Map<String, dynamic> attributes = const {}]) async {
    return await OptimizelyClientWrapper.createUserContext(
        _sdkKey, userId, attributes);
  }

  Future<Map<String, dynamic>> setAttributes(
      Map<String, dynamic> attributes) async {
    return await OptimizelyClientWrapper.setAttributes(_sdkKey, attributes);
  }

  Future<Map<String, dynamic>> trackEvent(String eventKey,
      [Map<String, dynamic> eventTags = const {}]) async {
    return await OptimizelyClientWrapper.trackEvent(
        _sdkKey, eventKey, eventTags);
  }

  Future<Map<String, dynamic>> decide(String key,
      [List<String> options = const []]) async {
    return await OptimizelyClientWrapper.decide(_sdkKey, [key], options);
  }

  Future<Map<String, dynamic>> decideForKeys(
      [List<String> keys = const [], List<String> options = const []]) async {
    return await OptimizelyClientWrapper.decide(_sdkKey, keys, options);
  }

  Future<Map<String, dynamic>> decideAll(
      [List<String> options = const []]) async {
    return await OptimizelyClientWrapper.decide(_sdkKey, [], options);
  }

  Future<CancelListening> addNotificationListener(
      MultiUseCallback callback, ListenerType listenerType) async {
    return await OptimizelyClientWrapper.addNotificationListener(
        _sdkKey, callback, listenerType);
  }
}
