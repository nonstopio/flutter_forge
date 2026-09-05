import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkUrlImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? boxFit;

  const NetworkUrlImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.boxFit = BoxFit.cover,
  });

  @override
  Widget build(final BuildContext context) => CachedNetworkImage(
    imageUrl: url,
    placeholder: (final context, final __) {
      final theme = Theme.of(context);

      return Container(
        color: theme.colorScheme.surface,
        width: width,
        height: height,
        child: Icon(
          Icons.image,
          size: min(width ?? 32, height ?? 32),
          color: theme.cardColor,
        ),
      );
    },
    width: width,
    height: height,
    fit: boxFit,
    fadeOutDuration: const Duration(),
    fadeInDuration: const Duration(),
    errorWidget: (final context, final url, final error) =>
        Icon(Icons.image, size: 32),
  );
}
