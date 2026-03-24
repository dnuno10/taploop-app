import 'package:flutter/material.dart';

class TapLoopLogo extends StatelessWidget {
  final double height;
  final bool showText;

  const TapLoopLogo({super.key, this.height = 30, this.showText = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/taploop-logo.png',
          height: height,
          fit: BoxFit.contain,
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Text(
            'TapLoop',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ],
    );
  }
}
