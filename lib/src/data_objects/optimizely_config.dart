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

import 'package:optimizely_flutter_sdk/src/utils/constants.dart';

class OptimizelyConfig {
  Map<String, OptimizelyExperiment> experimentsMap = {};
  Map<String, OptimizelyFeature> featuresMap = {};
  List<OptimizelyAttribute> attributes = [];
  List<OptimizelyEvent> events = [];
  List<OptimizelyAudience> audiences = [];
  String? revision;
  String? sdkKey;
  String? environmentKey;
  String? datafile;

  OptimizelyConfig(Map<String, dynamic> optimizelyConfig) {
    if (optimizelyConfig[Constants.experimentsMap] is Map<dynamic, dynamic>) {
      final experimentsMapDynamic =
          Map<String, dynamic>.from(optimizelyConfig[Constants.experimentsMap]);
      experimentsMapDynamic.forEach((k, v) => {
            if (v is Map<dynamic, dynamic>)
              {
                experimentsMap[k] =
                    OptimizelyExperiment.fromJson(Map<String, dynamic>.from(v))
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
          .map((audience) =>
              OptimizelyAudience.fromJson(Map<String, dynamic>.from(audience)))
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

  Map<String, dynamic> toJson() {
    Map<String, dynamic> dynamicExpMap = {};
    experimentsMap.forEach((k, v) => {dynamicExpMap[k] = v.toJson()});
    Map<String, dynamic> dynamicFeaturesMap = {};
    featuresMap.forEach((k, v) => {dynamicFeaturesMap[k] = v.toJson()});
    var dynamicAttributes = [];
    attributes.forEach((v) => {dynamicAttributes.add(v.toJson())});
    var dynamicEvents = [];
    events.forEach((v) => {dynamicEvents.add(v.toJson())});
    var dynamicAudiences = [];
    audiences.forEach((v) => {dynamicAudiences.add(v.toJson())});

    return {
      'experimentsMap': dynamicExpMap,
      'featuresMap': dynamicFeaturesMap,
      'attributes': dynamicAttributes,
      'events': dynamicEvents,
      'audiences': dynamicAudiences,
      'revision': revision,
      'sdkKey': sdkKey,
      'environmentKey': environmentKey,
      'datafile': datafile
    };
  }

  @override
  String toString() {
    var encodedExperimentsMap = json.encode(experimentsMap);
    var encodedFeaturesMap = json.encode(featuresMap);
    var encodedAttributes = json.encode(attributes);
    var encodedEvents = json.encode(events);
    var encodedAudiences = json.encode(audiences);
    return 'OptimizelyConfig {revision="$revision",'
        ' sdkKey="$sdkKey",'
        ' environmentKey="$environmentKey",'
        ' events="$encodedEvents",'
        ' audiences="$encodedAudiences",'
        ' attributes="$encodedAttributes",'
        ' featuresMap="$encodedFeaturesMap",'
        ' experimentsMap="$encodedExperimentsMap"}';
  }
}

// Represents the Audiences list in {@link OptimizelyConfigResponse}
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

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'conditions': conditions};

  @override
  String toString() {
    return 'OptimizelyAudience {id="$id", name="$name", conditions="$conditions"}';
  }
}

// Represents the Events's map in {@link OptimizelyConfigResponse}
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

  Map<String, dynamic> toJson() =>
      {'id': id, 'key': key, 'experimentIds': experimentIds};

  @override
  String toString() {
    var encodedExperimentIds = json.encode(experimentIds);
    return 'OptimizelyEvent {id="$id", key="$key", experimentIds="$encodedExperimentIds"}';
  }
}

// Represents the Attribute's map in {@link OptimizelyConfigResponse}
class OptimizelyAttribute {
  final String? id;
  final String? key;

  OptimizelyAttribute({this.id, this.key});

  factory OptimizelyAttribute.fromJson(Map<String, dynamic> parsedJson) {
    return OptimizelyAttribute(
        id: parsedJson[Constants.id], key: parsedJson[Constants.key]);
  }
  Map<String, dynamic> toJson() => {'id': id, 'key': key};

  @override
  String toString() {
    return 'OptimizelyAttribute {id="$id", key="$key"}';
  }
}

// Represents the feature's map in {@link OptimizelyConfigResponse}
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
        key: parsedJson[Constants.key],
        deliveryRules: tempDeliveryRules,
        experimentRules: tempExperimentRules);
  }

  Map<String, dynamic> toJson() {
    var dynamicDeliveryRules = [];
    deliveryRules.forEach((v) => {dynamicDeliveryRules.add(v.toJson())});

    var dynamicExperimentRules = [];
    experimentRules.forEach((v) => {dynamicExperimentRules.add(v.toJson())});
    return {
      'id': id,
      'key': key,
      'deliveryRules': dynamicDeliveryRules,
      'experimentRules': dynamicExperimentRules
    };
  }

  @override
  String toString() {
    var encodedDeliveryRules = json.encode(deliveryRules);
    var encodedExperimentRules = json.encode(experimentRules);
    return 'OptimizelyFeature {id="$id", key="$key", deliveryRules="$encodedDeliveryRules", experimentRules="$encodedExperimentRules"}';
  }
}

