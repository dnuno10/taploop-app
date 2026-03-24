import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/contact_item_model.dart';
import '../../../core/widgets/platform_icon.dart';
import '../../../core/theme/app_theme_extensions.dart';

class ContactItemTile extends StatelessWidget {
  final ContactItemModel item;
  final VoidCallback? onTap;

  const ContactItemTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            PlatformIcon.contact(contactType: item.type),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.displayLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                  Text(
                    item.value,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: context.textMuted),
          ],
        ),
      ),
    );
  }
}
