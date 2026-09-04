import 'package:di/di.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

// Test classes for dependency injection
class TestService {
  final String name;
  bool isDisposed = false;

  TestService(this.name);

  void dispose() {
    isDisposed = true;
  }
}

class TestRepository {
  final TestService service;
  bool isDisposed = false;

  TestRepository(this.service);

  void dispose() {
    isDisposed = true;
  }
}

void main() {
  group('GetItDependencyInjection', () {
    late GetItDependencyInjection di;
    late GetIt testGetIt;

    setUp(() {
      // Create a separate GetIt instance for testing
      testGetIt = GetIt.asNewInstance();
      di = GetItDependencyInjection(getIt: testGetIt);
    });

    tearDown(() async {
      await di.dispose();
    });

    group('Registration', () {
      setUp(() async {
        await di.init();
      });

      test('should register and retrieve instances', () async {
        final service = TestService('test');

        di.register<TestService>(service);

        expect(di.has<TestService>(), true);
        final retrieved = di.get<TestService>();
        expect(retrieved, same(service));
        expect(retrieved.name, 'test');
      });

      test('should register with dispose function', () async {
        final service = TestService('test');
        bool disposeCalled = false;

        di.register<TestService>(
          service,
          dispose: (instance) {
            disposeCalled = true;
            instance.dispose();
          },
        );

        expect(di.has<TestService>(), true);
        await di.unregister<TestService>(null);

        expect(disposeCalled, true);
        expect(service.isDisposed, true);
        expect(di.has<TestService>(), false);
      });
    });

    group('Error handling', () {
      test('registering before init() is allowed', () {
        // init() exists for symmetry with dispose(); GetIt needs no setup, so
        // registration works straight away.
        final service = TestService('test');

        di.register<TestService>(service);

        expect(di.get<TestService>(), same(service));
      });

      test('should throw when getting before initialization', () {
        expect(() => di.get<TestService>(), throwsA(isA<StateError>()));
      });

      test('should return false when not initialized', () {
        expect(di.has<TestService>(), false);
      });
    });

    group('Retrieval', () {
      setUp(() async {
        await di.init();
      });

      test('should get registered instances', () {
        final service = TestService('test');
        di.register<TestService>(service);

        final retrieved = di.get<TestService>();
        expect(retrieved, same(service));
      });

      test('should throw when getting unregistered type', () {
        expect(() => di.get<TestService>(), throwsA(isA<Object>()));
      });
    });

    group('Has/Contains', () {
      setUp(() async {
        await di.init();
      });

      test('should return true for registered types', () {
        final service = TestService('test');
        di.register<TestService>(service);

        expect(di.has<TestService>(), true);
      });

      test('should return false for unregistered types', () {
        expect(di.has<TestService>(), false);
      });
    });

    group('Unregistration', () {
      setUp(() async {
        await di.init();
      });

      test('should unregister instances', () async {
        final service = TestService('test');
        di.register<TestService>(service);

        expect(di.has<TestService>(), true);
        await di.unregister<TestService>(null);
        expect(di.has<TestService>(), false);
      });

      test('should call dispose function when unregistering', () async {
        final service = TestService('test');
        bool disposeCalled = false;

        di.register<TestService>(
          service,
          dispose: (instance) {
            disposeCalled = true;
            instance.dispose();
          },
        );

        await di.unregister<TestService>(null);

        expect(disposeCalled, true);
        expect(service.isDisposed, true);
      });

      test(
        'should handle unregistering non-existent types gracefully',
        () async {
          // Should not throw
          await di.unregister<TestService>(null);
          expect(di.has<TestService>(), false);
        },
      );

      test('should handle unregistering when not initialized', () async {
        // Should not throw
        await di.unregister<TestService>(null);
      });
    });

    group('Disposal', () {
      setUp(() async {
        await di.init();
      });

      test('should dispose all registered instances', () async {
        final service = TestService('service');
        final repository = TestRepository(service);

        di.register<TestService>(
          service,
          dispose: (instance) => instance.dispose(),
        );

        di.register<TestRepository>(
          repository,
          dispose: (instance) => instance.dispose(),
        );

        await di.dispose();

        expect(service.isDisposed, true);
        expect(repository.isDisposed, true);
        expect(di.has<TestService>(), false);
        expect(di.has<TestRepository>(), false);
      });
    });

    group('Reset', () {
      test('should reset and reinitialize', () async {
        await di.init();

        final service = TestService('test');
        di.register<TestService>(
          service,
          dispose: (instance) => instance.dispose(),
        );

        expect(di.has<TestService>(), true);

        await di.reset();

        expect(di.has<TestService>(), false);
        expect(service.isDisposed, true);
      });
    });

    group('Complex scenarios', () {
      setUp(() async {
        await di.init();
      });

      test('should handle multiple dependencies', () {
        final service = TestService('service');
        final repository = TestRepository(service);

        di.register<TestService>(service);
        di.register<TestRepository>(repository);

        expect(di.has<TestService>(), true);
        expect(di.has<TestRepository>(), true);

        final retrievedService = di.get<TestService>();
        final retrievedRepository = di.get<TestRepository>();

        expect(retrievedService, same(service));
        expect(retrievedRepository, same(repository));
        expect(retrievedRepository.service, same(service));
      });
    });
  });
}
