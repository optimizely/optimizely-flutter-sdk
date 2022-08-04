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
      Map<String, dynamic> _userContext =
          Map<String, dynamic>.from(json[Constants.userContext]);
      if (_userContext[Constants.userID] is String) {
        userContext[Constants.userID] = _userContext[Constants.userID];
      }
      if (_userContext[Constants.attributes] is Map<dynamic, dynamic>) {
        userContext[Constants.attributes] =
            Map<String, dynamic>.from(_userContext[Constants.attributes]);
      }
    }

    if (json[Constants.variables] is Map<dynamic, dynamic>) {
      variables = Map<String, dynamic>.from(json[Constants.variables]);
    }
    if (json[Constants.reasons] is List<dynamic>) {
      reasons = List<String>.from(json[Constants.reasons]);
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