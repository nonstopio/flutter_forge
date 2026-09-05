/// {{name.titleCase()}} Localization Package
///
/// This package provides internationalization support using i69n.
/// It contains generated message classes and utilities for managing translations.
library;

// Export generated i69n messages
export 'messages.i69n.dart';

// Export localization utilities
export 'src/localization_provider.dart';

// Export global strings instance for easy access
export 'src/strings.dart';
