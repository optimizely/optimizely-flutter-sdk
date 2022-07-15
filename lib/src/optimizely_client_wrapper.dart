import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'constants.dart';

enum ListenerType { track, decision, logEvent, projectConfigUpdate }

typedef MultiUseCallback = void Function(dynamic msg);
typedef CancelListening = void Function();

class OptimizelyClientWrapper {
  static const MethodChannel _channel = MethodChannel('optimizely_flutter_sdk');
  static int _nextCallbackId = 0;
  static final Map<int, MultiUseCallback> _callbacksById = {};

  static Future<Map<String, dynamic>> initializeClient(String sdkKey) async {
    _channel.setMethodCallHandler(_methodCallHandler);
    return Map<String, dynamic>.from(await _channel
        .invokeMethod(Constants.initializeMethod, {Constants.sdkKey: sdkKey}));
  }

  static Future<Map<String, dynamic>> getOptimizelyConfig(String sdkKey) async {
    return Map<String, dynamic>.from(await _channel.invokeMethod(
        Constants.getOptimizelyConfigMethod, {Constants.sdkKey: sdkKey}));
  }

  static Future<Map<String, dynamic>> createUserContext(
      String sdkKey, String userId,
      [Map<String, dynamic> attributes = const {}]) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.createUserContextMethod, {
      Constants.sdkKey: sdkKey,
      Constants.userID: userId,
      Constants.attributes:
          OptimizelyClientWrapper._covertToTypedMap(attributes)
    }));
  }

  static Future<Map<String, dynamic>> setAttributes(
      String sdkKey, Map<String, dynamic> attributes) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.setAttributesMethod, {
      Constants.sdkKey: sdkKey,
      Constants.attributes:
          OptimizelyClientWrapper._covertToTypedMap(attributes)
    }));
  }

  static Future<Map<String, dynamic>> trackEvent(String sdkKey, String eventKey,
      [Map<String, dynamic> eventTags = const {}]) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.trackEventMethod, {
      Constants.sdkKey: sdkKey,
      Constants.eventKey: eventKey,
      Constants.eventTags: OptimizelyClientWrapper._covertToTypedMap(eventTags)
    }));
  }

  static Future<Map<String, dynamic>> decide(String sdkKey,
      [List<String> keys = const [], List<String> options = const []]) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.decideMethod, {
      Constants.sdkKey: sdkKey,
      Constants.keys: keys,
      Constants.optimizelyDecideOption: options
    }));
  }

  static Future<CancelListening> addNotificationListener(String sdkKey,
      MultiUseCallback callback, ListenerType listenerType) async {
    _channel.setMethodCallHandler(_methodCallHandler);
    int currentListenerId = _nextCallbackId++;
    _callbacksById[currentListenerId] = callback;
    var listenerTypeStr = listenerType
        .toString()
        .substring(listenerType.toString().indexOf('.') + 1);
    await _channel.invokeMethod(Constants.addNotificationListenerMethod, {
      Constants.sdkKey: sdkKey,
      Constants.id: currentListenerId,
      Constants.type: listenerTypeStr
    });
    return () {
      _channel.invokeMethod(Constants.removeNotificationListenerMethod,
          {Constants.sdkKey: sdkKey, Constants.id: currentListenerId});
      _callbacksById.remove(currentListenerId);
    };
  }

  static Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case Constants.callBackListener:
        var id = call.arguments[Constants.id];
        var payload = call.arguments[Constants.payload];
        if (id is int && payload != null) {
          _callbacksById[id]!(payload);
        }
        break;
      default:
        // ignore: avoid_print
        print('Method ${call.method} not implemented.');
    }
  }

  static Map<String, dynamic> _covertToTypedMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return {};
    }
    // No alterations required for Android since types are successfully passed to its native code
    if (Platform.isAndroid) {
      return map;
    }

    // Send type along with value so typecasting is easily possible
    Map<String, dynamic> typedMap = {};
    for (MapEntry e in map.entries) {
      if (e.value is String) {
        typedMap[e.key] = {
          Constants.value: e.value,
          Constants.type: Constants.stringType
        };
        continue;
      }
      if (e.value is double) {
        typedMap[e.key] = {
          Constants.value: e.value,
          Constants.type: Constants.doubleType
        };
        continue;
      }
      if (e.value is int) {
        typedMap[e.key] = {
          Constants.value: e.value,
          Constants.type: Constants.intType
        };
        continue;
      }
      if (e.value is bool) {
        typedMap[e.key] = {
          Constants.value: e.value,
          Constants.type: Constants.boolType
        };
      }
    }

    return typedMap;
  }
}
