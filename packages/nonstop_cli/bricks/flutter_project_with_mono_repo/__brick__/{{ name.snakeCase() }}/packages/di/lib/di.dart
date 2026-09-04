/// Dependency Injection package for {{name.titleCase()}}
///
/// This package provides a clean abstraction over dependency injection
/// using GetIt as the underlying implementation.
library;

import 'package:di/di.dart';

// Core interfaces
export 'src/dependency_injection.dart';
// GetIt implementation
export 'src/dependency_injection_imp.dart';

final di = GetItDependencyInjection();
