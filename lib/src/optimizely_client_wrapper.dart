import 'dart:async';
import 'package:flutter/services.dart';
import 'package:optimizely_flutter_sdk/src/datamodels/typed_value.dart';

enum ListenerType { track, decision, logEvent }

typedef MultiUseCallback = void Function(dynamic msg);
typedef CancelListening = void Function();

class OptimizelyClientWrapper {
  static const MethodChannel _channel = MethodChannel('optimizely_flutter_sdk');
  static int _nextCallbackId = 0;
  static final Map<int, MultiUseCallback> _callbacksById = {};

  static Future<Map<String, dynamic>> initializeClient(String sdkKey) async {
    _channel.setMethodCallHandler(_methodCallHandler);
    return Map<String, dynamic>.from(
        await _channel.invokeMethod('initialize', {'sdk_key': sdkKey}));
  }

  static Future<Map<String, dynamic>> getOptimizelyConfig(String sdkKey) async {
    return Map<String, dynamic>.from(await _channel
        .invokeMethod('getOptimizelyConfig', {'sdk_key': sdkKey}));
  }

  static Future<Map<String, dynamic>> createUserContext(
      String sdkKey, String userId,
      [Map<String, TypedValue> attributes = const {}]) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod('createUserContext', {
      'sdk_key': sdkKey,
      'user_id': userId,
      'attributes': OptimizelyClientWrapper._covertTypedMap(attributes)
    }));
  }

  static Future<Map<String, dynamic>> setAttributes(
      String sdkKey, Map<String, TypedValue> attributes) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod('set_attributes', {
      'sdk_key': sdkKey,
      'attributes': OptimizelyClientWrapper._covertTypedMap(attributes)
    }));
  }

  static Future<Map<String, dynamic>> trackEvent(String sdkKey, String eventKey,
      [Map<String, TypedValue> eventTags = const {}]) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod('track_event', {
      'sdk_key': sdkKey,
      'event_key': eventKey,
      'event_tags': OptimizelyClientWrapper._covertTypedMap(eventTags)
    }));
  }

  static Future<Map<String, dynamic>> decide(String sdkKey,
      [List<String> keys = const [], List<String> options = const []]) async {
    return Map<String, dynamic>.from(await _channel.invokeMethod('decide', {
      'sdk_key': sdkKey,
      'keys': keys,
      'optimizely_decide_option': options
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
    await _channel.invokeMethod("addListener",
        {'sdk_key': sdkKey, "id": currentListenerId, "type": listenerTypeStr});
    return () {
      _channel.invokeMethod(
          "removeListener", {'sdk_key': sdkKey, "id": currentListenerId});
      _callbacksById.remove(currentListenerId);
    };
  }

  static Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'callbackListener':
        var id = call.arguments["id"];
        var payload = call.arguments["payload"];
        if (id is int && payload != null) {
          _callbacksById[id]!(payload);
        }
        break;
      default:
        // ignore: avoid_print
        print('Method ${call.method} not implemented.');
    }
  }

  static Map<String, dynamic> _covertTypedMap(
      Map<String, TypedValue> typedMap) {
    if (typedMap.isEmpty) {
      return {};
    }
    return {for (var e in typedMap.keys) e: typedMap[e]!.toMap()};
  }
}
