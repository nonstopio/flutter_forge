import 'package:di/di.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _Service {}

void main() {
  late GetItDependencyInjection container;
  setUp(
    () => container = GetItDependencyInjection(getIt: GetIt.asNewInstance()),
  );
  tearDown(() => container.dispose());

  test(
    'disposes dependents first, awaits cleanup and continues after failures',
    () async {
      final order = <String>[];
      container.register<String>(
        'service',
        dispose: (_) async {
          order.add('service');
        },
      );
      container.register<int>(
        1,
        dispose: (_) async {
          order.add('repository');
          throw StateError('cleanup');
        },
      );
      container.register<bool>(
        true,
        dispose: (_) async {
          order.add('controller');
        },
      );
      await container.reset();
      expect(order, ['controller', 'repository', 'service']);
      expect(container.has<int>(), isFalse);
      await container.reset();
      expect(order, hasLength(3));
    },
  );

  test('unregister cleanup failure still removes the registration', () async {
    container.register<String>(
      'value',
      dispose: (_) => throw StateError('cleanup'),
    );
    await container.unregister<String>(null);
    expect(container.has<String>(), isFalse);
  });

  test('wrong-instance unregistration has no disposal side effects', () async {
    final first = _Service();
    var disposed = false;
    container.register<_Service>(
      first,
      dispose: (_) {
        disposed = true;
      },
    );
    await expectLater(
      container.unregister<_Service>(_Service()),
      throwsArgumentError,
    );
    expect(container.get<_Service>(), same(first));
    expect(disposed, isFalse);
    await container.unregister<_Service>(first);
    expect(disposed, isTrue);
  });
}
