import 'dart:async';

import 'package:auth/data/token/firebase_auth_token_provider.dart';
import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Auth extends Mock implements FirebaseAuth {}

class _User extends Mock implements User {}

class _Token extends Mock implements IdTokenResult {}

class _Logger extends Mock implements Logger {}

void main() {
  late _Auth auth;
  late _User user;
  late _Logger logger;
  late _Token token;
  late StreamController<User?> events;
  late FirebaseAuthTokenProvider provider;
  late DateTime now;

  setUp(() {
    auth = _Auth();
    user = _User();
    token = _Token();
    logger = _Logger();
    now = DateTime(2026);
    events = StreamController<User?>();
    when(auth.idTokenChanges).thenAnswer((_) => events.stream);
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('user-1');
    when(() => token.token).thenReturn('test-token');
    when(
      () => token.expirationTime,
    ).thenReturn(now.add(const Duration(hours: 1)));
    when(() => user.getIdTokenResult(any())).thenAnswer((_) async => token);
    when(auth.signOut).thenAnswer((_) async {});
    provider = FirebaseAuthTokenProvider(
      firebaseAuth: auth,
      logger: logger,
      now: () => now,
    );
  });
  tearDown(() async {
    await provider.dispose();
    await events.close();
  });

  test('Firebase expiration controls cached-token reuse and refresh', () async {
    expect(provider.isTokenExpired, isTrue);
    expect(provider.isAuthenticated, isTrue);
    expect(await provider.getValidToken(), 'test-token');
    expect(provider.getCurrentToken(), 'test-token');
    expect(provider.isTokenExpired, isFalse);
    expect(await provider.getValidToken(), 'test-token');
    verify(() => user.getIdTokenResult(false)).called(1);
    now = now.add(const Duration(minutes: 55));
    expect(provider.isTokenExpired, isTrue);
    await provider.getValidToken();
    verify(() => user.getIdTokenResult(false)).called(1);
    await provider.refreshToken();
    verify(() => user.getIdTokenResult(true)).called(1);
  });

  test('signed-out users have no token', () async {
    when(() => auth.currentUser).thenReturn(null);
    expect(provider.isAuthenticated, isFalse);
    expect(await provider.getValidToken(), isNull);
    expect(await provider.refreshToken(), isNull);
  });

  test('token events publish refreshed tokens and clear on sign-out', () async {
    final values = <String?>[];
    final subscription = provider.tokenStream.listen(values.add);
    events.add(user);
    await pumpEventQueue();
    expect(values, [null, 'test-token']);
    when(() => auth.currentUser).thenReturn(null);
    events.add(null);
    await pumpEventQueue();
    expect(provider.getCurrentToken(), isNull);
    expect(values.last, isNull);
    await subscription.cancel();
  });

  test('read and stream errors clear cached credentials', () async {
    await provider.getValidToken();
    when(
      () => user.getIdTokenResult(any()),
    ).thenThrow(StateError('unavailable'));
    expect(await provider.refreshToken(), isNull);
    expect(provider.getCurrentToken(), isNull);
    events.addError(StateError('stream failure'), StackTrace.current);
    await pumpEventQueue();
    expect(provider.isTokenExpired, isTrue);
  });

  test(
    'sign-out clears credentials and late refreshes cannot restore them',
    () async {
      final pending = Completer<IdTokenResult>();
      when(
        () => user.getIdTokenResult(any()),
      ).thenAnswer((_) => pending.future);
      final refresh = provider.refreshToken();
      await provider.signOut();
      pending.complete(token);
      expect(await refresh, isNull);
      expect(provider.getCurrentToken(), isNull);
      verify(auth.signOut).called(1);
    },
  );

  test('an account change invalidates an in-flight response', () async {
    final pending = Completer<IdTokenResult>();
    when(() => user.getIdTokenResult(any())).thenAnswer((_) => pending.future);
    final refresh = provider.refreshToken();
    when(() => auth.currentUser).thenReturn(null);
    pending.complete(token);
    expect(await refresh, isNull);
  });

  test('disposing during refresh closes safely and is idempotent', () async {
    final pending = Completer<IdTokenResult>();
    when(() => user.getIdTokenResult(any())).thenAnswer((_) => pending.future);
    final refresh = provider.refreshToken();
    await provider.dispose();
    pending.completeError(StateError('late error'));
    expect(await refresh, isNull);
    expect(provider.isAuthenticated, isFalse);
    expect(await provider.getValidToken(), isNull);
    expect(await provider.refreshToken(), isNull);
    await provider.dispose();
  });

  test('null token results do not throw', () async {
    when(() => token.token).thenReturn(null);
    when(() => token.expirationTime).thenReturn(null);
    expect(await provider.getValidToken(), isNull);
    expect(provider.isTokenExpired, isTrue);
  });
}
