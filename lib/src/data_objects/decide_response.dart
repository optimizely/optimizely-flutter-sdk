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

import 'dart:convert';

import 'package:optimizely_flutter_sdk/src/data_objects/base_response.dart';
import 'package:optimizely_flutter_sdk/src/utils/constants.dart';

class Decision {
  String variationKey = '';
  String flagKey = '';
  String ruleKey = '';
  bool enabled = false;
  Map<String, dynamic> userContext = {};
  Map<String, dynamic> variables = {};
  List<String> reasons = [];

  Decision(Map<String, dynamic> json) {
    if (json[Constants.variationKey] is String) {
      variationKey = json[Constants.variationKey];
    }
    if (json[Constants.flagKey] is String) {
      flagKey = json[Constants.flagKey];
    }
    if (json[Constants.ruleKey] is String) {
      ruleKey = json[Constants.ruleKey];
    }
    if (json[Constants.enabled] is bool) {
      enabled = json[Constants.enabled];
    }
    if (json[Constants.userContext] is Map<dynamic, dynamic>) {
      Map<String, dynamic> localUserContext =
          Map<String, dynamic>.from(json[Constants.userContext]);
      if (localUserContext[Constants.userId] is String) {
        userContext[Constants.userId] = localUserContext[Constants.userId];
      }
      if (localUserContext[Constants.attributes] is Map<dynamic, dynamic>) {
        userContext[Constants.attributes] =
            Map<String, dynamic>.from(localUserContext[Constants.attributes]);
      }
    }

    if (json[Constants.variables] is Map<dynamic, dynamic>) {
      variables = Map<String, dynamic>.from(json[Constants.variables]);
    }
    if (json[Constants.reasons] is List<dynamic>) {
      reasons = List<String>.from(json[Constants.reasons]);
    }
  }

  @override
  String toString() {
    var encodedVariables = json.encode(variables);
    var encodedUserContext = json.encode(userContext);
    var reasonsString = reasons.join(",");
    return 'Decision {variationKey="$variationKey", enabled="$enabled", variables="$encodedVariables", ruleKey="$ruleKey", flagKey="$flagKey", userContext="$encodedUserContext", reasons="$reasonsString"}';
  }
}

class BaseDecideResponse extends BaseResponse {
  final Map<String, Decision> _decisions = {};

  BaseDecideResponse(Map<String, dynamic> json) : super(json) {
    if (json[Constants.responseResult] is Map<dynamic, dynamic>) {
      final decisionsMap =
          Map<String, dynamic>.from(json[Constants.responseResult]);
      // ignore: unnecessary_set_literal
      decisionsMap.forEach((k, v) => {
            if (v is Map<dynamic, dynamic>)
              {_decisions[k] = Decision(Map<String, dynamic>.from(v))}
          });
    }
  }

  Map<String, Decision> getDecisions() {
    return _decisions;
  }
}

class DecideResponse extends BaseDecideResponse {
  Decision? decision;

  DecideResponse(Map<String, dynamic> json) : super(json) {
    final decisions = getDecisions();
    if (decisions.isNotEmpty) {
      decision = decisions.values.first;
    }
  }
}

class DecideForKeysResponse extends BaseDecideResponse {
  Map<String, Decision> decisions = {};

  DecideForKeysResponse(Map<String, dynamic> json) : super(json) {
    decisions = getDecisions();
  }
}
