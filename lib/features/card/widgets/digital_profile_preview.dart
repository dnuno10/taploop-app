import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/digital_card_model.dart';
import '../models/contact_item_model.dart';
import '../models/social_link_model.dart';

/// Mini phone-frame preview of the digital profile card (centralized links).
class DigitalProfilePreview extends StatelessWidget {
  final DigitalCardModel card;
  final double width;

  const DigitalProfilePreview({
    super.key,
    required this.card,
    this.width = 280,
  });

  double get _height => width * 1.95;
  double get _scale => width / 300;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          width: width,
          height: _height,
          child: Stack(
            children: [
              // Phone frame shadow
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.1),
                  ),
                ),
              ),
              // Phone bezel
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(width * 0.1),
                  ),
                ),
              ),
              // Screen area
              Positioned(
                left: width * 0.03,
                right: width * 0.03,
                top: width * 0.06,
                bottom: width * 0.04,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(width * 0.08),
                  child: _ScreenContent(card: card, scale: _scale),
                ),
              ),
              // Notch / Dynamic Island
              Positioned(
                top: width * 0.025,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: width * 0.28,
                    height: width * 0.04,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.04, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}

class _ScreenContent extends StatelessWidget {
  final DigitalCardModel card;
  final double scale;
  const _ScreenContent({required this.card, required this.scale});

  Color get _bgColor {
    switch (card.themeStyle) {
      case CardThemeStyle.dark:
      case CardThemeStyle.neon:
      case CardThemeStyle.premium:
        return const Color(0xFF0D0D0D);
      case CardThemeStyle.gradient:
        return card.backgroundColorStart ?? const Color(0xFF6C4FE8);
      case CardThemeStyle.frosted:
        return const Color(0xFFF4F4F6);
      case CardThemeStyle.retro:
        return const Color(0xFFFFF8F0);
      default:
        return Colors.white;
    }
  }

  Color get _textColor =>
      card.themeStyle == CardThemeStyle.dark ||
          card.themeStyle == CardThemeStyle.neon ||
          card.themeStyle == CardThemeStyle.premium ||
          card.themeStyle == CardThemeStyle.gradient
      ? Colors.white
      : const Color(0xFF0D0D0D);

  Color get _subColor => _textColor.withValues(alpha: 0.55);

