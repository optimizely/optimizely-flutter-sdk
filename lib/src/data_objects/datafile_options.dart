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

class DatafileHostOptions {
  final String datafileHostPrefix;
  final String datafileHostSuffix;

  /// Adds support to provide datafileHost for different Platforms.
  ///
  /// Prefix for iOS should look like: https://cdn.optimizely.com
  /// Suffix for iOS should look like: /datafiles/%@.json (%@ here will automatically be subsituted with the sdkKey
  /// so make sure your datafile's name is the same as the sdkKey)
  ///
  /// Prefix for android should look like: https://cdn.optimizely.com
  /// Suffix for android should look like: /datafiles/%s.json (%s here will automatically be subsituted with the sdkKey
  /// so make sure your datafile's name is the same as the sdkKey)
  const DatafileHostOptions(
    this.datafileHostPrefix,
    this.datafileHostSuffix,
  );
}
