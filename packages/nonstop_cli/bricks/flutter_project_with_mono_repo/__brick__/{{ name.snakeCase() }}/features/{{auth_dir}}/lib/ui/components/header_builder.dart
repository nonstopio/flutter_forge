import 'package:design_system/design_system.dart' as ds;
import 'package:flutter/widgets.dart';

/// Banner shown above the sign-in and register forms.
///
/// Swap this for your own artwork: add it under the app's `assets:` in
/// pubspec.yaml and switch to `ds.HeaderType.asset` with an `assetPath`.
Widget headerBuilder(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(8),
    child: ds.Header(
      imageUrl: 'https://picsum.photos/1200/300',
    ),
  );
}
