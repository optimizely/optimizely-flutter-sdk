import 'dart:async';
import 'package:flutter/services.dart';

class OptimizelyFlutterSdk {
  static const MethodChannel _channel = MethodChannel('optimizely_flutter_sdk');

  static Future<Map<String, dynamic>> initializeClient(String sdkKey) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod('initialize', {'sdk_key': sdkKey}));
  }

  static Future<Map<String, dynamic>> getOptimizelyConfig() async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod('getOptimizelyConfig'));
  }

  static Future<Map<String, dynamic>> createUserContext(String userId,
      [Map<String, dynamic> attributes = const {}]) async {
    return Map<String, dynamic>.from(await _channel.invokeMethod(
        'createUserContext', {'user_id': userId, 'attributes': attributes}));
  }

  static Future<Map<String, dynamic>> setAttributes(
      Map<String, dynamic> attributes) async {
    return Map<String, dynamic>.from(await _channel
        .invokeMethod('set_attributes', {'attributes': attributes}));
  }

  static Future<Map<String, dynamic>> trackEvent(String eventKey,
      [Map<String, dynamic> eventTags = const {}]) async {
    return Map<String, dynamic>.from(await _channel.invokeMethod(
        'track_event', {'event_key': eventKey, 'event_tags': eventTags}));
  }

  static Future<Map<String, dynamic>> decide(
      [List<String> keys = const [], List<String> options = const []]) async {
    return Map<String, dynamic>.from(await _channel.invokeMethod(
        'decide', {'keys': keys, 'optimizely_decide_option': options}));
  }
}
