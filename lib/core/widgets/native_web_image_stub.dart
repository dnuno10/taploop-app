import 'package:flutter/material.dart';

class NativeWebImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Widget? fallback;
  final bool eager;
  final bool highPriority;

  const NativeWebImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.backgroundColor,
    this.fallback,
    this.eager = false,
    this.highPriority = false,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      isAntiAlias: true,
      cacheWidth: width == null
          ? null
          : (width! * MediaQuery.devicePixelRatioOf(context)).round(),
      cacheHeight: height == null
          ? null
          : (height! * MediaQuery.devicePixelRatioOf(context)).round(),
      errorBuilder: (_, __, ___) => fallback ?? const SizedBox.shrink(),
    );

    return ClipRRect(
      borderRadius: shape == BoxShape.circle
          ? BorderRadius.circular(999)
          : borderRadius ?? BorderRadius.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor, shape: shape),
        child: image,
      ),
    );
  }
}
