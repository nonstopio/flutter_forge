{{#firebase}}// This file is a placeholder. Generate the real one with:
//
//   cd apps/{{name.snakeCase()}} && flutterfire configure
//
// FlutterFire overwrites this file with your project's options and also drops
// google-services.json / GoogleService-Info.plist into the native folders.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform => throw UnsupportedError(
    'Firebase has not been configured for {{name.titleCase()}}.\n'
    'Run `flutterfire configure` inside apps/{{name.snakeCase()}} '
    'to replace lib/firebase_options.dart.',
  );
}{{/firebase}}
