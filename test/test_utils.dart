/// **************************************************************************
/// Copyright 2022, Optimizely, Inc. and contributors                        *
///                                                                          *
/// Licensed under the Apache License, Version 2.0 (the "License");          *
/// you may not use this file except in compliance with the License.         *
/// You may obtain a copy of the License at                                  *
///                                                                          *
///    http://www.apache.org/licenses/LICENSE-2.0                            *
///                                                                          *
/// Unless required by applicable law or agreed to in writing, software      *
/// distributed under the License is distributed on an "AS IS" BASIS,        *
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
/// See the License for the specific language governing permissions and      *
/// limitations under the License.                                           *
///**************************************************************************/

import 'package:flutter/foundation.dart';
import "package:flutter/services.dart";
import 'package:optimizely_flutter_sdk/src/data_objects/decide_response.dart';
import 'package:collection/collection.dart';
import 'package:optimizely_flutter_sdk/src/utils/constants.dart';

class TestUtils {
  static const collectionEquality = DeepCollectionEquality();
  static const Map<String, dynamic> decideResponseMap = {
    Constants.enabled: true,
    Constants.variables: {
      "bool_var": true,
      "str_var": "hello",
      "int_var": 1,
      "double_var": 5.5999999999999996
    },
    Constants.reasons: ["test_reason"],
    Constants.variationKey: "16906801184",
    Constants.userContext: {
      Constants.userId: "934391.0003922911",
      Constants.attributes: {"attr_1": "hola"}
    },
    Constants.ruleKey: "16941022436",
    Constants.flagKey: "feature_1"
  };

  static bool compareDecisions(Map<String, Decision> decisions) {
    final correctDecision = Decision(decideResponseMap);
    for (var decision in decisions.values) {
      if (decision.variationKey != correctDecision.variationKey) {
        return false;
      }
      if (decision.flagKey != correctDecision.flagKey) {
        return false;
      }
      if (decision.ruleKey != correctDecision.ruleKey) {
        return false;
      }
      if (decision.enabled != correctDecision.enabled) {
        return false;
      }
      if (!collectionEquality.equals(
          decision.userContext, correctDecision.userContext)) {
        return false;
      }
      if (!collectionEquality.equals(
          decision.variables, correctDecision.variables)) {
        return false;
      }
      if (!listEquals(decision.reasons, correctDecision.reasons)) {
        return false;
      }
    }
    return true;
  }

  static sendTestActivateNotifications(
      Function(MethodCall message) handler, int id, String sdkKey) {
    handler(MethodCall(Constants.activateCallBackListener, {
      Constants.id: id,
      Constants.sdkKey: sdkKey,
      Constants.payload: {
        Constants.experiment: {"test": id},
        Constants.userId: "test",
        Constants.attributes: {"test": id},
        Constants.variation: {"test": id},
      },
    }));
  }

  static sendTestDecisionNotifications(
      Function(MethodCall message) handler, int id, String sdkKey) {
    handler(MethodCall(Constants.decisionCallBackListener, {
      Constants.id: id,
      Constants.sdkKey: sdkKey,
      Constants.payload: <String, Object>{
        Constants.type: "$id", 
        Constants.userId: "test", 
        Constants.decisionInfo: const {
          Constants.experimentId: "experiment_12345",
          Constants.variationId: "variation_12345",
        },
      }
    }));
  }

  static sendTestLogEventNotifications(
      Function(MethodCall message) handler, int id, String sdkKey) {
    var payload = {
      Constants.url: "$id",
      Constants.params: {"test": id}
    };
    handler(MethodCall(Constants.logEventCallbackListener, {
      Constants.id: id,
      Constants.sdkKey: sdkKey,
      Constants.payload: payload
    }));
  }

  static sendTestClientNameAndVersionLogEventNotification(
      Function(MethodCall message) handler, int id, String sdkKey, String clientName, String sdkVersion) {
      var payload = {
      Constants.url: "$id",
      Constants.params: {
        "test": id,
        "client_name": clientName,
        "client_version": sdkVersion
      }
    };
    handler(MethodCall(Constants.logEventCallbackListener, {
      Constants.id: id,
      Constants.sdkKey: sdkKey,
      Constants.payload: payload
    }));
  }

  static sendTestTrackNotifications(
      Function(MethodCall message) handler, int id, String sdkKey) {
    var payload = {
      Constants.eventKey: "$id",
      Constants.userId: "test",
      Constants.attributes: {"test": id},
      Constants.eventTags: {"testTag": id}
    };
    handler(MethodCall(Constants.trackCallBackListener, {
      Constants.id: id,
      Constants.sdkKey: sdkKey,
      Constants.payload: payload
    }));
  }

  static sendTestTrackClientNameAndVersion(Function(MethodCall message) handler, int id, String sdkKey, String clientName, String sdkVersion) {
    var payload = {
      Constants.eventKey: "$id",
      Constants.userId: "test",
      Constants.attributes: {"test": id},
      Constants.eventTags: {
        "testTag": id,
        "client_name": clientName,
        "client_version": sdkVersion
        }
    };
    handler(MethodCall(Constants.trackCallBackListener, {
      Constants.id: id,
      Constants.sdkKey: sdkKey,
      Constants.payload: payload
    }));
  }

  static sendTestUpdateConfigNotifications(
      Function(MethodCall message) handler, int id, String sdkKey) {
    handler(MethodCall(Constants.configUpdateCallBackListener, {
      Constants.id: id,
      Constants.sdkKey: sdkKey,
      Constants.payload: {"payload": id}
    }));
  }

  static bool testActivateNotificationPayload(
      List notifications, int id, int actualID) {
    if (notifications[id].experiment["test"] != actualID ||
        notifications[id].userId != "test" ||
        notifications[id].variation["test"] != actualID ||
        notifications[id].attributes["test"] != actualID) {
      return false;
    }
    return true;
  }

  static bool testDecisionNotificationPayload(
      List notifications, int id, int actualID) {
    if (notifications[id].type != "$actualID" ||
        notifications[id].userId != "test" ||
        notifications[id].decisionInfo[Constants.experimentId] !=
            "experiment_12345" ||
        notifications[id].decisionInfo[Constants.variationId] !=
            "variation_12345") {
      return false;
    }
    return true;
  }

  static bool testTrackNotificationPayload(
      List notifications, int id, int actualID) {
    if (notifications[id].eventKey != "$actualID" ||
        notifications[id].userId != "test" ||
        notifications[id].attributes["test"] != actualID) {
      return false;
    }
    return true;
  }

  static bool testLogEventNotificationPayload(
      List notifications, int id, int actualID) {
    if (notifications[id].url != "$actualID" ||
        notifications[id].params["test"] != actualID) {
      return false;
    }
    return true;
  }

  static bool testUpdateConfigNotificationPayload(
      List notifications, int id, int actualID) {
    if (notifications[id]["payload"] != actualID) {
      return false;
    }
    return true;
  }
}
