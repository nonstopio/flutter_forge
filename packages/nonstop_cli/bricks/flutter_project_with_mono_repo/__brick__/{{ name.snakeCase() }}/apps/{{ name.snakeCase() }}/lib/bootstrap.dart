{{#analytics}}import 'package:analytics/analytics.dart' as analytics;
{{/analytics}}{{#auth}}import 'package:auth/auth.dart' as auth;
{{/auth}}import 'package:bloc/bloc.dart';
import 'package:core/core.dart' as core;
{{#firebase}}import 'package:core/developer/emulators.dart' as emulators;
{{/firebase}}import 'package:core/logger/logger.dart';
{{#crashlytics}}import 'package:crashlytics/crashlytics.dart' as crashlytics;
{{/crashlytics}}import 'package:di/di.dart';
{{#feature_flags}}import 'package:feature_flags/feature_flags.dart' as feature_flags;
{{/feature_flags}}{{#firebase}}import 'package:firebase_core/firebase_core.dart';
{{/firebase}}import 'package:flutter/widgets.dart';
{{#network}}import 'package:network/network.dart' as network;
{{/network}}{{#notifications}}import 'package:notifications/notifications.dart' as notifications;
{{/notifications}}{{#firebase}}import 'package:{{name.snakeCase()}}/firebase_options.dart';
{{/firebase}}
/// Brings every module up, in dependency order, before the first frame.
///
/// Order matters: the logger is registered first so everything after it can
/// report failures, and Firebase must be live before any Firebase-backed
/// module initialises.
Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  final stopwatch = Stopwatch()..start();

  await core.init();
  final logger = di.get<Logger>();
  logger.i('Core ready in ${stopwatch.elapsedMilliseconds} ms');

  Bloc.observer = core.CoreBlocObserver();
{{#firebase}}
  final options = DefaultFirebaseOptions.currentPlatform;
  await Firebase.initializeApp(options: options);

  if (core.Environment.useEmulators) {
    await emulators.init();
  }
{{/firebase}}
{{#crashlytics}}  await crashlytics.init();
{{/crashlytics}}{{#analytics}}  await analytics.init();
{{/analytics}}{{#feature_flags}}  await feature_flags.init();
{{/feature_flags}}{{#auth}}
  final clientId = options.iosClientId ?? options.androidClientId ?? '';
  await auth.init(auth.DefaultAuthConfig(clientId: clientId));
{{/auth}}{{#network}}
  await network.init(
    config: network.DefaultNetworkConfig(baseUrl: core.Environment.baseUrl),
  );
{{/network}}{{#notifications}}
  await notifications.init();
{{/notifications}}
  // TODO: initialise your own feature modules here.

  stopwatch.stop();
  logger.i('Bootstrap completed in ${stopwatch.elapsedMilliseconds} ms');
{{#analytics}}
  await analytics.AnalyticsHelper.logAppOpen(
    parameters: {'bootstrap_duration': stopwatch.elapsedMilliseconds},
  );
{{/analytics}}}
