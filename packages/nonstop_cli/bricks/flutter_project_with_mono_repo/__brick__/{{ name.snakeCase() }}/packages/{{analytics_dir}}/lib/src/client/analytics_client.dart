import 'package:analytics/src/models/analytics_event.dart';

abstract class AnalyticsClient {
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  });

  Future<void> logCustomEvent(AnalyticsEvent event);

  Future<void> setUserId(String? userId);

  Future<void> setUserProperty({required String name, required String? value});

  Future<void> resetAnalyticsData();

  Future<void> setAnalyticsCollectionEnabled(bool enabled);

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  });

  Future<void> logAppOpen({Map<String, dynamic>? parameters});

  Future<void> logLogin({
    String? loginMethod,
    Map<String, dynamic>? parameters,
  });

  Future<void> logSignUp({
    String? signUpMethod,
    Map<String, dynamic>? parameters,
  });

  Future<void> logPurchase({
    required String currency,
    required double value,
    Map<String, dynamic>? parameters,
  });

  void dispose();
}
