# Optimizely Flutter SDK Changelog
## [1.0.0-beta] - November 3rd, 2022
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
