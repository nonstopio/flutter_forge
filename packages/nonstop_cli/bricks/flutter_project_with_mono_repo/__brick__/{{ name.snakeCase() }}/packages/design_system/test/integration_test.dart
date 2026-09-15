import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
{{#network}}import 'package:core/core.dart';
{{/network}}
import 'package:design_system/design_system.dart' as ds;
import 'package:design_system/toast/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
{{#network}}import 'package:network/network.dart';
{{/network}}
import 'package:toastification/toastification.dart';

class _File extends Mock implements File {}

class _Stat extends Mock implements FileStat {}

{{#network}}class _Tokens extends Mock implements AuthTokenProvider {}
{{/network}}

{{#network}}class _Logger extends Mock implements Logger {}
{{/network}}

void main() {
  testWidgets(
    'file dialog renders supported metadata sizes and copies each field',
    (tester) async {
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      for (final (extension, label, size, expectedSize) in [
        ('jpg', 'JPEG Image', 20, '20 B'),
        ('png', 'PNG Image', 1024, '1.0 KB'),
        ('gif', 'GIF Image', 1048576, '1.0 MB'),
        ('webp', 'WebP Image', 0, '0 B'),
        ('bmp', 'BMP Image', 0, '0 B'),
        ('tiff', 'TIFF Image', 0, '0 B'),
        ('heic', 'HEIF Image', 0, '0 B'),
        ('unknown', 'Image File', 0, '0 B'),
      ]) {
        final file = _File();
        final stat = _Stat();
        when(() => file.path).thenReturn('/fixture/image.$extension');
        when(file.statSync).thenReturn(stat);
        when(() => stat.size).thenReturn(size);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => ds.FileInfoDialog.show(context, file),
                  child: const Text('show'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();
        expect(find.text(label), findsOneWidget);
        expect(find.text(expectedSize), findsOneWidget);
        for (final field in [
          'File Name',
          'File Type',
          'File Extension',
          'File Size',
          'File Path',
        ]) {
          await tester.ensureVisible(find.text(field));
          await tester.tap(find.text(field));
          await tester.pump();
        }
        expect(copied.last, file.path);
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
        expect(find.byType(ds.FileInfoDialog), findsNothing);
      }
      expect(copied.length, 40);
    },
  );

  testWidgets(
    'image adapters expose placeholder and errors and tolerate missing header assets',
    (tester) async {
      late CachedNetworkImage image;
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              context = ctx;
              image =
                  const ds.NetworkUrlImage(
                        url: 'https://example.test/image',
                        width: 40,
                        height: 60,
                      ).build(ctx)
                      as CachedNetworkImage;
              return image.placeholder!(ctx, '');
            },
          ),
        ),
      );
      expect(image.width, 40);
      expect(find.byIcon(Icons.image), findsOneWidget);
      final error = image.errorWidget!(context, '', Exception('missing'));
      await tester.pumpWidget(MaterialApp(home: error));
      expect(find.byIcon(Icons.image), findsOneWidget);
      for (final path in [null, '', 'missing.png']) {
        await tester.pumpWidget(
          MaterialApp(
            home: ds.Header(type: ds.HeaderType.asset, assetPath: path),
          ),
        );
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.image), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final header =
                  const ds.Header(
                        imageUrl: 'https://example.test/cover',
                      ).build(context)
                      as AspectRatio;
              expect(header.aspectRatio, 4);
              expect(
                (header.child as ds.NetworkUrlImage).url,
                'https://example.test/cover',
              );
              return const SizedBox();
            },
          ),
        ),
      );
    },
  );

{{#network}}  testWidgets(
    'auth headers support missing providers, failures and stable async rebuilds',
    (tester) async {
      final tokens = _Tokens();
      when(tokens.getCurrentToken).thenReturn('cached');
      when(tokens.getValidToken).thenAnswer((_) async => 'fresh');
      Widget subject({AuthTokenProvider? provider, bool validate = false}) =>
          MaterialApp(
            home: ds.AuthHeadersBuilder(
              provider: provider,
              logger: _Logger(),
              validateToken: validate,
              builder: (_, headers) =>
                  Text(headers['Authorization'] ?? 'anonymous'),
            ),
          );
      await tester.pumpWidget(subject());
      expect(find.text('anonymous'), findsOneWidget);
      await tester.pumpWidget(subject(provider: tokens));
      expect(find.text('Bearer cached'), findsOneWidget);
      await tester.pumpWidget(subject(provider: tokens, validate: true));
      await tester.pumpAndSettle();
      await tester.pumpWidget(subject(provider: tokens, validate: true));
      await tester.pumpAndSettle();
      expect(find.text('Bearer fresh'), findsOneWidget);
      verify(tokens.getValidToken).called(1);
      when(tokens.getCurrentToken).thenThrow(StateError('unavailable'));
      await tester.pumpWidget(subject(provider: tokens));
      expect(find.text('anonymous'), findsOneWidget);
      when(tokens.getValidToken).thenThrow(StateError('unavailable'));
      await tester.pumpWidget(subject(provider: tokens, validate: true));
      await tester.pumpAndSettle();
      expect(find.text('anonymous'), findsOneWidget);
      await tester.pumpWidget(subject(validate: true));
      await tester.pumpAndSettle();
      expect(find.text('anonymous'), findsOneWidget);
    },
  );

{{/network}}  testWidgets('toast variants render their messages and dismiss cleanly', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      ToastificationWrapper(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                context = ctx;
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    final callbacks = [
      () => Toast.notification(title: 'Notice', body: 'Details'),
      () => Toast.error(context, message: 'Notice', description: 'Details'),
      () => Toast.success(context, message: 'Notice', description: 'Details'),
      () => Toast.warning(context, message: 'Notice', description: 'Details'),
    ];
    for (final show in callbacks) {
      show();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.text('Notice'),
        findsOneWidget,
        reason: 'toast variant ${callbacks.indexOf(show)}',
      );
      expect(find.text('Details'), findsOneWidget);
      toastification.dismissAll(delayForAnimation: false);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }
  });
}
