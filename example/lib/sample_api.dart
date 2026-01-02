/// **************************************************************************
/// Copyright 2025, Optimizely, Inc. and contributors                        *
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

import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';
import 'package:optimizely_flutter_sdk_example/custom_logger.dart';


/// CMAB (Contextual Multi-Armed Bandit) API usage examples
///
/// This class demonstrates how to use CMAB features in the Optimizely Flutter SDK:
/// - Initializing SDK with CmabConfig
/// - Using decideAsync for CMAB-enabled experiments
/// - CMAB cache control options
/// - Combining CMAB with other decide options
class CmabSampleApi {
  // Replace with your actual SDK key
  static const String SDK_KEY = '2ExWptsTiSx1EZbpwSnoD';

  // Replace with your CMAB-enabled flag key
  static const String CMAB_FLAG_KEY = 'cmab-flag';

  /// Example 1: Basic CMAB initialization and single flag decision
  ///
  /// This example shows:
  /// - How to initialize the SDK with default CmabConfig
  /// - How to create a user context with attributes
  /// - How to use decideAsync() for a single flag
  /// - How to access decision results
  static Future<void> basicCmabExample() async {
    print('\n========== Example 1: Basic CMAB Usage ==========');

    try {
      // Initialize SDK with default CMAB configuration
      // Default cache size: 100, cache timeout: 1800 seconds (30 minutes)
      var flutterSDK = OptimizelyFlutterSdk(
        SDK_KEY,
        cmabConfig: CmabConfig(), // Uses defaults
      );

      var response = await flutterSDK.initializeClient();
      if (!response.success) {
        print('Failed to initialize SDK: ${response.reason}');
        return;
      }
      print('✓ SDK initialized successfully');

      // Create user context with attributes
      // CMAB uses these attributes to make personalized decisions
      var userContext = await flutterSDK.createUserContext(
        userId: 'user_123',
        attributes: {
          'country': 'us'
        },
      );

      if (userContext == null) {
        print('Failed to create user context');
        return;
      }
      print('✓ User context created for user_123');

      // Use decideAsync for CMAB-enabled flag
      // This makes an async call to the CMAB service for personalized variation
      // Always use ignoreUserProfileService with CMAB to get correct decisions
      print('\nMaking async decision for flag: $CMAB_FLAG_KEY');
      var decision = await userContext.decideAsync(
        CMAB_FLAG_KEY,
        {OptimizelyDecideOption.ignoreUserProfileService},
      );

      // Access decision results
      if (decision.decision != null) {
        print('✓ Decision received:');
        print('  - Flag Key: ${decision.decision!.flagKey}');
        print('  - Variation Key: ${decision.decision!.variationKey}');
        print('  - Enabled: ${decision.decision!.enabled}');
        print('  - Variables: ${decision.decision!.variables}');
      } else {
        print('✗ No decision returned');
      }
    } catch (e) {
      print('Error in basicCmabExample: $e');
    }
  }

