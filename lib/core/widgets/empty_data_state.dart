import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme_extensions.dart';

class EmptyDataState extends StatelessWidget {
  final String title;
  final String? hint;
  final IconData icon;
  final bool centered;
  final EdgeInsetsGeometry padding;

  const EmptyDataState({
    super.key,
    this.title = 'No hay datos',
    this.hint,
    this.icon = Icons.inbox_outlined,
    this.centered = false,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: centered
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.bgSubtle,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderColor),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: context.textSecondary, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 6),
            Text(
              hint!,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                height: 1.45,
                color: context.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );

    if (centered) {
      return Center(child: content);
    }

    return content;
  }
}
