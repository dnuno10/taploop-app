import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme_extensions.dart';

class SocialDivider extends StatelessWidget {
  final String text;

  const SocialDivider({super.key, this.text = 'O continúa con'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: context.borderColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: context.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(child: Divider(color: context.borderColor, thickness: 1)),
      ],
    );
  }
}