  Color get _accentColor {
    switch (card.themeStyle) {
      case CardThemeStyle.neon:
        return const Color(0xFF00FFB2);
      case CardThemeStyle.retro:
        return const Color(0xFFE8803A);
      case CardThemeStyle.premium:
        return const Color(0xFFD4AF37);
      default:
        return card.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedContacts = card.contactItems.where((c) => c.isVisible).toList();
    sortedContacts.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final visibleContacts = sortedContacts
        .take(card.layoutStyle == CardLayoutStyle.compact ? 2 : 3)
        .toList();

    final sortedSocials = card.socialLinks.where((s) => s.isVisible).toList();
    sortedSocials.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final visibleSocials = sortedSocials.take(4).toList();
    final isCentered = card.layoutStyle == CardLayoutStyle.centered;
    final isCompact = card.layoutStyle == CardLayoutStyle.compact;
    final headerPadding = isCompact
        ? EdgeInsets.fromLTRB(12 * scale, 14 * scale, 12 * scale, 16 * scale)
        : EdgeInsets.fromLTRB(16 * scale, 20 * scale, 16 * scale, 24 * scale);

    final bgBase = card.bgColor ?? _bgColor;
    final scrollContent = SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          _buildHeaderBand(headerPadding, isCentered, isCompact),
          // Contact items
          if (visibleContacts.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(
                12 * scale,
                10 * scale,
                12 * scale,
                6 * scale,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CONTACTO',
                  style: GoogleFonts.outfit(
                    fontSize: 8 * scale,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: _textColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12 * scale, 0, 12 * scale, 0),
              child: Column(
                children: visibleContacts.map((c) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8 * scale),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * scale,
                        vertical: 8 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: _textColor.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10 * scale),
                        border: Border.all(
                          color: _textColor.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _contactIcon(c.type),
                            size: 14 * scale,
                            color: _accentColor,
                          ),
                          SizedBox(width: 8 * scale),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  c.displayLabel,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 8 * scale,
                                    color: _textColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                Text(
                                  c.value,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 9 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: _textColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 8 * scale,
                            color: _textColor.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          // Social links
          if (visibleSocials.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                12 * scale,
                10 * scale,
                12 * scale,
                6 * scale,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'REDES SOCIALES',
                  style: GoogleFonts.outfit(
                    fontSize: 8 * scale,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: _textColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          if (visibleSocials.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                12 * scale,
                0,
                12 * scale,
                12 * scale,
              ),
              child: Column(
                children: visibleSocials.map((s) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8 * scale),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * scale,
                        vertical: 8 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: _textColor.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10 * scale),
                        border: Border.all(
                          color: _textColor.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _socialIcon(s.platform),
                            size: 14 * scale,
                            color: _accentColor,
                          ),
                          SizedBox(width: 8 * scale),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  s.label,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 9 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: _textColor,
                                  ),
                                ),
                                Text(
                                  _shortHandle(s.url),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 8 * scale,
                                    color: _textColor.withValues(alpha: 0.5),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 8 * scale,
                            color: _textColor.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          if (card.calendarEnabled && (card.calendarUrl?.isNotEmpty ?? false))
            Padding(
              padding: EdgeInsets.fromLTRB(
                12 * scale,
                4 * scale,
                12 * scale,
                12 * scale,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 10 * scale,
                ),
                decoration: BoxDecoration(
                  color: _accentColor,
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 11 * scale,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6 * scale),
                    Text(
                      'Agendar reunión',
                      style: GoogleFonts.outfit(
                        fontSize: 9 * scale,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    if (card.bgStyle == CardBgStyle.stripes) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: bgBase),
          CustomPaint(painter: _StripePainter(bgBase)),
          scrollContent,
        ],
      );
    }
    return Container(
      decoration: _buildBgDecoration(bgBase),
      child: scrollContent,
    );
  }

  Widget _buildHeaderBand(
    EdgeInsets headerPadding,
    bool isCentered,
    bool isCompact,
  ) {
    switch (card.layoutStyle) {
      case CardLayoutStyle.banner:
        return _buildBannerHeader(isCompact);
      case CardLayoutStyle.minimal:
        return _buildMinimalHeader(isCompact);
      default:
        return _buildClassicHeader(headerPadding, isCentered, isCompact);
    }
  }

  Widget _buildClassicHeader(
    EdgeInsets headerPadding,
    bool isCentered,
    bool isCompact,
  ) {
    final isGP =
        card.themeStyle == CardThemeStyle.gradient ||
        card.themeStyle == CardThemeStyle.premium;
    return Container(
      width: double.infinity,
      padding: headerPadding,
      child: Column(
        crossAxisAlignment: isCentered
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Container(
            width: (isCompact ? 44 : 52) * scale,
            height: (isCompact ? 44 : 52) * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accentColor.withValues(alpha: 0.2),
              border: Border.all(color: _accentColor, width: 2),
            ),
            child: _buildAvatar((isCompact ? 16 : 18) * scale),
          ),
          SizedBox(height: 10 * scale),
          Text(
            card.name.isEmpty ? 'Tu nombre' : card.name,
            style: GoogleFonts.outfit(
              fontSize: (isCompact ? 14 : 16) * scale,
              fontWeight: FontWeight.w800,
              color: isGP ? Colors.white : _textColor,
            ),
            textAlign: isCentered ? TextAlign.center : TextAlign.left,
          ),
          SizedBox(height: 3 * scale),
          Text(
            card.jobTitle.isEmpty ? 'Tu cargo' : card.jobTitle,
            style: GoogleFonts.dmSans(
              fontSize: (isCompact ? 10 : 11) * scale,
              color: isGP ? Colors.white70 : _subColor,
            ),
            textAlign: isCentered ? TextAlign.center : TextAlign.left,
          ),
          if (card.bio?.isNotEmpty == true) ...[
            SizedBox(height: 8 * scale),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12 * scale,
                vertical: 6 * scale,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Text(
                card.bio!,
                style: GoogleFonts.dmSans(
                  fontSize: 9 * scale,
                  color: isGP ? Colors.white70 : _subColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: isCentered ? TextAlign.center : TextAlign.left,
              ),
            ),
          ],
          SizedBox(height: 8 * scale),
          Container(
            height: 30 * scale,
            constraints: BoxConstraints(maxWidth: 90 * scale),
            padding: EdgeInsets.symmetric(
              horizontal: 6 * scale,
              vertical: 3 * scale,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    'assets/images/liomont-logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                if (card.companyLogoUrl != null &&
                    card.companyLogoUrl!.isNotEmpty)
                  SizedBox(
                    height: 9 * scale,
                    child: Image.network(
                      card.companyLogoUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerHeader(bool isCompact) {
    final isGP =
        card.themeStyle == CardThemeStyle.gradient ||
        card.themeStyle == CardThemeStyle.premium;
    final avatarSize = (isCompact ? 42.0 : 50.0);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 12 * scale,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: avatarSize * scale,
            height: avatarSize * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accentColor.withValues(alpha: 0.2),
              border: Border.all(color: _accentColor, width: 2),
            ),
            child: _buildAvatar((isCompact ? 15 : 17) * scale),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  card.name.isEmpty ? 'Tu nombre' : card.name,
                  style: GoogleFonts.outfit(
                    fontSize: (isCompact ? 13 : 14) * scale,
                    fontWeight: FontWeight.w800,
                    color: isGP ? Colors.white : _textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2 * scale),
                Text(
                  card.jobTitle.isEmpty ? 'Tu cargo' : card.jobTitle,
                  style: GoogleFonts.dmSans(
                    fontSize: (isCompact ? 9 : 10) * scale,
                    color: isGP ? Colors.white70 : _subColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (card.company.isNotEmpty)
                  Text(
                    card.company,
                    style: GoogleFonts.dmSans(
                      fontSize: (isCompact ? 8 : 9) * scale,
                      fontWeight: FontWeight.w600,
                      color: isGP ? Colors.white70 : _subColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (card.companyLogoUrl != null) ...[
                  SizedBox(height: 6 * scale),
                  Container(
                    height: 26 * scale,
                    constraints: BoxConstraints(maxWidth: 80 * scale),
                    padding: EdgeInsets.symmetric(
                      horizontal: 5 * scale,
                      vertical: 3 * scale,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.asset(
                            'assets/images/liomont-logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          height: 8 * scale,
                          child: Image.network(
                            card.companyLogoUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalHeader(bool isCompact) {
    final avatarSize = (isCompact ? 40.0 : 46.0);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        18 * scale,
        16 * scale,
        14 * scale,
      ),
      // No background: transparent to let page bg show through
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: avatarSize * scale,
            height: avatarSize * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(
                color: _textColor.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: _buildAvatar((isCompact ? 14 : 16) * scale),
          ),
          SizedBox(height: 8 * scale),
          Text(
            card.name.isEmpty ? 'Tu nombre' : card.name,
            style: GoogleFonts.outfit(
              fontSize: (isCompact ? 13 : 15) * scale,
              fontWeight: FontWeight.w800,
              color: _textColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2 * scale),
          Text(
            card.jobTitle.isEmpty ? 'Tu cargo' : card.jobTitle,
            style: GoogleFonts.dmSans(
              fontSize: (isCompact ? 9 : 10) * scale,
              color: _subColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (card.company.isNotEmpty)
            Text(
              card.company,
              style: GoogleFonts.dmSans(
                fontSize: (isCompact ? 8 : 9) * scale,
                fontWeight: FontWeight.w600,
                color: _accentColor,
              ),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: 8 * scale),
          Container(
            height: 28 * scale,
            constraints: BoxConstraints(maxWidth: 88 * scale),
            padding: EdgeInsets.symmetric(
              horizontal: 6 * scale,
              vertical: 3 * scale,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    'assets/images/liomont-logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                if (card.companyLogoUrl != null &&
                    card.companyLogoUrl!.isNotEmpty)
                  SizedBox(
                    height: 8 * scale,
                    child: Image.network(
                      card.companyLogoUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildBgDecoration(Color base) {
    switch (card.bgStyle) {
      case CardBgStyle.plain:
        return BoxDecoration(color: base);
      case CardBgStyle.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [base, card.bgColorEnd ?? _darken(base)],
          ),
        );
      case CardBgStyle.mesh:
        return BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.2, -0.6),
            radius: 1.6,
            colors: [
              card.bgColorEnd ?? Colors.white.withValues(alpha: 0.45),
              base,
            ],
          ),
        );
      case CardBgStyle.stripes:
        return BoxDecoration(color: base);
    }
  }

  static Color _darken(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
  }

  Widget _buildAvatar(double initialsFontSize) {
    if (card.profilePhotoUrl != null && card.profilePhotoUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          card.profilePhotoUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _buildInitials(initialsFontSize),
        ),
      );
    }
    return _buildInitials(initialsFontSize);
  }

  Widget _buildInitials(double size) {
    return Center(
      child: Text(
        _initials(card.name),
        style: GoogleFonts.outfit(
          fontSize: size,
          fontWeight: FontWeight.w800,
          color: _accentColor,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

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

  IconData _contactIcon(ContactType t) => switch (t) {
    ContactType.phone => Icons.phone_outlined,
    ContactType.whatsapp => Icons.chat_outlined,
    ContactType.email => Icons.email_outlined,
    ContactType.address => Icons.location_on_outlined,
    ContactType.website => Icons.language_outlined,
  };

  IconData _socialIcon(SocialPlatform p) => switch (p) {
    SocialPlatform.linkedin => Icons.work_outline,
    SocialPlatform.instagram => Icons.camera_alt_outlined,
    SocialPlatform.facebook => Icons.facebook_outlined,
    SocialPlatform.tiktok => Icons.music_note_outlined,
    SocialPlatform.twitter => Icons.alternate_email,
    SocialPlatform.youtube => Icons.play_circle_outline,
    SocialPlatform.calendly => Icons.calendar_today_outlined,
    SocialPlatform.github => Icons.code_outlined,
    SocialPlatform.custom => Icons.link_outlined,
  };
}

class _StripePainter extends CustomPainter {
  final Color bgColor;
  const _StripePainter(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    final isDark =
        ThemeData.estimateBrightnessForColor(bgColor) == Brightness.dark;
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
      ..strokeWidth = size.width * 0.04;
    final gap = size.width * 0.14;
    for (double i = -size.height; i < size.width + size.height; i += gap) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.bgColor != bgColor;
}
