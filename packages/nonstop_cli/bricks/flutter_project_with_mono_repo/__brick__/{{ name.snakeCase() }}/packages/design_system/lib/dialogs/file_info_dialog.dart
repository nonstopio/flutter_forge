import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FileInfoDialog extends StatelessWidget {
  final File file;

  const FileInfoDialog({super.key, required this.file});

  static Future<void> show(BuildContext context, File file) {
    return showDialog<void>(
      context: context,
      builder: (context) => FileInfoDialog(file: file),
    );
  }

  String _getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'JPEG Image';
      case 'png':
        return 'PNG Image';
      case 'gif':
        return 'GIF Image';
      case 'webp':
        return 'WebP Image';
      case 'bmp':
        return 'BMP Image';
      case 'tiff':
      case 'tif':
        return 'TIFF Image';
      case 'heic':
      case 'heif':
        return 'HEIF Image';
      default:
        return 'Image File';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    bool isPath = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    value,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontFamily: isPath ? 'monospace' : null,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.copy,
                size: 16,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Get file info
    final fileStat = file.statSync();
    final fileSize = fileStat.size;
    final fileName = file.path.split('/').last;
    final fileExtension = fileName.split('.').last.toLowerCase();
    final fileType = _getFileType(fileExtension);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'File Information',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.image_outlined,
                      label: 'File Name',
                      value: fileName,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      onTap: () =>
                          _copyToClipboard(context, fileName, 'File name'),
                    ),
                    _buildInfoRow(
                      icon: Icons.category_outlined,
                      label: 'File Type',
                      value: fileType,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      onTap: () =>
                          _copyToClipboard(context, fileType, 'File type'),
                    ),
                    _buildInfoRow(
                      icon: Icons.extension_outlined,
                      label: 'File Extension',
                      value: '.$fileExtension',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      onTap: () => _copyToClipboard(
                        context,
                        '.$fileExtension',
                        'File extension',
                      ),
                    ),
                    _buildInfoRow(
                      icon: Icons.storage_outlined,
                      label: 'File Size',
                      value: _formatFileSize(fileSize),
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      onTap: () => _copyToClipboard(
                        context,
                        _formatFileSize(fileSize),
                        'File size',
                      ),
                    ),
                    _buildInfoRow(
                      icon: Icons.folder_outlined,
                      label: 'File Path',
                      value: file.path,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      isPath: true,
                      onTap: () =>
                          _copyToClipboard(context, file.path, 'File path'),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tap any field to copy to clipboard',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
