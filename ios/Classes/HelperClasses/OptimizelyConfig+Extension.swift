/****************************************************************************
 * Copyright 2022, Optimizely, Inc. and contributors                        *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 *    http://www.apache.org/licenses/LICENSE-2.0                            *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 ***************************************************************************/

import Foundation
import Optimizely

// Extension to convert OptimizelyConfig to Map
extension OptimizelyConfig {
    var dict: [String: Any]? {
        return [
            "revision": self.revision,
            "experimentsMap": self.experimentsMap.mapValues{ $0.dict },
            "featuresMap": self.featuresMap.mapValues{ $0.dict },
            "attributes": self.attributes.map { $0.dict },
            "audiences": self.audiences.map { $0.dict },
            "events": self.events.map { $0.dict },
            "sdkKey": self.sdkKey,
            "environmentKey": self.environmentKey
        ]
    }
}

extension OptimizelyAttribute {
    var dict: [String: Any] {
        return [
            "key": self.key,
            "id": self.id,
        ]
    }
}

extension OptimizelyAudience {
    var dict: [String: Any] {
        return [
            "name": self.name,
            "id": self.id,
            "conditions": self.conditions
        ]
    }
}

extension OptimizelyEvent {
    var dict: [String: Any] {
        return [
            "key": self.key,
            "id": self.id,
            "experimentIds": self.experimentIds
        ]
    }
}

extension OptimizelyExperiment {
    var dict: [String: Any] {
        return [
            "key": self.key,
            "id": self.id,
            "audiences": self.audiences,
            "variationsMap": self.variationsMap.mapValues{ $0.dict }
        ]
    }
}

extension OptimizelyFeature {
    var dict: [String: Any] {
        return [
            "key": self.key,
            "id": self.id,
            "experimentRules": self.experimentRules.map{ $0.dict },
            "deliveryRules": self.deliveryRules.map{ $0.dict },
            "experimentsMap": self.experimentsMap.mapValues{ $0.dict },
            "variablesMap": self.variablesMap.mapValues{ $0.dict }
        ]
    }
}

extension OptimizelyVariation {
    var dict: [String: Any] {
        var expected: [String: Any] = [
            "key": self.key,
            "id": self.id,
            "variablesMap": self.variablesMap.mapValues{ $0.dict }
        ]
        
        if let featureEnabled = self.featureEnabled {
            expected["featureEnabled"] = featureEnabled
        }
        
        return expected
    }
}

extension OptimizelyVariable {
    var dict: [String: Any] {
        return [
            "key": self.key,
            "id": self.id,
            "type": self.type,
            "value": self.value
        ]
    }
}
