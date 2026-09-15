import 'package:auth/auth.dart';
import 'package:auth/ui/components/footer_builder.dart';
import 'package:core/core.dart' as core;
import 'package:di/di.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _User extends Mock implements User {}

class _UserInfo extends Mock implements UserInfo {}

class _Credential extends Mock implements UserCredential {}

class _AuthService extends Mock implements AuthService {}

void main() {
  setUp(core.init);
  tearDown(di.reset);

  test(
    'provider analytics handles every supported method and empty identities',
    () async {
      expect(AuthAnalytics.getAuthMethod(null), 'email');
      expect(AuthAnalytics.getAuthMethod([]), 'email');
      for (final provider in ['google.com', 'apple.com', 'password']) {
        final info = _UserInfo();
        when(() => info.providerId).thenReturn(provider);
        expect(
          AuthAnalytics.getAuthMethod([info]),
          provider == 'password' ? 'email' : provider.split('.').first,
        );
      }
      await AuthAnalytics.logSignInSuccess(
        method: 'email',
        userEmail: 'person@example.test',
      );
      await AuthAnalytics.logSignUpSuccess(method: 'email');
      await AuthAnalytics.logUserCreationSuccess(method: 'email');
      await AuthAnalytics.logAuthError(errorType: 'test', flowType: 'sign_in');
      await AuthAnalytics.logSignOutError(errorMessage: 'test');
      await AuthAnalytics.logSignOutSuccess();
    },
  );

  testWidgets(
    'auth screen adapters wire headers, footers and SDK state actions',
    (tester) async {
      late BuildContext context;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (ctx, _) {
              context = ctx;
              return const SizedBox();
            },
          ),
          GoRoute(
            path: AuthRoutes.forgotPassword,
            builder: (_, state) =>
                Text(state.uri.queryParameters['email'] ?? ''),
          ),
          GoRoute(
            path: AuthRoutes.signIn,
            builder: (_, _) => const Text('sign-in route'),
          ),
          GoRoute(
            path: AuthRoutes.signUp,
            builder: (_, _) => const Text('sign-up route'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      var signedIn = 0;
      var signedUp = 0;
      final routes = AuthRouter(
        onSignedIn: (_) {},
        onSignedUp: (_) {},
      ).routes.whereType<GoRoute>().toList();
      final state = GoRouterState.of(context);
      expect(routes[0].builder!(context, state), isA<SignInScreen>());
      expect(routes[1].builder!(context, state), isA<RegisterScreen>());
      expect(
        (routes[2].builder!(context, state) as ForgotPasswordScreen).email,
        isNull,
      );
      final signIn =
          SignInScreen(onSignedIn: (_) => signedIn++).build(context)
              as ui.SignInScreen;
      final register =
          RegisterScreen(onSignedUp: (_) => signedUp++).build(context)
              as ui.RegisterScreen;
      final recovery =
          const ForgotPasswordScreen(
                email: 'person@example.test',
              ).build(context)
              as ui.ForgotPasswordScreen;
      expect(recovery.email, 'person@example.test');
      final user = _User();
      final credential = _Credential();
      when(() => user.providerData).thenReturn([]);
      when(() => user.email).thenReturn('person@example.test');
      when(() => credential.user).thenReturn(user);
      for (final actions in [signIn.actions, register.actions!]) {
        actions
            .whereType<ui.AuthStateChangeAction<ui.SignedIn>>()
            .single
            .invoke(context, ui.SignedIn(user));
        actions
            .whereType<ui.AuthStateChangeAction<ui.UserCreated>>()
            .single
            .invoke(context, ui.UserCreated(credential));
        actions
            .whereType<ui.AuthStateChangeAction<ui.AuthFailed>>()
            .single
            .invoke(context, ui.AuthFailed(Exception('test')));
      }
      await tester.pump();
      expect(signedIn, 2);
      expect(signedUp, 2);
      signIn.actions.whereType<ui.ForgotPasswordAction>().single.callback(
        context,
        'person@example.test',
      );
      await tester.pumpAndSettle();
      expect(find.text('person@example.test'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      // Validate our builders independently of Firebase UI's platform implementation.
      final widgets = [
        signIn.headerBuilder!(context, const BoxConstraints(), 0),
        register.headerBuilder!(context, const BoxConstraints(), 0),
        recovery.headerBuilder!(context, const BoxConstraints(), 0),
        signIn.footerBuilder!(context, ui.AuthAction.signIn),
        register.footerBuilder!(context, ui.AuthAction.signUp),
      ];
      for (final widget in widgets) {
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    },
  );

  for (final signedIn in [null, false, true]) {
    testWidgets('route guard handles registered identity $signedIn', (
      tester,
    ) async {
      if (signedIn != null) {
        final service = _AuthService();
        when(() => service.isSignedIn).thenReturn(signedIn);
        di.register<AuthService>(service);
      }
      final router = GoRouter(
        initialLocation: '/private',
        routes: [
          GoAuthRoute(
            path: '/private',
            builder: (_, _) => const Text('private'),
          ),
          GoRoute(
            path: AuthRoutes.signIn,
            builder: (_, _) => const Text('login'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text(signedIn == true ? 'private' : 'login'), findsOneWidget);
    });
  }

  testWidgets('footers navigate to the opposite authentication route', (
    tester,
  ) async {
    for (final type in FooterType.values) {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, _) => Scaffold(
              body: footerBuilder(context, ui.AuthAction.signIn, type),
            ),
          ),
          GoRoute(
            path: AuthRoutes.signIn,
            builder: (_, _) => const Text('login destination'),
          ),
          GoRoute(
            path: AuthRoutes.signUp,
            builder: (_, _) => const Text('register destination'),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GestureDetector).last);
      await tester.pumpAndSettle();
      expect(
        find.text(
          type == FooterType.signIn
              ? 'register destination'
              : 'login destination',
        ),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    }
  });
}
