part of optimizely_flutter_sdk;

class ClientRequest {
  String? sdkKey;

  Map<String, dynamic> toDict() {
    final Map<String, dynamic> result = <String, dynamic>{};
    result['sdk_key'] = sdkKey;
    return result;
  }
}
