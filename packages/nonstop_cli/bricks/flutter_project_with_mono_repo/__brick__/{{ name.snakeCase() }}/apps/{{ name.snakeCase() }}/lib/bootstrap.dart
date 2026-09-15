{{#analytics}}import 'package:analytics/analytics.dart' as analytics;
{{/analytics}}
{{#auth}}import 'package:auth/auth.dart' as auth;
{{/auth}}
import 'package:bloc/bloc.dart';
import 'package:core/core.dart' as core;
{{#firebase}}import 'package:core/developer/emulators.dart' as emulators;
{{/firebase}}
import 'package:core/logger/logger.dart';
{{#crashlytics}}import 'package:crashlytics/crashlytics.dart' as crashlytics;
{{/crashlytics}}
import 'package:di/di.dart';
{{#notifications}}import 'package:design_system/toast/toasts.dart';
{{/notifications}}
{{#feature_flags}}import 'package:feature_flags/feature_flags.dart' as feature_flags;
{{/feature_flags}}
{{#firebase}}import 'package:firebase_core/firebase_core.dart';
{{/firebase}}
import 'package:flutter/widgets.dart';
{{#network}}import 'package:network/network.dart' as network;
{{/network}}
{{#notifications}}import 'package:notifications/notifications.dart' as notifications;
{{/notifications}}
{{#firebase}}import 'package:{{name.snakeCase()}}/firebase_options.dart';
{{/firebase}}

/// Brings every module up, in dependency order, before the first frame.
///
/// Order matters: the logger is registered first so everything after it can
/// report failures, and Firebase must be live before any Firebase-backed
/// module initialises. If `flutterfire configure` has not been run yet, those
/// modules are skipped so the rest of the app still boots.
Future<void> init({
  void Function(String route)? onOpenRoute,
{{#firebase}}  FirebaseOptions? firebaseOptions,
  bool useEmulators = core.Environment.useEmulators,
{{/firebase}}
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final stopwatch = Stopwatch()..start();

  await core.init();
  final logger = di.get<Logger>();
  logger.i('Core ready in ${stopwatch.elapsedMilliseconds} ms');

  Bloc.observer = core.CoreBlocObserver();

{{#firebase}}  var firebaseReady = false;
  FirebaseOptions? resolvedOptions;
  try {
    resolvedOptions = firebaseOptions ?? DefaultFirebaseOptions.currentPlatform;
    await Firebase.initializeApp(options: resolvedOptions);
    firebaseReady = true;
    if (useEmulators) {
      await emulators.init();
    }
  } on UnsupportedError catch (error) {
    logger.w('$error');
  }
  logger.i(
    firebaseReady
        ? 'Firebase ready'
        : 'Firebase not configured yet; skipping Firebase modules',
  );

{{/firebase}}{{#crashlytics}}  if (firebaseReady) await crashlytics.init();
{{/crashlytics}}
{{#analytics}}  if (firebaseReady) await analytics.init();
{{/analytics}}
{{#feature_flags}}  if (firebaseReady) await feature_flags.init();
{{/feature_flags}}

{{#auth}}  if (firebaseReady) {
    final clientId =
        resolvedOptions!.iosClientId ?? resolvedOptions.androidClientId ?? '';
    await auth.init(auth.DefaultAuthConfig(clientId: clientId));
  }

{{/auth}}{{#network}}  await network.init(
    config: network.DefaultNetworkConfig(baseUrl: core.Environment.baseUrl),
  );

{{/network}}{{#notifications}}  if (firebaseReady) {
    await notifications.init(
      config: notifications.NotificationConfig(
        onForeground: (title, body) =>
            Toast.notification(title: title, body: body),
        onOpenRoute: onOpenRoute,
      ),
    );
  }

{{/notifications}}  // TODO: initialise your own feature modules here.

  stopwatch.stop();
  logger.i('Bootstrap completed in ${stopwatch.elapsedMilliseconds} ms');

{{#analytics}}  if (firebaseReady) {
    await analytics.AnalyticsHelper.logAppOpen(
      parameters: {'bootstrap_duration': stopwatch.elapsedMilliseconds},
    );
  }{{/analytics}}
}
