# Optimizely Flutter SDK Changelog

## 3.0.0
November 28th, 2024

### Breaking Changes
* VUID configuration is now independent of ODP ([#78](https://github.com/optimizely/optimizely-flutter-sdk/pull/78))
* When VUID is disabled:
    * `vuid` is not generated or saved.
    * `client-initialized` event will not auto fired on SDK init.
    * `vuid` is not included in the odp events as a default attribute.
    * `createUserContext()` will be rejected if `userId` is not provided.

## 2.0.1
July 25, 2024

### Bug Fixes

* Migration of flutter's gradle plugins ([#74](https://github.com/optimizely/optimizely-flutter-sdk/pull/74)).

## 2.0.0
January 23, 2024

### New Features

The 2.0.0 release introduces a new primary feature, [Advanced Audience Targeting]( https://docs.developers.optimizely.com/feature-experimentation/docs/optimizely-data-platform-advanced-audience-targeting) enabled through integration with [Optimizely Data Platform (ODP)](https://docs.developers.optimizely.com/optimizely-data-platform/docs) ([#52](https://github.com/optimizely/optimizely-flutter-sdk/pull/52), [#57](https://github.com/optimizely/optimizely-flutter-sdk/pull/57), [#72](https://github.com/optimizely/optimizely-flutter-sdk/pull/72)). 

You can use ODP, a high-performance [Customer Data Platform (CDP)]( https://www.optimizely.com/optimization-glossary/customer-data-platform/), to easily create complex real-time segments (RTS) using first-party and 50+ third-party data sources out of the box. You can create custom schemas that support the user attributes important for your business, and stitch together user behavior done on different devices to better understand and target your customers for personalized user experiences. ODP can be used as a single source of truth for these segments in any Optimizely or 3rd party tool.  

With ODP accounts integrated into Optimizely projects, you can build audiences using segments pre-defined in ODP. The SDK will fetch the segments for given users and make decisions using the segments. For access to ODP audience targeting in your Feature Experimentation account, please contact your Customer Success Manager. 

This version includes the following changes: 

* New API added to `OptimizelyUserContext`: 

	- `fetchQualifiedSegments()`: this API will retrieve user segments from the ODP server. The fetched segments will be used for audience evaluation. The fetched data will be stored in the local cache to avoid repeated network delays. 

	- When an `OptimizelyUserContext` is created, the SDK will automatically send an identify request to the ODP server to facilitate observing user activities. 

* New APIs added to `OptimizelyFlutterSdk`: 

	- `sendOdpEvent()`: customers can build/send arbitrary ODP events that will bind user identifiers and data to user profiles in ODP. 

	- `createUserContext()` with anonymous user IDs: user-contexts can be created without a userId. The SDK will create and use a persistent `VUID` specific to a device when userId is not provided. 

For details, refer to our documentation pages:  

* [Advanced Audience Targeting](https://docs.developers.optimizely.com/feature-experimentation/docs/optimizely-data-platform-advanced-audience-targeting)  

* [Client SDK Support](https://docs.developers.optimizely.com/feature-experimentation/v1.0/docs/advanced-audience-targeting-for-client-side-sdks) 

* [Initialize Flutter SDK](https://docs.developers.optimizely.com/feature-experimentation/docs/initialize-sdk-flutter) 

* [OptimizelyUserContext Flutter SDK](https://docs.developers.optimizely.com/feature-experimentation/docs/optimizelyusercontext-flutter)

* [Advanced Audience Targeting segment qualification methods](https://docs.developers.optimizely.com/feature-experimentation/docs/advanced-audience-targeting-segment-qualification-methods-flutter) 

* [Send Optimizely Data Platform data using Advanced Audience Targeting](https://docs.developers.optimizely.com/feature-experimentation/docs/send-odp-data-using-advanced-audience-targeting-flutter) 


### Bug Fixes

* Crash fixed, fetchQualifiedSegments without options ([#64](https://github.com/optimizely/optimizely-flutter-sdk/pull/64)).
* Fix proguard for logback and dart version ([#68](https://github.com/optimizely/optimizely-flutter-sdk/pull/68)).

### Functionality Enhancements

* Add specific client name support to track event ([#72](https://github.com/optimizely/optimizely-flutter-sdk/pull/72)).
* Update Github Issue Templates ([#65](https://github.com/optimizely/optimizely-flutter-sdk/pull/65)).
* Add configurable log level support ([#63](https://github.com/optimizely/optimizely-flutter-sdk/pull/63)).

## 2.0.0-beta
September 21, 2023

### New Features

* Add ODP for iOS ([#52](https://github.com/optimizely/optimizely-flutter-sdk/pull/52)).
* Add ODP for Android ([#57](https://github.com/optimizely/optimizely-flutter-sdk/pull/57)).

### Bug Fixes

* Crash fixed, fetchQualifiedSegments without options ([#64](https://github.com/optimizely/optimizely-flutter-sdk/pull/64)).

### Functionality Enhancements

* Update Github Issue Templates ([#65](https://github.com/optimizely/optimizely-flutter-sdk/pull/65)).
* Add configurable log level support ([#63](https://github.com/optimizely/optimizely-flutter-sdk/pull/63)).

## 1.0.1
May 8, 2023

**Official General Availability (GA) release**

### Bug Fixes

* Fix "no serializer found" error ([#51](https://github.com/optimizely/optimizely-flutter-sdk/pull/51)).

## 1.0.1-beta
March 10, 2022

* We updated our README.md and other non-functional code to reflect that this SDK supports both Optimizely Feature Experimentation and Optimizely Full Stack. ([#44](https://github.com/optimizely/optimizely-flutter-sdk/pull/44)).

## 1.0.0-beta
November 3, 2022

**Beta release of the Optimizely X Full Stack Flutter SDK.**

### New Features
* Following are the api's added in Flutter SDK:
	- activate
	- getVariation
	- getForcedVariation
	- setForcedVariation
	- getOptimizelyConfig
	- createUserContext
	- close

* Following are the notification listener's added in Flutter SDK:
	- addActivateNotificationListener
	- addDecisionNotificationListener
	- addTrackNotificationListener
	- addLogEventNotificationListener
	- addConfigUpdateNotificationListener
	- removeNotificationListener
	- clearNotificationListeners
	- clearAllNotificationListeners

* Following are the api's added in UserContext:
	- getUserId
	- getAttributes
	- setAttributes
	- trackEvent
	- decide
	- decideForKeys
	- decideAll
	- setForcedDecision
	- getForcedDecision
	- removeForcedDecision
	- removeAllForcedDecisions
