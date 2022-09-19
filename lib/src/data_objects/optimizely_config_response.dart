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

class OptimizelyConfigResponse extends BaseResponse {
  late Map<String, OptimizelyExperiment> experimentsMap = {};
  late Map<String, OptimizelyFeature> featuresMap = {};
  late List<OptimizelyAttribute> attributes;
  late List<OptimizelyEvent> events;
  late List<OptimizelyAudience> audiences;
  late String revision;
  late String sdkKey;
  late String environmentKey;
  String? datafile;

  OptimizelyConfigResponse(Map<String, dynamic> json) : super(json) {
    if (json[Constants.responseResult] is Map<dynamic, dynamic>) {
      var optimizelyConfig =
          Map<String, dynamic>.from(json[Constants.responseResult]);

      if (optimizelyConfig[Constants.experimentsMap] is Map<dynamic, dynamic>) {
        final experimentsMapDynamic = Map<String, dynamic>.from(
            optimizelyConfig[Constants.experimentsMap]);
        experimentsMapDynamic.forEach((k, v) => {
              if (v is Map<dynamic, dynamic>)
                {
                  experimentsMap[k] = OptimizelyExperiment.fromJson(
                      Map<String, dynamic>.from(v))
                }
            });
      }

      if (optimizelyConfig[Constants.featuresMap] is Map<dynamic, dynamic>) {
        final featuresMapDynamic =
            Map<String, dynamic>.from(optimizelyConfig[Constants.featuresMap]);
        featuresMapDynamic.forEach((k, v) => {
              if (v is Map<dynamic, dynamic>)
                {
                  featuresMap[k] =
                      OptimizelyFeature.fromJson(Map<String, dynamic>.from(v))
                }
            });
      }

      if (optimizelyConfig[Constants.attributes] is List<dynamic>) {
        var attributesDynamic = optimizelyConfig[Constants.attributes] as List;
        attributes = attributesDynamic
            .map((attribute) => OptimizelyAttribute.fromJson(
                Map<String, dynamic>.from(attribute)))
            .toList();
      }

      if (optimizelyConfig[Constants.events] is List<dynamic>) {
        var eventsDynamic = optimizelyConfig[Constants.events] as List;
        events = eventsDynamic
            .map((event) =>
                OptimizelyEvent.fromJson(Map<String, dynamic>.from(event)))
            .toList();
      }

      if (optimizelyConfig[Constants.audiences] is List<dynamic>) {
        var audiencesDynamic = optimizelyConfig[Constants.audiences] as List;
        audiences = audiencesDynamic
            .map((audience) => OptimizelyAudience.fromJson(
                Map<String, dynamic>.from(audience)))
            .toList();
      }

      if (optimizelyConfig[Constants.revision] is String) {
        revision = optimizelyConfig[Constants.revision] as String;
      }

      if (optimizelyConfig[Constants.sdkKey] is String) {
        sdkKey = optimizelyConfig[Constants.sdkKey] as String;
      }

      if (optimizelyConfig[Constants.environmentKey] is String) {
        environmentKey = optimizelyConfig[Constants.environmentKey] as String;
      }

      if (optimizelyConfig[Constants.datafile] is String) {
        datafile = optimizelyConfig[Constants.datafile] as String;
      }
    }
  }
}

class OptimizelyAudience {
  final String? id;
  final String? name;
  final String? conditions;
  OptimizelyAudience({this.id, this.name, this.conditions});

  factory OptimizelyAudience.fromJson(Map<String, dynamic> parsedJson) {
    return OptimizelyAudience(
        id: parsedJson[Constants.id],
        name: parsedJson[Constants.name],
        conditions: parsedJson[Constants.conditions]);
  }
}

class OptimizelyEvent {
  final String? id;
  final String? key;
  final List<String> experimentIds;
  OptimizelyEvent({this.id, this.key, this.experimentIds = const []});

  factory OptimizelyEvent.fromJson(Map<String, dynamic> parsedJson) {
    return OptimizelyEvent(
        id: parsedJson[Constants.id],
        key: parsedJson[Constants.key],
        experimentIds: List<String>.from(parsedJson[Constants.experimentIds]));
  }
}

class OptimizelyAttribute {
  final String? id;
  final String? key;

  OptimizelyAttribute({this.id, this.key});

  factory OptimizelyAttribute.fromJson(Map<String, dynamic> parsedJson) {
    return OptimizelyAttribute(
        id: parsedJson[Constants.id], key: parsedJson[Constants.key]);
  }
}

class OptimizelyFeature {
  final String? id;
  final String? key;
  final List<OptimizelyExperiment> deliveryRules;
  final List<OptimizelyExperiment> experimentRules;

  OptimizelyFeature(
      {this.id,
      this.key,
      this.deliveryRules = const [],
      this.experimentRules = const []});

  factory OptimizelyFeature.fromJson(Map<String, dynamic> parsedJson) {
    List<OptimizelyExperiment> tempDeliveryRules = [];
    List<OptimizelyExperiment> tempExperimentRules = [];
    if (parsedJson[Constants.deliveryRules] is List<dynamic>) {
      var deliveryRulesDynamic = parsedJson[Constants.deliveryRules] as List;
      tempDeliveryRules = deliveryRulesDynamic
          .map((experiment) => OptimizelyExperiment.fromJson(
              Map<String, dynamic>.from(experiment)))
          .toList();
    }
    if (parsedJson[Constants.experimentRules] is List<dynamic>) {
      var experimentRulesDynamic =
          parsedJson[Constants.experimentRules] as List;
      tempExperimentRules = experimentRulesDynamic
          .map((experiment) => OptimizelyExperiment.fromJson(
              Map<String, dynamic>.from(experiment)))
          .toList();
    }
    return OptimizelyFeature(
        id: parsedJson[Constants.id],
        key: parsedJson[Constants.name],
        deliveryRules: tempDeliveryRules,
        experimentRules: tempExperimentRules);
  }
}

class OptimizelyExperiment {
  final String? id;
  final String? key;
  final String audiences;
  final Map<String, OptimizelyVariation> variationsMap;

  OptimizelyExperiment(
      {this.id, this.key, this.audiences = "", this.variationsMap = const {}});
  factory OptimizelyExperiment.fromJson(Map<String, dynamic> parsedJson) {
    Map<String, OptimizelyVariation>? tempVariationsMap = {};
    if (parsedJson[Constants.variationsMap] is Map<dynamic, dynamic>) {
      final variationsMapDynamic =
          Map<String, dynamic>.from(parsedJson[Constants.variationsMap]);
      variationsMapDynamic.forEach((k, v) => {
            if (v is Map<dynamic, dynamic>)
              {
                tempVariationsMap[k] =
                    OptimizelyVariation.fromJson(Map<String, dynamic>.from(v))
              }
          });
    }
    return OptimizelyExperiment(
        id: parsedJson[Constants.id],
        key: parsedJson[Constants.key],
        audiences: parsedJson[Constants.audiences],
        variationsMap: tempVariationsMap);
  }
}

class OptimizelyVariation {
  final String? id;
  final String? key;
  final bool featureEnabled;

  OptimizelyVariation({this.id, this.key, this.featureEnabled = false});

  factory OptimizelyVariation.fromJson(Map<String, dynamic> parsedJson) {
    return OptimizelyVariation(
        id: parsedJson[Constants.id],
        key: parsedJson[Constants.key],
        featureEnabled: parsedJson[Constants.featureEnabled]);
  }
}
