import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

class DesignSystemWrapper extends StatefulWidget {
  const DesignSystemWrapper({super.key, required this.builder});

  final Widget Function(BuildContext context, ThemeData theme) builder;

  @override
  State<DesignSystemWrapper> createState() => _DesignSystemWrapperState();
}

class _DesignSystemWrapperState extends State<DesignSystemWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final materialTheme = DesignSystem(context);
    final theme = brightness != Brightness.dark
        ? materialTheme.light()
        : materialTheme.dark();

    return Theme(
      data: theme,
      child: GlobalLoaderOverlay(
        overlayColor: theme.colorScheme.surface.withValues(alpha: 0.8),
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: ToastificationWrapper(child: widget.builder(context, theme)),
      ),
    );
  }
}
