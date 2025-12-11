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
import 'package:optimizely_flutter_sdk/src/data_objects/log_level.dart';

class Utils {
  static Map<OptimizelyDecideOption, String> decideOptions = {
    OptimizelyDecideOption.disableDecisionEvent: "disableDecisionEvent",
    OptimizelyDecideOption.enabledFlagsOnly: "enabledFlagsOnly",
    OptimizelyDecideOption.ignoreUserProfileService: "ignoreUserProfileService",
    OptimizelyDecideOption.includeReasons: "includeReasons",
    OptimizelyDecideOption.excludeVariables: "excludeVariables",
  };

  static Map<OptimizelySegmentOption, String> segmentOptions = {
    OptimizelySegmentOption.ignoreCache: "ignoreCache",
    OptimizelySegmentOption.resetCache: "resetCache",
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
      dynamic processedValue = _processValue(e.value);
      if (processedValue != null) {
        primitiveMap[e.key] = e.value;
        typedMap[e.key] = processedValue;
      }
    }

    if (Platform.isIOS) {
      return typedMap;
    }
    return primitiveMap;
  }

  /// Recursively processes values to add type information for iOS
  static dynamic _processValue(dynamic value) {
    if (value is String) {
      return {
        Constants.value: value,
        Constants.type: Constants.stringType
      };
    }
    if (value is double) {
      return {
        Constants.value: value,
        Constants.type: Constants.doubleType
      };
    }
    if (value is int) {
      return {
        Constants.value: value,
        Constants.type: Constants.intType
      };
    }
    if (value is bool) {
      return {
        Constants.value: value,
        Constants.type: Constants.boolType
      };
    }
    if (value is Map) {
      // Handle nested maps
      Map<String, dynamic> nestedMap = {};
      (value as Map).forEach((k, v) {
        dynamic processedValue = _processValue(v);
        if (processedValue != null) {
          nestedMap[k.toString()] = processedValue;
        }
      });
      return {
        Constants.value: nestedMap,
        Constants.type: Constants.mapType
      };
    }
    if (value is List) {
      // Handle arrays
      List<dynamic> nestedList = [];
      for (var item in value) {
        dynamic processedValue = _processValue(item);
        if (processedValue != null) {
          nestedList.add(processedValue);
        }
      }
      return {
        Constants.value: nestedList,
        Constants.type: Constants.listType
      };
    }
    // ignore: avoid_print
    print('Unsupported value type: ${value.runtimeType}');
    return null;
  }

  static List<String> convertDecideOptions(
      Set<OptimizelyDecideOption> options) {
    return options.map((option) => Utils.decideOptions[option]!).toList();
  }

  static List<String> convertSegmentOptions(
      Set<OptimizelySegmentOption> options) {
    return options.map((option) => Utils.segmentOptions[option]!).toList();
  }

  static String convertLogLevel(OptimizelyLogLevel logLevel) {
    // OptimizelyLogLevel.error -> "error"
    // OptimizelyLogLevel.debug -> "debug"
    return logLevel.toString().split('.').last;  
  }

}
