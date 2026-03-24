import 'package:flutter/material.dart';
import '../../features/card/models/social_link_model.dart';
import '../../features/card/models/contact_item_model.dart';
import '../theme/app_colors.dart';

class PlatformIcon extends StatelessWidget {
  final SocialPlatform? platform;
  final ContactType? contactType;
  final double size;

  const PlatformIcon.social({super.key, required this.platform, this.size = 20})
    : contactType = null;

  const PlatformIcon.contact({
    super.key,
    required this.contactType,
    this.size = 20,
  }) : platform = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 16,
      height: size + 16,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(_icon, size: size, color: Colors.white),
    );
  }

  IconData get _icon {
    if (contactType != null) {
      switch (contactType!) {
        case ContactType.phone:
          return Icons.phone_outlined;
        case ContactType.whatsapp:
          return Icons.chat_outlined;
        case ContactType.email:
          return Icons.mail_outline;
        case ContactType.address:
          return Icons.place_outlined;
        case ContactType.website:
          return Icons.language_outlined;
      }
    }
    switch (platform!) {
      case SocialPlatform.linkedin:
        return Icons.work_outline;
      case SocialPlatform.instagram:
        return Icons.camera_alt_outlined;
      case SocialPlatform.facebook:
        return Icons.facebook_outlined;
      case SocialPlatform.tiktok:
        return Icons.music_note_outlined;
      case SocialPlatform.twitter:
        return Icons.alternate_email;
      case SocialPlatform.youtube:
        return Icons.play_circle_outline;
      case SocialPlatform.calendly:
        return Icons.calendar_today_outlined;
      case SocialPlatform.github:
        return Icons.code_outlined;
      case SocialPlatform.custom:
        return Icons.link;
    }
  }

  Color get _color {
    if (contactType != null) {
      switch (contactType!) {
        case ContactType.phone:
          return const Color(0xFF1A8C4E);
        case ContactType.whatsapp:
          return const Color(0xFF25D366);
        case ContactType.email:
          return const Color(0xFFEF6820);
        case ContactType.address:
          return const Color(0xFF4A90D9);
        case ContactType.website:
          return const Color(0xFF7B61FF);
      }
    }
    switch (platform!) {
      case SocialPlatform.linkedin:
        return const Color(0xFF0A66C2);
      case SocialPlatform.instagram:
        return const Color(0xFFE1306C);
      case SocialPlatform.facebook:
        return const Color(0xFF1877F2);
      case SocialPlatform.tiktok:
        return const Color(0xFF010101);
      case SocialPlatform.twitter:
        return const Color(0xFF000000);
      case SocialPlatform.youtube:
        return const Color(0xFFFF0000);
      case SocialPlatform.calendly:
        return const Color(0xFF006BFF);
      case SocialPlatform.github:
        return const Color(0xFF171515);
      case SocialPlatform.custom:
        return AppColors.primary;
    }
  }
}
