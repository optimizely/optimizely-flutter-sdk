/// **************************************************************************
/// Copyright 2023, Optimizely, Inc. and contributors                        *
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

class SDKSettings {
  // The maximum size of audience segments cache (optional. default = 100). Set to zero to disable caching.
  final int segmentsCacheSize;
  // The timeout in seconds of audience segments cache (optional. default = 600). Set to zero to disable timeout.
  final int segmentsCacheTimeoutInSecs;
  // The timeout in seconds of odp segment fetch (optional. default = 10) - OS default timeout will be used if this is set to zero.
  final int timeoutForSegmentFetchInSecs;
  // The timeout in seconds of odp event dispatch (optional. default = 10) - OS default timeout will be used if this is set to zero.
  final int timeoutForOdpEventInSecs;
  // Set this flag to true (default = false) to disable ODP features
  final bool disableOdp;

  const SDKSettings({
    this.segmentsCacheSize = 100, // Default segmentsCacheSize
    this.segmentsCacheTimeoutInSecs = 600, // Default segmentsCacheTimeoutInSecs
    this.timeoutForSegmentFetchInSecs =
        10, // Default timeoutForSegmentFetchInSecs
    this.timeoutForOdpEventInSecs = 10, // Default timeoutForOdpEventInSecs
    this.disableOdp = false, // Default disableOdp
  });
}
