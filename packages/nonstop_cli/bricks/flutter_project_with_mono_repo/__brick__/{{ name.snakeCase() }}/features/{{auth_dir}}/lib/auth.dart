import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import 'package:auth/config/config.dart';
import 'package:auth/data/index.dart';
import 'package:core/logger/logger.dart';
import 'package:di/di.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
{{#network}}import 'package:network/network.dart';
{{/network}}

export 'analytics/analytics.dart';
export 'config/index.dart';
export 'constants/index.dart';
export 'data/index.dart';
export 'router/router.dart';
export 'ui/screens/index.dart';

/// Registers the auth providers and services.
///
/// Call this after `Firebase.initializeApp` and before the router is built -
/// route guards resolve [AuthService] from the locator on the first frame.
Future<void> init(
  AuthConfig config, {
  FirebaseAuth? firebaseAuth,
  void Function(List<AuthProvider>)? configureProviders,
}) async {
  final logger = di.get<Logger>();
  logger.i('Initializing Auth...');

  (configureProviders ?? FirebaseUIAuth.configureProviders)([
    EmailAuthProvider(),
    GoogleProvider(clientId: config.clientId, iOSPreferPlist: true),
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) AppleProvider(),
  ]);

  final sdk = firebaseAuth ?? FirebaseAuth.instance;
  di.register<AuthService>(AuthServiceImp(firebaseAuth: sdk, logger: logger));

{{#network}}  // The network layer reads bearer tokens through this provider, so auth has
  // to own it - registering it anywhere else risks a stale token on refresh.
  final tokens = FirebaseAuthTokenProvider(firebaseAuth: sdk, logger: logger);
  di.register<AuthTokenProvider>(tokens, dispose: (_) => tokens.dispose());

{{/network}}  logger.i('Auth initialized');
}
