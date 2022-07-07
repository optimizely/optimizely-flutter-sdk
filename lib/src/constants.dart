class Constants {
  // Supported data types for attributes and eventTags
  static const String stringType = "string";
  static const String doubleType = "double";
  static const String intType = "int";
  static const String boolType = "bool";

  // Supported Method Names
  static const String initializeMethod = "initialize";
  static const String getOptimizelyConfigMethod = "getOptimizelyConfig";
  static const String createUserContextMethod = "createUserContext";
  static const String setAttributesMethod = "setAttributes";
  static const String trackEventMethod = "trackEvent";
  static const String decideMethod = "decide";
  static const String addNotificationListenerMethod = "addNotificationListener";
  static const String removeNotificationListenerMethod =
      "removeNotificationListener";

  // Request parameter keys
  static const String id = "id";
  static const String sdkKey = "sdk_key";
  static const String userID = "user_id";
  static const String attributes = "attributes";
  static const String eventKey = "event_key";
  static const String eventTags = "event_tags";
  static const String keys = "keys";
  static const String optimizelyDecideOption = "optimizely_decide_option";
  static const String payload = "payload";
  static const String value = "value";
  static const String type = "type";
  static const String callBackListener = "callbackListener";
}