  /// Example 2: CMAB cache control options
  ///
  /// This example demonstrates the three CMAB-specific cache options:
  /// - ignoreCmabCache: Bypass cache and make fresh CMAB request
  /// - resetCmabCache: Clear entire CMAB cache before decision
  /// - invalidateUserCmabCache: Clear cache for current user only
  static Future<void> cmabCacheOptionsExample() async {
    print('\n========== Example 2: CMAB Cache Options ==========');

    try {
      var flutterSDK = OptimizelyFlutterSdk(
        SDK_KEY,
        cmabConfig: CmabConfig(),
      );

      await flutterSDK.initializeClient();
      var userContext = await flutterSDK.createUserContext(
        userId: 'user_456',
        attributes: {'country': 'us'},
      );

      if (userContext == null) return;

      // Option 1: Ignore CMAB Cache
      // Use this when you want to bypass the cache and get a fresh decision
      // from the CMAB service (e.g., for real-time personalization)
      print('\n1. Using ignoreCmabCache option:');
      var decision1 = await userContext.decideAsync(
        CMAB_FLAG_KEY,
        {
          OptimizelyDecideOption.ignoreCmabCache,
          OptimizelyDecideOption.ignoreUserProfileService,
        },
      );
      print('  ✓ Fresh decision from CMAB service (cache bypassed)');
      print('  - Variation: ${decision1.decision?.variationKey}');

      // Option 2: Reset CMAB Cache
      // Use this to clear the entire CMAB cache before making a decision
      // Useful when you want to refresh all cached CMAB decisions
      print('\n2. Using resetCmabCache option:');
      var decision2 = await userContext.decideAsync(
        CMAB_FLAG_KEY,
        {
          OptimizelyDecideOption.resetCmabCache,
          OptimizelyDecideOption.ignoreUserProfileService,
        },
      );
      print('  ✓ Entire CMAB cache cleared, new decision fetched');
      print('  - Variation: ${decision2.decision?.variationKey}');

      // Option 3: Invalidate User CMAB Cache
      // Use this to clear cache for the current user only
      // Other users' cached decisions remain intact
      print('\n3. Using invalidateUserCmabCache option:');
      var decision3 = await userContext.decideAsync(
        CMAB_FLAG_KEY,
        {
          OptimizelyDecideOption.invalidateUserCmabCache,
          OptimizelyDecideOption.ignoreUserProfileService,
        },
      );
      print('  ✓ User-specific cache cleared, new decision fetched');
      print('  - Variation: ${decision3.decision?.variationKey}');

      // Regular cached decision (for comparison)
      print('\n4. Regular decision (uses cache if available):');
      var decision4 = await userContext.decideAsync(
        CMAB_FLAG_KEY,
        {OptimizelyDecideOption.ignoreUserProfileService},
      );
      print('  ✓ Decision returned (may be from cache)');
      print('  - Variation: ${decision4.decision?.variationKey}');

    } catch (e) {
      print('Error in cmabCacheOptionsExample: $e');
    }
  }

  /// Example 3: Custom CMAB configuration
  ///
  /// This example shows how to customize CMAB settings:
  /// - Custom cache size
  /// - Custom cache timeout
  /// - Custom prediction endpoint (optional)
  static Future<void> customCmabConfigExample() async {
    print('\n========== Example 3: Custom CMAB Configuration ==========');

    try {
      // Initialize with custom CMAB configuration
      var flutterSDK = OptimizelyFlutterSdk(
        SDK_KEY,
        cmabConfig: CmabConfig(
          cacheSize: 200,              // Store up to 200 decisions in cache
          cacheTimeoutInSecs: 3600,    // Cache expires after 1 hour (3600 seconds)
          predictionEndpoint: 'https://custom-endpoint.example.com/predict/{ruleId}', // Optional custom endpoint template
        ),
      );

      print('✓ SDK initialized with custom CMAB config:');
      print('  - Cache Size: 200 decisions');
      print('  - Cache Timeout: 3600 seconds (1 hour)');
      print('  - Prediction Endpoint: https://custom-endpoint.example.com/predict/{ruleId}');

      await flutterSDK.initializeClient();

      var userContext = await flutterSDK.createUserContext(
        userId: 'user_789',
        attributes: {'country': 'us'},
      );

      if (userContext == null) return;

      // Make decision with custom config
      var decision = await userContext.decideAsync(
        CMAB_FLAG_KEY,
        {OptimizelyDecideOption.ignoreUserProfileService},
      );

      print('\n✓ Decision made with custom cache settings:');
      print('  - Variation: ${decision.decision?.variationKey}');
      print('  - This decision will be cached for 1 hour');
      print('  - Cache can store up to 200 user decisions');

    } catch (e) {
      print('Error in customCmabConfigExample: $e');
    }
  }

