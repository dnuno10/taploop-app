import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../features/card/models/social_link_model.dart';
import '../../features/card/models/contact_item_model.dart';
import '../theme/app_colors.dart';

class PlatformIcon extends StatelessWidget {
  final SocialPlatform? platform;
  final ContactType? contactType;
  final double size;
  final bool framed;
  final Color? color;

  const PlatformIcon.social({
    super.key,
    required this.platform,
    this.size = 20,
    this.framed = true,
    this.color,
  }) : contactType = null;

  const PlatformIcon.contact({
    super.key,
    required this.contactType,
    this.size = 20,
    this.framed = true,
    this.color,
  }) : platform = null;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? _color;
    if (!framed) {
      return _brandIcon != null
          ? FaIcon(_brandIcon, size: size, color: iconColor)
          : Icon(_materialIcon, size: size, color: iconColor);
    }

    return Container(
      width: size + 16,
      height: size + 16,
      decoration: BoxDecoration(
        color: iconColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: _brandIcon != null
            ? FaIcon(_brandIcon, size: size, color: Colors.white)
            : Icon(_materialIcon, size: size, color: Colors.white),
      ),
    );
  }

  FaIconData? get _brandIcon {
    if (contactType != null) {
      switch (contactType!) {
        case ContactType.whatsapp:
          return FontAwesomeIcons.whatsapp;
        case ContactType.phone:
        case ContactType.email:
        case ContactType.address:
        case ContactType.website:
          return null;
      }
    }
    switch (platform!) {
      case SocialPlatform.linkedin:
        return FontAwesomeIcons.linkedinIn;
      case SocialPlatform.instagram:
        return FontAwesomeIcons.instagram;
      case SocialPlatform.facebook:
        return FontAwesomeIcons.facebookF;
      case SocialPlatform.tiktok:
        return FontAwesomeIcons.tiktok;
      case SocialPlatform.twitter:
        return FontAwesomeIcons.xTwitter;
      case SocialPlatform.youtube:
        return FontAwesomeIcons.youtube;
      case SocialPlatform.github:
        return FontAwesomeIcons.github;
      case SocialPlatform.calendly:
      case SocialPlatform.custom:
        return null;
    }
  }

  IconData get _materialIcon {
    if (contactType != null) {
      switch (contactType!) {
        case ContactType.phone:
          return Icons.phone_outlined;
        case ContactType.email:
          return Icons.mail_outline;
        case ContactType.address:
          return Icons.place_outlined;
        case ContactType.website:
          return Icons.language_outlined;
        case ContactType.whatsapp:
          return Icons.chat_outlined;
      }
    }
    switch (platform!) {
      case SocialPlatform.calendly:
        return Icons.calendar_today_outlined;
      case SocialPlatform.custom:
        return Icons.link;
      case SocialPlatform.linkedin:
      case SocialPlatform.instagram:
      case SocialPlatform.facebook:
      case SocialPlatform.tiktok:
      case SocialPlatform.twitter:
      case SocialPlatform.youtube:
      case SocialPlatform.github:
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
        return const Color(0xFF181717);
      case SocialPlatform.custom:
        return AppColors.primary;
    }
  }
}
