import 'package:contact_permission_example/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('check and request show denied and granted permission states',
      (tester) async {
    final methods = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('nonstopio_contact_permission'), (call) async {
      methods.add(call.method);
      return call.method == 'requestPermission';
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('nonstopio_contact_permission'), null));
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Permission granted: null'), findsOneWidget);
    await tester.tap(find.text('Check Permission'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('Permission granted: false'), findsOneWidget);
    await tester.tap(find.text('Request Permission'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('Permission granted: true'), findsOneWidget);
    expect(methods, ['isPermissionGranted', 'requestPermission']);
  });
}
