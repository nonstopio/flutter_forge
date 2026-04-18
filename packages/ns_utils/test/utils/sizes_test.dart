import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_utils/utils/sizes.dart' as sizes;
import 'package:ns_utils/src.dart';

class _Capture extends StatefulWidget {
  const _Capture({required this.onContext});
  final void Function(BuildContext context) onContext;
  @override
  State<_Capture> createState() => _CaptureState();
}

class _CaptureState extends State<_Capture> {
  @override
  Widget build(BuildContext context) {
    widget.onContext(context);
    return const SizedBox.shrink();
  }
}

Future<BuildContext> _build(WidgetTester tester, Size screen) async {
  BuildContext? ctx;
  tester.view.physicalSize = screen;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: _Capture(onContext: (c) => ctx = c),
      ),
    ),
  );
  return ctx!;
}

void main() {
  setUp(() {
    sizes.Sizes.initialized = false;
  });

  testWidgets('initScreenAwareSizes sets sizes for a 400-wide screen',
      (tester) async {
    final ctx = await _build(tester, const Size(400, 800));
    sizes.Sizes.initScreenAwareSizes(ctx);
    // Calling again takes the early-return path.
    sizes.Sizes.initScreenAwareSizes(ctx);
  });

  for (final w in <double>[520, 620, 900, 1200]) {
    testWidgets('initScreenAwareSizes branches for $w-wide screen',
        (tester) async {
      sizes.Sizes.initialized = false;
      final ctx = await _build(tester, Size(w, 800));
      sizes.Sizes.initScreenAwareSizes(ctx);
    });
  }
}
