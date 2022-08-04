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
    "enabled": true,
    "variables": {
      "bool_var": true,
      "str_var": "hello",
      "int_var": 1,
      "double_var": 5.5999999999999996
    },
    "reasons": ["test_reason"],
    "variation_key": "16906801184",
    "user_context": {
      "user_id": "934391.0003922911",
      "attributes": {"attr_1": "hola"}
    },
    "rule_key": "16941022436",
    "flag_key": "feature_1"
  };

  static bool compareDecisions(DecideResponse response) {
    final correctDecision = Decision(decideResponseMap);
    for (var i = 0; i < response.decisions.length; i++) {
      final decision = response.decisions[i];
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

  static sendTestNotifications(
      Function(MethodCall message) handler, int count) {
    for (var i = 0; i < count; i++) {
      handler(MethodCall(Constants.callBackListener, {
        Constants.id: i,
        Constants.payload: {"payload": i}
      }));
    }
  }

  static bool testNotificationPayload(List notifications) {
    for (var i = 0; i < notifications.length; i++) {
      if (notifications[i]["payload"] != i) {
        return false;
      }
    }
    return true;
  }
}
