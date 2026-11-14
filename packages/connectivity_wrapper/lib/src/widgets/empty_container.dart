import 'package:material_ui/material_ui.dart';

/// [EmptyContainer] is a StatelessWidget that returns a SizedBox.shrink().
///
class EmptyContainer extends StatelessWidget {
  /// [EmptyContainer] Constructor
  ///
  const EmptyContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
