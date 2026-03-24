import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/social_link_model.dart';
import '../../../core/widgets/platform_icon.dart';
import '../../../core/theme/app_theme_extensions.dart';

class SocialLinkTile extends StatelessWidget {
  final SocialLinkModel link;
  final VoidCallback? onTap;

  const SocialLinkTile({super.key, required this.link, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            PlatformIcon.social(platform: link.platform),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    link.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    _shortHandle(link.url),
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: context.textSecondary,
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

  /// Extracts a short handle from a URL, e.g. "@juangarcia" from
  /// "https://instagram.com/juangarcia".
  String _shortHandle(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        final handle = segments.last;
        return handle.startsWith('@') ? handle : '@$handle';
      }
    } catch (_) {}
    return url;
  }
}
