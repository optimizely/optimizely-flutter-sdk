library optimizely_flutter_sdk;

import 'dart:async';
import 'package:flutter/services.dart';
part 'client_request.dart';

class OptimizelyFlutterSdk {
  static const MethodChannel _channel = MethodChannel('optimizely_flutter_sdk');

  static Future<Map<String, dynamic>> initializeClient(
      ClientRequest request) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod('initialize', request.toDict()));
  }

  static Future<Map<String, dynamic>> get decide async {
    return Map<String, dynamic>.from(await _channel.invokeMethod('decide'));
  }
}
