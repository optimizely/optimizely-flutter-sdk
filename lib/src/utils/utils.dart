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

import 'dart:io' show Platform;

import 'package:optimizely_flutter_sdk/src/user_context/optimizely_user_context.dart';
import 'package:optimizely_flutter_sdk/src/utils/constants.dart';

class Utils {
  static Map<OptimizelyDecideOption, String> decideOptions = {
    OptimizelyDecideOption.disableDecisionEvent: "disableDecisionEvent",
    OptimizelyDecideOption.enabledFlagsOnly: "enabledFlagsOnly",
    OptimizelyDecideOption.ignoreUserProfileService: "ignoreUserProfileService",
    OptimizelyDecideOption.includeReasons: "includeReasons",
    OptimizelyDecideOption.excludeVariables: "excludeVariables",
  };

  static Map<String, dynamic> convertToTypedMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return map;
    }

    // Send type along with value so typecasting is easily possible (only for iOS)
    Map<String, dynamic> typedMap = {};
    // Only keep primitive values
    Map<String, dynamic> primitiveMap = {};
    for (MapEntry e in map.entries) {
      if (e.value is String) {
        primitiveMap[e.key] = e.value;
        typedMap[e.key] = {
          Constants.value: e.value,
          Constants.type: Constants.stringType
        };
        continue;
      }
      if (e.value is double) {
        primitiveMap[e.key] = e.value;
        typedMap[e.key] = {
          Constants.value: e.value,
          Constants.type: Constants.doubleType
        };
        continue;
      }
      if (e.value is int) {
        primitiveMap[e.key] = e.value;
        typedMap[e.key] = {
          Constants.value: e.value,
          Constants.type: Constants.intType
        };
        continue;
      }
      if (e.value is bool) {
        primitiveMap[e.key] = e.value;
        typedMap[e.key] = {
          Constants.value: e.value,
          Constants.type: Constants.boolType
        };
        continue;
      }
      // ignore: avoid_print
      print('Unsupported value type for key: ${e.key}.');
    }

    if (Platform.isIOS) {
      return typedMap;
    }
    return primitiveMap;
  }

  static List<String> convertDecideOptions(
      Set<OptimizelyDecideOption> options) {
    List<String> convertedOptions = [];
    for (var option in options) {
      convertedOptions.add(Utils.decideOptions[option]!);
    }
    return convertedOptions;
  }
}
