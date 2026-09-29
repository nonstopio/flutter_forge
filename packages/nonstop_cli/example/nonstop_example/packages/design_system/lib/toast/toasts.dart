import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:toastification/toastification.dart';

class Toast {
  static void notification({required String title, required String body}) =>
      toastification.show(
        type: ToastificationType.info,
        style: ToastificationStyle.fillColored,
        title: Text(title),
        description: Text(body),
        alignment: Alignment.topCenter,
        autoCloseDuration: const Duration(seconds: 3, milliseconds: 500),
        animationBuilder: (context, animation, alignment, child) {
          return ScaleTransition(scale: animation, child: child);
        },
        icon: Icon(Iconsax.notification),
        borderRadius: BorderRadius.circular(12.0),
        showProgressBar: true,
        dragToClose: true,
        applyBlurEffect: true,
      );

  static void error(
    BuildContext context, {
    required String message,
    String? description,
  }) => toastification.show(
    context: context,
    type: ToastificationType.error,
    style: ToastificationStyle.fillColored,
    title: Text(message),
    description: description != null ? Text(description) : null,
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 3, milliseconds: 500),
    animationBuilder: (context, animation, alignment, child) {
      return ScaleTransition(scale: animation, child: child);
    },
    icon: Icon(Iconsax.warning_2),
    borderRadius: BorderRadius.circular(12.0),
    showProgressBar: true,
    dragToClose: true,
    applyBlurEffect: true,
  );

  static void success(
    BuildContext context, {
    required String message,
    String? description,
  }) => toastification.show(
    context: context,
    type: ToastificationType.success,
    style: ToastificationStyle.fillColored,
    title: Text(message),
    description: description != null ? Text(description) : null,
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 3, milliseconds: 500),
    animationBuilder: (context, animation, alignment, child) {
      return ScaleTransition(scale: animation, child: child);
    },
    icon: Icon(Iconsax.tick_circle),
    borderRadius: BorderRadius.circular(12.0),
    showProgressBar: true,
    dragToClose: true,
    applyBlurEffect: true,
  );

  static void warning(
    BuildContext context, {
    required String message,
    String? description,
  }) => toastification.show(
    context: context,
    type: ToastificationType.warning,
    style: ToastificationStyle.fillColored,
    title: Text(message),
    description: description != null ? Text(description) : null,
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 3, milliseconds: 500),
    animationBuilder: (context, animation, alignment, child) {
      return ScaleTransition(scale: animation, child: child);
    },
    icon: Icon(Iconsax.danger),
    borderRadius: BorderRadius.circular(12.0),
    showProgressBar: true,
    dragToClose: true,
    applyBlurEffect: true,
  );
}
