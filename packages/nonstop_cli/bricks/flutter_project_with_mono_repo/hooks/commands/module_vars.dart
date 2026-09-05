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

  // The boot test runs the real bootstrap, which a Firebase project cannot do
  // until `flutterfire configure` has been run. An empty file name makes mason
  // skip the file, so those projects simply ship without it.
  context.vars['smoke_test_file'] = usesFirebase ? '' : 'smoke_test.dart';
}
