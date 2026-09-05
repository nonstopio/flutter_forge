import 'dart:async';

import 'dart:developer' as dev;

import 'package:di/src/dependency_injection.dart';
import 'package:get_it/get_it.dart';

/// Implementation of DependencyInjection using GetIt
class GetItDependencyInjection implements DependencyInjection {
  final GetIt _getIt;
  final Map<Type, DisposeFunc> _disposeFunctions = {};
  final Map<Type, Object> _registeredInstances = {};

  /// Creates a new instance with optional GetIt instance
  /// If no instance is provided, uses GetIt.instance
  GetItDependencyInjection({GetIt? getIt}) : _getIt = getIt ?? GetIt.instance;

  @override
  Future<void> init() async {
    // GetIt doesn't require explicit initialization
    // but we can use this to set up any global configurations
  }

  @override
  Future<void> dispose() async {
    // Call dispose functions for all registered instances
    for (final entry in _disposeFunctions.entries) {
      final type = entry.key;
      final disposeFunc = entry.value;
      final instance = _registeredInstances[type];

      if (instance != null) {
        try {
          await disposeFunc(instance);
        } catch (e) {
          // Log error but continue disposing other instances
          dev.log(
            'Error disposing instance of type $type',
            name: 'di',
            error: e,
          );
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

    // Call dispose function if it exists
    final disposeFunc = _disposeFunctions[T];
    if (disposeFunc != null) {
      try {
        final registeredInstance = instance ?? _registeredInstances[T];
        if (registeredInstance != null) {
          await disposeFunc(registeredInstance);
        }
      } catch (e) {
        // Log error but continue with unregistration
        dev.log('Error disposing instance of type $T', name: 'di', error: e);
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
  Future<void> reset() async {
    await dispose();
    await init();
  }

  /// Get the underlying GetIt instance (for advanced usage)
  GetIt get getIt => _getIt;
}
