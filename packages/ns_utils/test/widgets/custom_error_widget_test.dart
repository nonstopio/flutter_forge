import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_utils/widgets/custom_error_widget.dart';

class _ImageBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage(<String, dynamic>{})!;
    }
    return ByteData.sublistView(base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a3foAAAAASUVORK5CYII='));
  }
}

void main() {
  for (final showDetails in [true, false]) {
    testWidgets('error screen renders details=$showDetails and restarts on tap',
        (tester) async {
      var restarts = 0;
      await tester.pumpWidget(ScreenUtilInit(
          designSize: const Size(800, 600),
          builder: (_, child) => MaterialApp(
              home: DefaultAssetBundle(
                  bundle: _ImageBundle(),
                  child: CustomErrorWidget(
                      errorDetails:
                          FlutterErrorDetails(exception: StateError('broken')),
                      showErrorDetails: showDetails,
                      logoAsset: 'logo.png',
                      onRestart: (_) => restarts++)))));
      await tester.pumpAndSettle();
      if (showDetails) {
        expect(find.textContaining('broken'), findsWidgets);
      } else {
        expect(find.text('Abnormal Behavior!'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      }
      await tester.ensureVisible(find.text('Restart App!'));
      await tester.tap(find.text('Restart App!'));
      expect(restarts, 1);
    });
  }
}
