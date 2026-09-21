import 'package:core/developer/emulators.dart' as emulators;
{{#firestore}}import 'package:cloud_firestore/cloud_firestore.dart';
{{/firestore}}
import 'package:core/core.dart';
import 'package:core/logger/talker_logger_impl.dart';
import 'package:di/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talker_flutter/talker_flutter.dart' hide TalkerRouteLog;

class _Counter extends Bloc<int, int> {
  _Counter() : super(0) {
    on<int>((event, emit) => emit(event));
  }
}

void main() {
{{#emulators}}  test('emulator setup failures are surfaced before Firebase initialization', () async {
    await expectLater(emulators.init(), throwsA(anything));
  });
{{/emulators}}
{{^emulators}}  test('emulator setup is a no-op without emulated services', emulators.init);
{{/emulators}}
  setUp(init);
  tearDown(di.reset);

  test(
    'event base defines value equality and DI exposes its configured container',
    () {
      final event = RefreshProfile();
      expect(event.props, isEmpty);
      expect(event, RefreshProfile());
      expect(di.getIt.isRegistered<Logger>(), isTrue);
    },
  );

  testWidgets('context event extension broadcasts to the owned channel', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      GlobalEventChannelProvider(
        child: Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox();
          },
        ),
      ),
    );
    context.fire(const RefreshProfile());
    await tester.pump();
    expect(
      context.read<GlobalEventChannel>().state.current,
      const RefreshProfile(),
    );
  });

  test('event channel bounds history while retaining total counts', () async {
    final channel = GlobalEventChannel(maxRecentEvents: 2);
    final states = <GlobalEventState>[];
    final subscription = channel.stream.listen(states.add);
    for (var i = 0; i < 3; i++) {
      channel.add(const FireGlobalEvent(eventType: RefreshProfile()));
    }
    await pumpEventQueue();
    expect(states, hasLength(3));
    expect(channel.state.history, hasLength(2));
    expect(channel.state.eventCounts[RefreshProfile], 3);
    expect(channel.state.current, const RefreshProfile());
    expect(channel.state.copyWith(), channel.state);
    expect(channel.state.copyWith(maxRecentEvents: 9).maxRecentEvents, 9);
    expect(const FireGlobalEvent(eventType: RefreshProfile()).props, [
      const RefreshProfile(),
    ]);
    await subscription.cancel();
    await channel.close();
  });

  testWidgets(
    'provider, builder, listener and consumer share the event channel',
    (tester) async {
      var listeners = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: GlobalEventChannelProvider(
            lazy: false,
            child: GlobalEventChannelListener(
              listener: (_, state) {
                listeners++;
              },
              child: GlobalEventChannelConsumer(
                listener: (_, state) {
                  listeners++;
                },
                builder: (_, state) => GlobalEventChannelBuilder(
                  builder: (_, state) =>
                      Text('Events: ${state.history.length}'),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Events: 0'), findsOneWidget);
      BlocProvider.of<GlobalEventChannel>(
        tester.element(find.text('Events: 0')),
      ).add(const FireGlobalEvent(eventType: RefreshProfile()));
      await tester.pumpAndSettle();
      expect(find.text('Events: 1'), findsOneWidget);
      expect(listeners, 2);
      await tester.pumpWidget(const SizedBox());
    },
  );

  test('date and string helpers handle null and valid input', () {
    final date = DateTime(2026, 1, 15, 13, 14, 15);
    expect(DateTimeConverter.toViewFormat(null), '');
    expect(DateTimeConverter.toViewFormat(date), 'January 15, 2026');
    expect(DateTimeConverter.toViewFormatWithTime(null), '');
    expect(
      DateTimeConverter.toViewFormatWithTime(date),
      'January 15, 2026, 1:14 PM',
    );
    expect(DateTimeConverter.toViewFormatTime(null), '');
    expect(DateTimeConverter.toViewFormatTime(date), '1:14:15 PM');
    expect((null as String?).asBool, isFalse);
    for (final value in ['TRUE', 'true', '1']) {
      expect(value.asBool, isTrue);
    }
    expect('false'.asBool, isFalse);
    expect(CoreException(message: 'message').message, 'message');
    expect(UserNotFoundException().message, isNotEmpty);
  });

  test(
    'timestamp adapters accept documented forms and reject invalid shapes',
    () {
      // Exercise runtime construction as well as annotation-style const use.
      // ignore: prefer_const_constructors
      final converter = TimestampConverter();
      // ignore: prefer_const_constructors
      final nullable = TimestampConverterNullable();
      final date = DateTime.utc(2026);
      expect(converter.fromJson(date.toIso8601String()).toUtc(), date);
{{#firestore}}      expect(converter.fromJson(Timestamp.fromDate(date)).toUtc(), date);
{{/firestore}}
      expect(
        converter.fromJson({
          '_seconds': 1,
          '_nanoseconds': 500000000,
        }).millisecondsSinceEpoch,
        1500,
      );
      expect(converter.toJson(date), date.toIso8601String());
      expect(converter.toJson(null), isNull);
      expect(nullable.fromJson(null), isNull);
      expect(nullable.toJson(null), isNull);
      expect(nullable.toJson(date), date.toIso8601String());
      expect(() => converter.fromJson(null), throwsArgumentError);
    },
  );

  test('logger forwards every level and exposes its adapter', () {
    final talker = Talker(settings: TalkerSettings(useConsoleLogs: false));
    final logger = TalkerLoggerImpl(talker);
    logger.d('debug');
    logger.i('info');
    logger.w('warning');
    logger.e('error');
    expect(logger.logger, same(talker));
    expect(talker.history, hasLength(4));
  });

  test(
    'observers support event, transition, error and route lifecycles',
    () async {
      final bloc = _Counter();
      final observer = CoreBlocObserver();
      observer.onEvent(bloc, 1);
      observer.onTransition(
        bloc,
        const Transition(currentState: 0, event: 1, nextState: 1),
      );
      observer.onError(bloc, StateError('test'), StackTrace.current);
      final routes = CoreRouteObserver();
      final named = MaterialPageRoute<void>(
        builder: (_) => const SizedBox(),
        settings: const RouteSettings(name: '/test', arguments: 'arg'),
      );
      final unnamed = MaterialPageRoute<void>(builder: (_) => const SizedBox());
      for (final route in [named, unnamed]) {
        routes.didPush(route, null);
        routes.didPop(route, null);
        routes.didRemove(route, null);
        routes.didReplace(newRoute: route);
      }
      routes.didReplace();
      final log = TalkerRouteLog(route: unnamed, type: RouteLogType.push);
      expect(log.key, TalkerKey.route);
      expect(log.pen, isA<AnsiPen>());
      await bloc.close();
    },
  );
}
