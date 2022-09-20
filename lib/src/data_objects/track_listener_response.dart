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

import 'package:optimizely_flutter_sdk/src/utils/constants.dart';

class TrackListenerResponse {
  String eventKey = '';
  String userId = '';
  Map<String, dynamic> attributes = {};
  Map<String, dynamic> eventTags = {};

  TrackListenerResponse(Map<String, dynamic> json) {
    if (json[Constants.eventKey] is String) {
      eventKey = json[Constants.eventKey];
    }
    if (json[Constants.userId] is String) {
      userId = json[Constants.userId];
    }

    if (json[Constants.attributes] is Map<dynamic, dynamic>) {
      attributes = Map<String, dynamic>.from(json[Constants.attributes]);
    }

    if (json[Constants.eventTags] is Map<dynamic, dynamic>) {
      eventTags = Map<String, dynamic>.from(json[Constants.eventTags]);
    }
  }
}
