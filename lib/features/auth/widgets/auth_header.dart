import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../../core/widgets/taploop_logo.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double logoHeight;
  final double titleFontSize;
  final double subtitleFontSize;
  final double logoBottomSpacing;
  final double titleBottomSpacing;
  final double? titleMaxWidth;
  final double? subtitleMaxWidth;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoHeight = 32,
    this.titleFontSize = 26,
    this.subtitleFontSize = 14,
    this.logoBottomSpacing = 32,
    this.titleBottomSpacing = 22,
    this.titleMaxWidth,
    this.subtitleMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TapLoopLogo(height: logoHeight),
        SizedBox(height: logoBottomSpacing),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: titleMaxWidth ?? double.infinity,
          ),
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
              height: 1.08,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: titleBottomSpacing),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: subtitleMaxWidth ?? double.infinity,
          ),
          child: Text(
            subtitle,
            style: GoogleFonts.dmSans(
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w400,
              color: context.textSecondary,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
