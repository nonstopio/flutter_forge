import 'package:design_system/components/index.dart';
import 'package:material_ui/material_ui.dart';
import 'package:loader_overlay/loader_overlay.dart';

class Loader {
  static void show(BuildContext context) {
    context.loaderOverlay.show(
      widgetBuilder: (_) => const Center(child: DefaultLoader()),
    );
  }

  static void hide(BuildContext context) {
    context.loaderOverlay.hide();
  }
}
