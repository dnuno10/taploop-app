import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/link_stat_model.dart';
import '../../card/models/contact_item_model.dart';
import '../../card/models/social_link_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../../core/widgets/platform_icon.dart';

class LinkStatsBar extends StatelessWidget {
  final LinkStatModel stat;

  const LinkStatsBar({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _LinkStatIcon(platform: stat.platform, label: stat.label),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                stat.label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context.textSecondary,
                ),
              ),
            ),
            Text(
              '${stat.clicks}',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 38,
              child: Text(
                '${(stat.percentage * 100).toInt()}%',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
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
            backgroundColor: context.borderColor,
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

class _LinkStatIcon extends StatelessWidget {
  final String platform;
  final String label;

  const _LinkStatIcon({required this.platform, required this.label});

  @override
  Widget build(BuildContext context) {
    final resolved = _resolvedValue;
    final contactType = _contactType(resolved);
    if (contactType != null) {
      return PlatformIcon.contact(
        contactType: contactType,
        size: 14,
        framed: false,
      );
    }
    return PlatformIcon.social(
      platform: _socialPlatform(resolved),
      size: 14,
      framed: false,
    );
  }

  String get _resolvedValue {
    final raw = platform.trim().toLowerCase();
    if (raw.isNotEmpty && raw != 'social' && raw != 'link') return raw;
    final text = label.trim().toLowerCase();
    if (text.contains('instagram')) return 'instagram';
    if (text.contains('facebook')) return 'facebook';
    if (text.contains('linkedin')) return 'linkedin';
    if (text.contains('tik') || text.contains('tiktok')) return 'tiktok';
    if (text.contains('twitter') || text == 'x' || text.contains('x /')) {
      return 'twitter';
    }
    if (text.contains('youtube')) return 'youtube';
    if (text.contains('github')) return 'github';
    if (text.contains('whatsapp')) return 'whatsapp';
    if (text.contains('correo') || text.contains('email')) return 'email';
    if (text.contains('tel') || text.contains('llamar')) return 'phone';
    if (text.contains('sitio') || text.contains('web')) return 'website';
    if (text.contains('dirección') || text.contains('direccion')) {
      return 'address';
    }
    if (text.contains('form') || text.contains('agenda')) return 'calendly';
    return raw;
  }

  ContactType? _contactType(String value) {
    switch (value) {
      case 'phone':
      case 'contact':
        return ContactType.phone;
      case 'whatsapp':
        return ContactType.whatsapp;
      case 'email':
        return ContactType.email;
      case 'address':
        return ContactType.address;
      case 'website':
        return ContactType.website;
      default:
        return null;
    }
  }

  SocialPlatform _socialPlatform(String value) {
    switch (value) {
      case 'instagram':
        return SocialPlatform.instagram;
      case 'facebook':
        return SocialPlatform.facebook;
      case 'tiktok':
        return SocialPlatform.tiktok;
      case 'twitter':
        return SocialPlatform.twitter;
      case 'youtube':
        return SocialPlatform.youtube;
      case 'calendly':
      case 'form':
        return SocialPlatform.calendly;
      case 'github':
        return SocialPlatform.github;
      case 'linkedin':
        return SocialPlatform.linkedin;
      default:
        return SocialPlatform.custom;
    }
  }
}
