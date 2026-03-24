import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/link_stat_model.dart';
import '../../../core/theme/app_colors.dart';

class LinkStatsBar extends StatelessWidget {
  final LinkStatModel stat;

  const LinkStatsBar({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                stat.label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            Text(
              '${stat.clicks}',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 38,
              child: Text(
                '${(stat.percentage * 100).toInt()}%',
                style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.grey),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: stat.percentage,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              _platformColor(stat.platform),
            ),
          ),
        ),
      ],
    );
  }

  Color _platformColor(String platform) {
    switch (platform) {
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'instagram':
        return const Color(0xFFE1306C);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'tiktok':
        return const Color(0xFF010101);
      case 'twitter':
        return const Color(0xFF000000);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'whatsapp':
        return const Color(0xFF25D366);
      case 'email':
        return AppColors.primary;
      case 'website':
        return const Color(0xFF7B61FF);
      default:
        return AppColors.primary;
    }
  }
}
