# Analytics Package

A structured analytics package for {{name.titleCase()}} with Firebase Analytics integration and pluggable provider architecture.

## Features

- ✅ **Interface-based design** - Easy to switch analytics providers
- ✅ **Automatic screen tracking** - Route observer tracks navigation automatically
- ✅ **Structured event names** - Type-safe, organized event constants
- ✅ **Dependency injection** - Integrated with DI container
- ✅ **Error handling** - Graceful failures don't crash the app
- ✅ **Debug logging** - Configurable logging for development

## Quick Start

### 1. Initialize Analytics

```dart
import 'package:analytics/analytics.dart';

final analyticsConfig = DefaultAnalyticsConfig(
  enableAnalytics: true,
  enableDebugLogging: true, // Set to false in production
);
await init(config: analyticsConfig);
```

### 2. Automatic Screen Tracking

Add the `AnalyticsRouteObserver` to your router:

```dart
GoRouter(
  observers: [
    AnalyticsRouteObserver(), // Uses FirebaseAnalyticsObserver internally
  ],
  // ... routes
);
```

The `AnalyticsRouteObserver` internally uses Firebase's native `FirebaseAnalyticsObserver` for proper screen tracking while adding additional logging and error handling.

### 3. Manual Event Tracking

#### Using Structured Event Names (Recommended)

```dart
// User events
await AnalyticsHelper.logEvent(AnalyticsEvents.user.authenticatedRedirect);

// Authentication events
await AnalyticsHelper.logEvent(
  AnalyticsEvents.auth.signIn,
  parameters: {'method': 'google'},
);

// Feature usage
await AnalyticsHelper.logEvent(
  AnalyticsEvents.feature.used,
  parameters: {'feature_name': 'health_sync'},
);

// Survey events
await AnalyticsHelper.logEvent(
  AnalyticsEvents.survey.completed,
  parameters: {
    'survey_id': 'wellness_assessment',
    'duration_seconds': 120,
  },
);
```

#### Using Helper Methods

```dart
// Feature tracking
await AnalyticsHelper.logFeatureUsed('health_dashboard');

// Survey tracking
await AnalyticsHelper.logSurveyStarted('mood_tracker');
await AnalyticsHelper.logSurveyCompleted('mood_tracker', duration: 45);

// Error tracking
await AnalyticsHelper.logAppError('network_timeout');

// Button interactions
await AnalyticsHelper.logButtonPressed('start_assessment');

// Authentication events
await AnalyticsHelper.logSignIn(method: 'google');
await AnalyticsHelper.logSignUp(method: 'email');

// User management
await AnalyticsHelper.setUserId('user123');
await AnalyticsHelper.setUserProperty(name: 'plan', value: 'premium');

// App lifecycle
await AnalyticsHelper.logAppOpen();
```

#### Direct Client Usage

```dart
final analyticsClient = di.get<AnalyticsClient>();

await analyticsClient.logEvent(
  name: 'custom_event',
  parameters: {'key': 'value'},
);

await analyticsClient.setUserId('user123');
await analyticsClient.setUserProperty(name: 'plan', value: 'premium');
```

## Structured Event Names

The package provides organized, type-safe event names through `AnalyticsEvents`:

### Available Event Categories

```dart
// User-related events
AnalyticsEvents.user.authenticatedRedirect
AnalyticsEvents.user.profileUpdated
AnalyticsEvents.user.onboardingCompleted

// Authentication events
AnalyticsEvents.auth.signIn
AnalyticsEvents.auth.signUp
AnalyticsEvents.auth.signOut

// Navigation events
AnalyticsEvents.navigation.screenView
AnalyticsEvents.navigation.tabSwitched

// Feature usage
AnalyticsEvents.feature.used
AnalyticsEvents.feature.tutorialCompleted

// App lifecycle
AnalyticsEvents.app.open
AnalyticsEvents.app.background
AnalyticsEvents.app.foreground

// Survey events
AnalyticsEvents.survey.started
AnalyticsEvents.survey.completed
AnalyticsEvents.survey.abandoned

// Health data events
AnalyticsEvents.health.dataSynced
AnalyticsEvents.health.deviceConnected
AnalyticsEvents.health.goalAchieved

// Error events
AnalyticsEvents.error.appError
AnalyticsEvents.error.networkError
```

## Configuration

### AnalyticsConfig Options

```dart
final config = DefaultAnalyticsConfig(
  enableAnalytics: true,        // Enable/disable analytics collection
  enableDebugLogging: false,    // Debug logging (development only)
  userId: 'user123',           // Optional: Set initial user ID
  defaultUserProperties: {      // Optional: Default user properties
    'user_type': 'premium',
    'app_version': '1.0.0',
  },
);
```

### Environment-based Configuration

```dart
import 'package:flutter/foundation.dart';

final config = DefaultAnalyticsConfig(
  enableAnalytics: !kDebugMode,          // Disable in debug builds
  enableDebugLogging: kDebugMode,        // Debug logging in development
);
```

## Architecture

### Components

- **AnalyticsClient** - Abstract interface for analytics operations
- **FirebaseAnalyticsClient** - Firebase Analytics implementation
- **AnalyticsRouteObserver** - Automatic screen tracking
- **AnalyticsHelper** - Convenience methods for common events
- **AnalyticsEvents** - Structured event name constants

### Pluggable Design

Switch analytics providers by implementing `AnalyticsClient`:

```dart
class MixpanelAnalyticsClient implements AnalyticsClient {
  @override
  Future<void> logEvent({required String name, Map<String, dynamic>? parameters}) {
    // Mixpanel implementation
  }
  // ... other methods
}

// Register with DI
di.register<AnalyticsClient>(MixpanelAnalyticsClient(config));
```

## Best Practices

1. **Use Structured Events**: Always prefer `AnalyticsEvents.category.eventName` over string literals
2. **Include Context**: Add relevant parameters like `screen_name`, `user_id`, etc.
3. **Consistent Naming**: Use snake_case for event names and parameters
4. **Error Handling**: Analytics failures should never crash the app
5. **Privacy**: Respect user privacy settings and data regulations

## Examples

### Track User Journey

```dart
// App launch
await AnalyticsHelper.logAppOpen();

// User signs in
await AnalyticsHelper.logSignIn(method: 'google');

// User completes onboarding
await AnalyticsHelper.logEvent(
  AnalyticsEvents.user.onboardingCompleted,
  parameters: {'steps_completed': 5},
);

// User uses a feature
await AnalyticsHelper.logFeatureUsed('health_sync');

// User completes a survey
await AnalyticsHelper.logSurveyCompleted(
  'wellness_assessment',
  duration: 180,
);
```

### Error Tracking

```dart
try {
  // Some operation
} catch (error) {
  await AnalyticsHelper.logAppError(
    'api_call_failed',
    errorMessage: error.toString(),
    parameters: {
      'endpoint': '/api/health/sync',
      'user_id': userId,
    },
  );
  rethrow;
}
```

This structured approach ensures consistent, discoverable, and maintainable analytics throughout the {{name.titleCase()}} app.