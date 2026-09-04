import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AssetImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit boxFit;
  final String? package;

  const AssetImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.boxFit = BoxFit.cover,
    this.package,
  });
  @override
  Widget build(BuildContext context) {
    // if asset is svg, use SvgPicture.asset
    if (assetPath.endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        width: width,
        height: height,
        fit: boxFit,
        package: package,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image,
            size: 32,
            color: Theme.of(context).colorScheme.onSurface,
          );
        },
      );
    }

    // otherwise, use Image.asset
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: boxFit,
      package: package,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.image,
          size: 32,
          color: Theme.of(context).colorScheme.onSurface,
        );
      },
    );
  }
}
