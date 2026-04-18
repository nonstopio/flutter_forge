import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ns_utils/widgets/spacers.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, _) => child,
      ),
    ),
  );
}

void main() {
  testWidgets('Padding widgets render via runtime constructors',
      (tester) async {
    final key = UniqueKey();
    await tester.pumpWidget(
      _wrap(
        ListView(
          shrinkWrap: true,
          children: [
            P1(key: key),
            P2(key: UniqueKey()),
            P5(key: UniqueKey()),
            P8(key: UniqueKey()),
            P10(key: UniqueKey()),
            PH10(key: UniqueKey()),
            P20(key: UniqueKey()),
            P30(key: UniqueKey()),
            P40(key: UniqueKey()),
          ],
        ),
      ),
    );
    expect(find.byType(Padding), findsWidgets);
  });

  testWidgets('C* spacer widgets render with color via runtime ctors',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListView(
          shrinkWrap: true,
          children: [
            C0(key: UniqueKey()),
            C1(key: UniqueKey(), color: Colors.red),
            C2(key: UniqueKey(), color: Colors.red),
            C3(key: UniqueKey(), color: Colors.red),
            C4(key: UniqueKey(), color: Colors.red),
            C5(key: UniqueKey(), color: Colors.red),
            C6(key: UniqueKey(), color: Colors.red),
            C8(key: UniqueKey(), color: Colors.red),
            C10(key: UniqueKey(), color: Colors.red),
            C15(key: UniqueKey(), color: Colors.red),
            C20(key: UniqueKey(), color: Colors.red),
            C40(key: UniqueKey(), color: Colors.red),
            C30(key: UniqueKey(), color: Colors.red),
            C50(key: UniqueKey(), color: Colors.red),
            C100(key: UniqueKey(), color: Colors.red),
            C150(key: UniqueKey(), color: Colors.red),
          ],
        ),
      ),
    );
    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('C* spacer widgets accept null color (transparent default)',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListView(
          shrinkWrap: true,
          children: [
            C1(key: UniqueKey()),
            C2(key: UniqueKey()),
            C3(key: UniqueKey()),
            C4(key: UniqueKey()),
            C5(key: UniqueKey()),
            C6(key: UniqueKey()),
            C8(key: UniqueKey()),
            C10(key: UniqueKey()),
            C15(key: UniqueKey()),
            C20(key: UniqueKey()),
            C30(key: UniqueKey()),
            C40(key: UniqueKey()),
            C50(key: UniqueKey()),
            C100(key: UniqueKey()),
            C150(key: UniqueKey()),
          ],
        ),
      ),
    );
    expect(find.byType(Container), findsWidgets);
  });
}
