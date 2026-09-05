/// An optional module the mono-repo template can generate.
///
/// Each one maps to a boolean brick variable of the same [key]; the brick uses
/// it to include or skip a whole package directory and the code that wires it
/// into the app shell.
class TemplateModule {
  const TemplateModule({
    required this.key,
    required this.label,
    required this.description,
    required this.defaultValue,
    this.impliedBy = const [],
  });

  /// Brick variable name, e.g. `network`.
  final String key;

  /// Short name shown in the picker.
  final String label;

  /// One line explaining what the user gets.
  final String description;

  /// Whether the module is pre-selected.
  final bool defaultValue;

  /// Modules that cannot compile without this one.
  final List<String> impliedBy;

  /// CLI flag: `--network` / `--no-network`.
  String get flag => key.replaceAll('_', '-');

  @override
  String toString() => '$label — $description';
}

/// The modules offered when creating a mono-repo.
///
/// Order is the order they are presented in.
const templateModules = <TemplateModule>[
  TemplateModule(
    key: 'network',
    label: 'Network',
    description: 'Dio client, auth + logging interceptors, typed errors',
    defaultValue: true,
    impliedBy: ['notifications'],
  ),
  TemplateModule(
    key: 'auth',
    label: 'Authentication',
    description: 'Firebase Auth (email, Google, Apple) with route guards',
    defaultValue: true,
  ),
  TemplateModule(
    key: 'firestore',
    label: 'Cloud Firestore',
    description: 'Firestore + Cloud Functions wiring and timestamp converters',
    defaultValue: false,
  ),
  TemplateModule(
    key: 'notifications',
    label: 'Push notifications',
    description: 'FCM, permission handling, device-token registration',
    defaultValue: true,
  ),
  TemplateModule(
    key: 'analytics',
    label: 'Analytics',
    description: 'Event tracking behind a swappable client',
    defaultValue: true,
  ),
  TemplateModule(
    key: 'crashlytics',
    label: 'Crash reporting',
    description: 'Crashlytics for fatals and handled errors',
    defaultValue: true,
  ),
  TemplateModule(
    key: 'feature_flags',
    label: 'Feature flags',
    description: 'Remote Config flags with a widget wrapper',
    defaultValue: true,
    impliedBy: ['developer'],
  ),
  TemplateModule(
    key: 'developer',
    label: 'Developer tools',
    description: 'In-app logs and flag inspector behind a hidden gesture',
    defaultValue: true,
  ),
  TemplateModule(
    key: 'dashboard',
    label: 'Dashboard shell',
    description: 'Bottom navigation with starter tabs and a profile tab',
    defaultValue: true,
  ),
];

/// Applies the "module A needs module B" rules to a selection.
///
/// The brick's `hooks/commands/module_vars.dart` applies the same rules, so a
/// project generated with plain `mason make` still compiles. Change both.
Map<String, bool> resolveModuleImplications(Map<String, bool> selection) {
  final resolved = Map<String, bool>.from(selection);
  for (final module in templateModules) {
    if (module.impliedBy.any((other) => resolved[other] ?? false)) {
      resolved[module.key] = true;
    }
  }
  return resolved;
}
