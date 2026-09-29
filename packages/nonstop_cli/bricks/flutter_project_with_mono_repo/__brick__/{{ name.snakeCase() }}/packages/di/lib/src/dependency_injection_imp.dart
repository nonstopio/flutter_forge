import 'dart:async';

import 'dart:developer' as dev;

import 'package:di/src/dependency_injection.dart';
import 'package:get_it/get_it.dart';

/// Receives a failure thrown by a registration's dispose callback.
typedef DisposeErrorHandler = void Function(Object error, StackTrace stack);

/// Implementation of DependencyInjection using GetIt
class GetItDependencyInjection implements DependencyInjection {
  final GetIt _getIt;
  final Map<Type, DisposeFunc> _disposeFunctions = {};
  final Map<Type, Object> _registeredInstances = {};

  /// Called when a dispose callback throws; disposal carries on regardless.
  ///
  /// Defaults to `dart:developer` logging. Settable so the app can route it
  /// to its logger once one is registered, without `di` depending on it.
  DisposeErrorHandler onDisposeError;

  /// Creates a new instance with optional GetIt instance
  /// If no instance is provided, uses GetIt.instance
  GetItDependencyInjection({GetIt? getIt, DisposeErrorHandler? onDisposeError})
    : _getIt = getIt ?? GetIt.instance,
      onDisposeError = onDisposeError ?? _logDisposeError;

  static void _logDisposeError(Object error, StackTrace stack) => dev.log(
    'Error disposing a registered instance',
    name: 'di',
    error: error,
    stackTrace: stack,
  );

  @override
  Future<void> dispose() async {
    // Call dispose functions for all registered instances
    // Dependents are registered after dependencies; tear them down first.
    for (final entry in _disposeFunctions.entries.toList().reversed) {
      final type = entry.key;
      final disposeFunc = entry.value;
      final instance = _registeredInstances[type];

      if (instance != null) {
        try {
          await disposeFunc(instance);
        } catch (error, stack) {
          // Report but continue disposing other instances
          onDisposeError(error, stack);
        }
      }
    }

    // Clear dispose functions and registered instances maps
    _disposeFunctions.clear();
    _registeredInstances.clear();

    // Reset GetIt instance
    await _getIt.reset();
  }

  @override
  void register<T extends Object>(
    final T instance, {
    final DisposeFunc? dispose,
  }) {
    // Register the instance as a singleton
    _getIt.registerSingleton<T>(instance);

    // Store the instance and dispose function if provided
    _registeredInstances[T] = instance;
    if (dispose != null) {
      _disposeFunctions[T] = dispose;
    }
  }

  @override
  Future<void> unregister<T extends Object>(final T? instance) async {
    if (!_getIt.isRegistered<T>()) {
      return;
    }
    if (instance != null && !identical(instance, _getIt.get<T>())) {
      throw ArgumentError.value(
        instance,
        'instance',
        'Does not match the registered instance of $T',
      );
    }

    // Call dispose function if it exists
    final disposeFunc = _disposeFunctions[T];
    if (disposeFunc != null) {
      try {
        final registeredInstance = instance ?? _registeredInstances[T];
        if (registeredInstance != null) {
          await disposeFunc(registeredInstance);
        }
      } catch (error, stack) {
        // Report but continue with unregistration
        onDisposeError(error, stack);
      }
      _disposeFunctions.remove(T);
    }

    // Remove from our tracking
    _registeredInstances.remove(T);

    // Unregister from GetIt
    await _getIt.unregister<T>(instance: instance);
  }

  @override
  T get<T extends Object>() {
    return _getIt.get<T>();
  }

  @override
  bool has<T extends Object>() {
    return _getIt.isRegistered<T>();
  }

  @override
  Future<void> reset() => dispose();

  /// Get the underlying GetIt instance (for advanced usage)
  GetIt get getIt => _getIt;
}
