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

import 'package:optimizely_flutter_sdk/src/constants.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/base_response.dart';

class Decision {
  String variationKey = '';
  String flagKey = '';
  String ruleKey = '';
  bool enabled = false;
  Map<String, dynamic> userContext = {};
  Map<String, dynamic> variables = {};
  List<String> reasons = [];

  Decision(Map<String, dynamic> json) {
    if (json[Constants.requestVariationKey] is String) {
      variationKey = json[Constants.requestVariationKey];
    }
    if (json[Constants.requestFlagKey] is String) {
      flagKey = json[Constants.requestFlagKey];
    }
    if (json[Constants.requestRuleKey] is String) {
      ruleKey = json[Constants.requestRuleKey];
    }
    if (json[Constants.requestEnabled] is bool) {
      enabled = json[Constants.requestEnabled];
    }
    if (json[Constants.requestUserContext] is Map<dynamic, dynamic>) {
      Map<String, dynamic> _userContext =
          Map<String, dynamic>.from(json[Constants.requestUserContext]);
      if (_userContext[Constants.requestUserID] is String) {
        userContext[Constants.requestUserID] =
            _userContext[Constants.requestUserID];
      }
      if (_userContext[Constants.requestAttributes] is Map<dynamic, dynamic>) {
        userContext[Constants.requestAttributes] = Map<String, dynamic>.from(
            _userContext[Constants.requestAttributes]);
      }
    }

    if (json[Constants.requestVariables] is Map<dynamic, dynamic>) {
      variables = Map<String, dynamic>.from(json[Constants.requestVariables]);
    }
    if (json[Constants.requestReasons] is List<dynamic>) {
      reasons = List<String>.from(json[Constants.requestReasons]);
    }
  }
}

class DecideResponse extends BaseResponse {
  List<Decision> decisions = [];

  DecideResponse(Map<String, dynamic> json) : super(json) {
    if (json[Constants.responseResult] is Map<dynamic, dynamic>) {
      var _decisions =
          Map<String, dynamic>.from(json[Constants.responseResult]);
      for (final value in _decisions.values) {
        if (value is Map<dynamic, dynamic>) {
          var decision = Decision(Map<String, dynamic>.from(value));
          decisions.add(decision);
        }
      }
    }
  }
}
