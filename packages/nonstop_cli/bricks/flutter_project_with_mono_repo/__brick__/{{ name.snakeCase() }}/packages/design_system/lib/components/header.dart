import 'package:design_system/components/network_url_image.dart';
import 'package:design_system/utils/index.dart';
import 'package:flutter/material.dart';

enum HeaderType {
  image,
  asset;

  double get ratio => switch (this) {
    HeaderType.image => 4 / 1,
    HeaderType.asset => 1 / 1,
  };
}

class Header extends StatelessWidget {
  const Header({
    super.key,
    this.type = HeaderType.image,
    this.assetPath,
    this.imageUrl,
  });

  final HeaderType type;
  final String? assetPath;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(aspectRatio: type.ratio, child: _buildImage(context));
  }

  Widget _buildImage(BuildContext context) {
    switch (type) {
      case HeaderType.asset:
        return Hero(
          tag: assetPath!,
          child: Image.asset(
            assetPath!,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        );
      case HeaderType.image:
        return NetworkUrlImage(url: imageUrl.asEmptyIfNull);
    }
  }
}
