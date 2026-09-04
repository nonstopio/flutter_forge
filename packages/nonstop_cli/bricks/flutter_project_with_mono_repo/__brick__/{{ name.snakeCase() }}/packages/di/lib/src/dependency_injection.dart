import 'dart:async';

typedef DisposeFunc<T> = FutureOr Function(T param);

abstract class DependencyInjection {
  Future<void> init();

  Future<void> dispose();

  void register<T extends Object>(
    final T instance, {
    final DisposeFunc? dispose,
  });

  Future<void> unregister<T extends Object>(final T? instance);

  T get<T extends Object>();

  bool has<T extends Object>();

  Future<void> reset();
}
