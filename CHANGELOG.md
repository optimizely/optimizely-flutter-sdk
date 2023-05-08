# Optimizely Flutter SDK Changelog

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
