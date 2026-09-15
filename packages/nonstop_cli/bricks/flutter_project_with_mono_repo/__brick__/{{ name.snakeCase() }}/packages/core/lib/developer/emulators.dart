{{#emulators}}{{#auth}}import 'package:firebase_auth/firebase_auth.dart';
{{/auth}}{{#firestore}}import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
{{/firestore}}import 'package:core/logger/logger.dart';
import 'package:di/di.dart';
import 'package:flutter/foundation.dart';

/// Points every Firebase SDK at the local emulator suite.
///
/// Ports match the defaults in `firebase.json`; change both together.
Future<void> init({String? host}) async {
  final logger = di.get<Logger>();
  final emulatorHost = host ?? (!kIsWeb && defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost');
  logger.i('Using Firebase emulators');
  try {
{{#auth}}    await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
{{/auth}}{{#firestore}}    FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
    FirebaseFunctions.instance.useFunctionsEmulator(emulatorHost, 5001);
{{/firestore}}    logger.i('Successfully initialised the Firebase emulators');
  } catch (error, stackTrace) {
    logger.e('Failed to initialise the Firebase emulators:', error, stackTrace);
    rethrow;
  }
}
{{/emulators}}{{^emulators}}/// No Firebase services are enabled in this project, so there is nothing to
/// point at an emulator. Kept as a no-op so bootstrap stays uniform.
Future<void> init({String? host}) async {}
{{/emulators}}