  /// Example 4: Combining CMAB options with other decide options
  ///
  /// This example shows how to use CMAB cache options together with
  /// other OptimizelyDecideOption values like includeReasons
  static Future<void> combinedOptionsExample() async {
    print('\n========== Example 4: Combined Options ==========');

    try {
      var flutterSDK = OptimizelyFlutterSdk(
        SDK_KEY,
        cmabConfig: CmabConfig(),
      );

      await flutterSDK.initializeClient();

      var userContext = await flutterSDK.createUserContext(
        userId: 'user_999',
        attributes: {'country': 'us'},
      );

      if (userContext == null) return;

      // Combine ignoreCmabCache with includeReasons and ignoreUserProfileService
      // This gives you a fresh decision with detailed reasoning
      print('\nCombining ignoreCmabCache + includeReasons + ignoreUserProfileService:');
      var decision = await userContext.decideAsync(
        CMAB_FLAG_KEY,
        {
          OptimizelyDecideOption.ignoreCmabCache,
          OptimizelyDecideOption.includeReasons,
          OptimizelyDecideOption.ignoreUserProfileService,
        },
      );

      print('✓ Decision with combined options:');
      print('  - Variation: ${decision.decision?.variationKey}');
      print('  - Enabled: ${decision.decision?.enabled}');

      if (decision.decision?.reasons != null &&
          decision.decision!.reasons.isNotEmpty) {
        print('  - Reasons:');
        for (var reason in decision.decision!.reasons) {
          print('    • $reason');
        }
      }

      // Another combination: resetCmabCache + excludeVariables + ignoreUserProfileService
      print('\nCombining resetCmabCache + excludeVariables + ignoreUserProfileService:');
      var decision2 = await userContext.decideAsync(
        CMAB_FLAG_KEY,
        {
          OptimizelyDecideOption.resetCmabCache,
          OptimizelyDecideOption.excludeVariables,
          OptimizelyDecideOption.ignoreUserProfileService,
        },
      );

      print('✓ Decision without variables:');
      print('  - Variation: ${decision2.decision?.variationKey}');
      print('  - Variables excluded: ${decision2.decision?.variables.isEmpty}');

    } catch (e) {
      print('Error in combinedOptionsExample: $e');
    }
  }

 static Future<void> testInvalidateUserCmabCacheOption() async {
    try {
      final sdk = OptimizelyFlutterSdk(SDK_KEY, cmabConfig: CmabConfig(), defaultLogLevel: OptimizelyLogLevel.debug,  logger: CustomLogger());
      await sdk.initializeClient();

      // Create two users and populate cache
      const Map<String, dynamic> cmabAttrUS = {'country': 'us'};
      const user1Id = 'user_invalidate_1';
      final user1Context = (await sdk.createUserContext(
        userId: user1Id,
        attributes: cmabAttrUS,
      ))!;

      const user2Id = 'user_invalidate_2';
      final user2Context = (await sdk.createUserContext(
        userId: user2Id,
        attributes: cmabAttrUS,
      ))!;
      
      // Populate cache for both users
      await user1Context.decideAsync(
        CMAB_FLAG_KEY,
        {
          OptimizelyDecideOption.ignoreUserProfileService,
          OptimizelyDecideOption.includeReasons,
        },
      );

      await user2Context.decideAsync(
        CMAB_FLAG_KEY,
        {
          OptimizelyDecideOption.ignoreUserProfileService,
          OptimizelyDecideOption.includeReasons,
        },
      );

      // Invalidate cache for user1 only
      await user1Context.decideAsync(
        CMAB_FLAG_KEY,
        {
          OptimizelyDecideOption.ignoreUserProfileService,
          OptimizelyDecideOption.includeReasons,
          OptimizelyDecideOption.invalidateUserCmabCache,
        },
      );

    //  User2's call should still use cache (not affected by user1 invalidation)
      await user2Context.decideAsync(
        CMAB_FLAG_KEY,
        {
          OptimizelyDecideOption.ignoreUserProfileService,
          OptimizelyDecideOption.includeReasons,
        },
      );

    } catch (e) {
      print('Error in testInvalidateUserCmabCacheOption: $e');
    } 
  }
  /// Run all CMAB examples sequentially
  ///
  /// This runs all the example methods in order, demonstrating
  /// the complete CMAB API functionality
  static Future<void> runAllCmabExamples() async {
    print('\n╔════════════════════════════════════════════════════════╗');
    print('║  CMAB API Examples - Optimizely Flutter SDK           ║');
    print('╚════════════════════════════════════════════════════════╝');

    print('\nIMPORTANT: Update SDK_KEY and CMAB_FLAG_KEY constants');
    print('in sample_api.dart before running these examples.\n');

    try {
      await basicCmabExample();
      await Future.delayed(Duration(seconds: 1)); // Pause between examples

      await cmabCacheOptionsExample();
      await Future.delayed(Duration(seconds: 1));

      await customCmabConfigExample();
      await Future.delayed(Duration(seconds: 1));

      await combinedOptionsExample();

      await Future.delayed(Duration(seconds: 1));
      await testInvalidateUserCmabCacheOption();

      print('\n╔════════════════════════════════════════════════════════╗');
      print('║  All CMAB Examples Completed Successfully! ✓          ║');
      print('╚════════════════════════════════════════════════════════╝\n');

    } catch (e) {
      print('\n✗ Error running CMAB examples: $e');
    }
  }
}