// Represents the experiment's map in {@link OptimizelyConfigResponse}
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

  Map<String, dynamic> toJson() {
    Map<String, dynamic> dynamicVariationsMap = {};
    variationsMap.forEach((k, v) => {dynamicVariationsMap[k] = v.toJson()});

    return {
      'id': id,
      'key': key,
      'audiences': audiences,
      'variationsMap': dynamicVariationsMap
    };
  }

  @override
  String toString() {
    var encodedVariationsMap = json.encode(variationsMap);
    return 'OptimizelyExperiment {id="$id", key="$key", audiences="$audiences", variationsMap="$encodedVariationsMap"}';
  }
}

// Details of variation in {@link OptimizelyExperiment}
class OptimizelyVariation {
  final String? id;
  final String? key;
  final bool featureEnabled;
  final Map<String, OptimizelyVariable> variablesMap;

  OptimizelyVariation(
      {this.id,
      this.key,
      this.featureEnabled = false,
      this.variablesMap = const {}});

  factory OptimizelyVariation.fromJson(Map<String, dynamic> parsedJson) {
    Map<String, OptimizelyVariable>? tempVariablesMap = {};
    if (parsedJson[Constants.variablesMap] is Map<dynamic, dynamic>) {
      final variablesMapDynamic =
          Map<String, dynamic>.from(parsedJson[Constants.variablesMap]);
      variablesMapDynamic.forEach((k, v) => {
            if (v is Map<dynamic, dynamic>)
              {
                tempVariablesMap[k] =
                    OptimizelyVariable.fromJson(Map<String, dynamic>.from(v))
              }
          });
    }
    return OptimizelyVariation(
        id: parsedJson[Constants.id],
        key: parsedJson[Constants.key],
        featureEnabled: parsedJson[Constants.featureEnabled],
        variablesMap: tempVariablesMap);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> dynamicVariablesMap = {};
    variablesMap.forEach((k, v) => {dynamicVariablesMap[k] = v.toJson()});

    return {
      'id': id,
      'key': key,
      'featureEnabled': featureEnabled,
      'variablesMap': dynamicVariablesMap
    };
  }

  @override
  String toString() {
    var encodedVariablesMap = json.encode(variablesMap);
    return 'OptimizelyVariation {id="$id", key="$key", featureEnabled="$featureEnabled", variablesMap="$encodedVariablesMap"}';
  }
}

// Details of feature variable in {@link OptimizelyVariation}
class OptimizelyVariable {
  final String? id;
  final String? key;
  final String? type;
  final String? value;

  OptimizelyVariable({this.id, this.key, this.type, this.value});

  factory OptimizelyVariable.fromJson(Map<String, dynamic> parsedJson) {
    return OptimizelyVariable(
        id: parsedJson[Constants.id],
        key: parsedJson[Constants.key],
        type: parsedJson[Constants.type],
        value: parsedJson[Constants.value]);
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'key': key, 'type': type, 'value': value};

  @override
  String toString() {
    return 'OptimizelyVariable {id="$id", key="$key", type="$type", value="$value"}';
  }
}
