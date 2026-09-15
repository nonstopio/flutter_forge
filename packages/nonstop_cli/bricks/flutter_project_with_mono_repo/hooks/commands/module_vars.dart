import 'package:mason/mason.dart';

/// Optional modules, each of which maps to a directory in the brick.
///
/// A directory named `{{<module>_dir}}` renders to an empty path segment when
/// the module is off, and mason skips every file underneath it.
const optionalModules = <String>[
  'network',
  'notifications',
  'analytics',
  'crashlytics',
  'feature_flags',
  'developer',
  'auth',
  'dashboard',
];

/// Modules that cannot work without `Firebase.initializeApp`.
const _firebaseBackedModules = <String>[
  'notifications',
  'analytics',
  'crashlytics',
  'feature_flags',
  'auth',
  'firestore',
];

bool _flag(HookContext context, String key) => context.vars[key] == true;

/// Normalises the module answers and derives everything the templates read.
void resolveModuleVars(HookContext context) {
  // A module can be implied by another (dev tools read feature flags), so
  // resolve implications before deriving anything from them. `nonstop create`
  // already does this in lib/commands/create/modules.dart; it is repeated here
  // so `mason make` on its own still produces a project that compiles.
  if (_flag(context, 'developer')) context.vars['feature_flags'] = true;
  if (_flag(context, 'notifications')) context.vars['network'] = true;

  for (final module in optionalModules) {
    final enabled = _flag(context, module);
    context.vars[module] = enabled;
    context.vars['${module}_dir'] = enabled ? module : '';
  }

  context.vars['firestore'] = _flag(context, 'firestore');
  final usesFirebase =
      _firebaseBackedModules.any((module) => _flag(context, module));
  context.vars['firebase'] = usesFirebase;
  context.vars['emulators'] =
      _flag(context, 'auth') || _flag(context, 'firestore');
  context.vars['firebase_sdk_mocks'] = _firebaseBackedModules
      .where((module) => module != 'firestore')
      .any((module) => _flag(context, module));
  // Empty path segment → mason skips the file, so a project with no Firebase
  // modules never ships a placeholder `firebase_options.dart`.
  context.vars['firebase_options_file'] =
      usesFirebase ? 'firebase_options.dart' : '';

  // Every project ships an entrypoint smoke test. SDK-specific suites and
  // lifecycle adapters are omitted only when their module is absent.
  context.vars['notification_lifecycle_file'] =
      _flag(context, 'notifications') ? 'notification_lifecycle.dart' : '';
  context.vars['notification_lifecycle_test_file'] =
      _flag(context, 'notifications') ? 'notification_lifecycle_test.dart' : '';
  context.vars['firebase_bootstrap_test_file'] =
      usesFirebase ? 'firebase_bootstrap_test.dart' : '';
  context.vars['auth_token_provider_test_file'] =
      _flag(context, 'network') ? 'token_provider_test.dart' : '';
}
