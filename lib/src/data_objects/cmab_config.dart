/****************************************************************************
 * Copyright 2025, Optimizely, Inc. and contributors                        *
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

/// Configuration for CMAB (Contextual Multi-Armed Bandit) service
class CmabConfig {
  /// The maximum size of CMAB decision cache (default = 100)
  final int cacheSize;

  /// The timeout in seconds of CMAB cache (default = 1800 / 30 minutes)
  final int cacheTimeoutInSecs;

  /// The CMAB prediction endpoint template (optional, default endpoint used if null)
  ///
  /// Provide a URL template with '{ruleId}' placeholder which will be replaced
  /// with the actual rule ID at runtime.
  ///
  /// Example: 'https://custom-endpoint.example.com/predict/{ruleId}'
  /// Default: 'https://prediction.cmab.optimizely.com/predict/{ruleId}'
  ///
  /// Note: The placeholder is automatically converted to platform-specific format
  /// (%@ for iOS, %s for Android) when passed to native SDKs.
  final String? predictionEndpoint;

  const CmabConfig({
    this.cacheSize = 100,
    this.cacheTimeoutInSecs = 1800,
    this.predictionEndpoint,
  });
}
