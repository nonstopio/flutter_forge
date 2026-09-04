{{#firebase}}{{#auth}}import 'package:firebase_auth/firebase_auth.dart';
{{/auth}}{{#firestore}}import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
{{/firestore}}import 'package:core/logger/logger.dart';
import 'package:di/di.dart';

/// Points every Firebase SDK at the local emulator suite.
///
/// Ports match the defaults in `firebase.json`; change both together.
Future<void> init() async {
  final logger = di.get<Logger>();
  logger.i('Using Firebase emulators');
  try {
{{#auth}}    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
{{/auth}}{{#firestore}}    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
{{/firestore}}    logger.i('Successfully initialised the Firebase emulators');
  } catch (error, stackTrace) {
    logger.e('Failed to initialise the Firebase emulators:', error, stackTrace);
  }
}
{{/firebase}}{{^firebase}}/// No Firebase services are enabled in this project, so there is nothing to
/// point at an emulator. Kept as a no-op so bootstrap stays uniform.
Future<void> init() async {}
{{/firebase}}