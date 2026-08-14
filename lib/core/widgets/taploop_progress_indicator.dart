import 'package:flutter/material.dart';

class TapLoopProgressIndicator extends StatelessWidget {
  static const double defaultSize = 26;
  static const double defaultStrokeWidth = 2.4;

  final Color? color;

  const TapLoopProgressIndicator({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: defaultSize,
      height: defaultSize,
      child: CircularProgressIndicator(
        strokeWidth: defaultStrokeWidth,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
