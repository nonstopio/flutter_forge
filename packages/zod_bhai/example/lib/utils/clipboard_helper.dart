import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'form_validation_extensions.dart';

class ClipboardHelper {
  static Future<void> copyToClipboard(
    BuildContext context, 
    String text, {
    String? successMessage,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(successMessage ?? 'Copied to clipboard'),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}