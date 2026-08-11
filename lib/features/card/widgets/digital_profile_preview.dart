import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/native_web_image.dart';
import '../../../core/widgets/platform_icon.dart';
import '../models/contact_item_model.dart';
import '../models/digital_card_model.dart';
import '../models/smart_form_model.dart';
import '../models/social_link_model.dart';

/// Mini phone-frame preview of the digital profile card (centralized links).
class DigitalProfilePreview extends StatelessWidget {
  final DigitalCardModel card;
  final double width;
  final bool enableInnerScroll;

  const DigitalProfilePreview({
    super.key,
    required this.card,
    this.width = 280,
    this.enableInnerScroll = true,
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.20),
                        blurRadius: width * 0.14,
                        spreadRadius: width * 0.01,
                        offset: Offset(0, width * 0.08),
                      ),
                    ],
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
                  child: _ScreenContent(
                    card: card,
                    scale: _scale,
                    enableInnerScroll: enableInnerScroll,
                  ),
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
  final bool enableInnerScroll;
  const _ScreenContent({
    required this.card,
    required this.scale,
    required this.enableInnerScroll,
  });

  Color get _bgColor {
    // Use bgColor from new design, with fallback to white if not set
    return card.bgColor ?? Colors.white;
  }

  Color get _textColor {
    final base = card.bgColor ?? Colors.white;
    final end = card.bgColorEnd;
    final sampled = switch (card.bgStyle) {
      CardBgStyle.gradient || CardBgStyle.mesh => _mix(base, end ?? base),
      CardBgStyle.plain || CardBgStyle.stripes => base,
    };
    return _contrastTextColor(sampled);
  }

  Color get _subColor => _textColor.withValues(alpha: 0.55);

  Color get _accentColor => card.primaryColor;

  @override
  Widget build(BuildContext context) {
    final visibleContacts = card.contactItems.where((c) => c.isVisible).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final visibleSocials = card.socialLinks.where((s) => s.isVisible).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final isModern = card.usesModernProfileDesign;
    final isCentered = !isModern;

    final bgBase = card.bgColor ?? _bgColor;
    final scrollContent = ScrollConfiguration(
      behavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
      child: SingleChildScrollView(
        primary: false,
        physics: enableInnerScroll
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: isModern
              ? [
                  _buildModernHero(),
                  _buildSaveButton(),
                  _buildModernActionButtons(),
                  if (visibleSocials.isNotEmpty)
                    _buildModernSocialCircles(visibleSocials),
                  if (visibleContacts.isNotEmpty)
                    _buildModernContactRows(visibleContacts),
                  if (card.calendarEnabled &&
                      (card.calendarUrl?.isNotEmpty ?? false))
                    _buildCalendarButton(),
                  if (card.smartForms.where((f) => f.isActive).isNotEmpty)
                    _buildFormPreview(
                      card.smartForms.where((f) => f.isActive).first,
                    ),
                  SizedBox(height: 18 * scale),
                ]
              : [
                  _buildTaploeHero(isCentered),
                  _buildSaveButton(),
                  if (visibleContacts.isNotEmpty)
                    _buildContactPills(visibleContacts),
                  if (visibleSocials.isNotEmpty)
                    _buildSocialList(visibleSocials),
                  if (card.calendarEnabled &&
                      (card.calendarUrl?.isNotEmpty ?? false))
                    _buildCalendarButton(),
                  if (card.smartForms.where((f) => f.isActive).isNotEmpty)
                    _buildFormPreview(
                      card.smartForms.where((f) => f.isActive).first,
                    ),
                  SizedBox(height: 18 * scale),
                ],
        ),
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

  Widget _buildModernHero() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        28 * scale,
        18 * scale,
        6 * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (card.companyLogoUrl != null && card.companyLogoUrl!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 22 * scale),
              child: SizedBox(
                width: 132 * scale,
                height: 38 * scale,
                child: NativeWebImage(
                  imageUrl: card.companyLogoUrl!,
                  width: 132 * scale,
                  height: 38 * scale,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          SizedBox(
            width: 72 * scale,
            height: 72 * scale,
            child: _buildAvatar(25 * scale),
          ),
          SizedBox(height: 17 * scale),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  card.name.isEmpty ? 'Tu nombre' : card.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 21 * scale,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    color: _textColor,
                  ),
                ),
              ),
              if (card.showVerifiedBadge) ...[
                SizedBox(width: 8 * scale),
                Icon(
                  Icons.verified_rounded,
                  size: 16 * scale,
                  color: const Color(0xFF2F9DEB),
                ),
              ],
            ],
          ),
          SizedBox(height: 5 * scale),
          Text(
            card.jobTitle.isEmpty ? 'Tu cargo' : card.jobTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12 * scale,
              height: 1.12,
              fontWeight: FontWeight.w800,
              color: _textColor,
            ),
          ),
          if (card.bio?.trim().isNotEmpty == true) ...[
            SizedBox(height: 12 * scale),
            Text(
              card.bio!,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 10 * scale,
                height: 1.32,
                color: _subColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaploeHero(bool isCentered) {
    final titleAlign = isCentered ? TextAlign.center : TextAlign.left;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        28 * scale,
        18 * scale,
        10 * scale,
      ),
      child: Column(
        crossAxisAlignment: isCentered
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (card.companyLogoUrl != null && card.companyLogoUrl!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 22 * scale),
              child: SizedBox(
                width: 132 * scale,
                height: 38 * scale,
                child: NativeWebImage(
                  imageUrl: card.companyLogoUrl!,
                  width: 132 * scale,
                  height: 38 * scale,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          SizedBox(
            width: 72 * scale,
            height: 72 * scale,
            child: _buildAvatar(25 * scale),
          ),
          SizedBox(height: 17 * scale),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  card.name.isEmpty ? 'Tu nombre' : card.name,
                  textAlign: titleAlign,
                  style: GoogleFonts.outfit(
                    fontSize: 21 * scale,
                    height: 1.02,
                    fontWeight: FontWeight.w800,
                    color: _textColor,
                  ),
                ),
              ),
              if (card.showVerifiedBadge) ...[
                SizedBox(width: 7 * scale),
                Icon(
                  Icons.verified_rounded,
                  size: 16 * scale,
                  color: const Color(0xFF2F9DEB),
                ),
              ],
            ],
          ),
          SizedBox(height: 5 * scale),
          Text(
            card.jobTitle.isEmpty ? 'Tu cargo' : card.jobTitle,
            textAlign: titleAlign,
            style: GoogleFonts.outfit(
              fontSize: 12 * scale,
              height: 1.12,
              fontWeight: FontWeight.w800,
              color: _textColor,
            ),
          ),
          if (card.company.isNotEmpty) ...[
            SizedBox(height: 3 * scale),
            Text(
              card.company,
              textAlign: titleAlign,
              style: GoogleFonts.dmSans(
                fontSize: 9 * scale,
                fontWeight: FontWeight.w700,
                color: _subColor,
              ),
            ),
          ],
          if (card.bio?.trim().isNotEmpty == true) ...[
            SizedBox(height: 14 * scale),
            Padding(
              padding: EdgeInsets.only(bottom: 6 * scale),
              child: Text(
                card.bio!,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 10 * scale,
                  height: 1.35,
                  color: _subColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(14 * scale, 10 * scale, 14 * scale, 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 11 * scale),
        decoration: BoxDecoration(
          color: _accentColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_alt_1_rounded,
              size: 14 * scale,
              color: Colors.white,
            ),
            SizedBox(width: 7 * scale),
            Text(
              'Guardar contacto',
              style: GoogleFonts.outfit(
                fontSize: 11.5 * scale,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        14 * scale,
        20 * scale,
        14 * scale,
        9 * scale,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 9 * scale,
            fontWeight: FontWeight.w800,
            color: _textColor.withValues(alpha: 0.55),
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialList(List<SocialLinkModel> socials) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('REDES SOCIALES'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * scale),
          child: Column(
            children: [
              for (final link in socials.take(5))
                Padding(
                  padding: EdgeInsets.only(bottom: 8 * scale),
                  child: _listRow(
                    icon: PlatformIcon.social(
                      platform: link.platform,
                      size: 13 * scale,
                    ),
                    title: link.label,
                    subtitle: _shortHandle(link.url),
                    titleFirst: true,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactPills(List<ContactItemModel> contacts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Contacto'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * scale),
          child: Column(
            children: [
              for (final item in contacts.take(3))
                Padding(
                  padding: EdgeInsets.only(bottom: 8 * scale),
                  child: _listRow(
                    icon: PlatformIcon.contact(
                      contactType: item.type,
                      size: 13 * scale,
                    ),
                    title: item.displayLabel,
                    subtitle: _displayContactValue(item),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernActionButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(14 * scale, 12 * scale, 14 * scale, 0),
      child: Row(
        children: [
          Expanded(
            child: _pillRow(
              icon: Icon(
                Icons.email_rounded,
                size: 15 * scale,
                color: _accentColor,
              ),
              label: 'Enviar correo',
              filled: false,
              trailing: Icons.keyboard_arrow_right_rounded,
            ),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: _pillRow(
              icon: Icon(
                Icons.share_rounded,
                size: 15 * scale,
                color: _accentColor,
              ),
              label: 'Compartir',
              filled: false,
              trailing: Icons.keyboard_arrow_right_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSocialCircles(List<SocialLinkModel> socials) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildModernSectionTitle('Conecta conmigo'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * scale),
          child: Wrap(
            spacing: 14 * scale,
            runSpacing: 14 * scale,
            children: [
              for (final link in socials.take(5))
                Container(
                  width: 82 * scale,
                  height: 82 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.1,
                    ),
                  ),
                  child: Center(
                    child: PlatformIcon.social(
                      platform: link.platform,
                      framed: false,
                      size: 50 * scale,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernContactRows(List<ContactItemModel> contacts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildModernSectionTitle('Contacto'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * scale),
          child: Column(
            children: [
              for (final item in contacts.take(3))
                Padding(
                  padding: EdgeInsets.only(bottom: 8 * scale),
                  child: _modernListRow(
                    icon: PlatformIcon.contact(
                      contactType: item.type,
                      framed: false,
                      size: 15 * scale,
                      color: _accentColor,
                    ),
                    label: _modernContactLabel(item),
                    trailing: Icons.arrow_forward_rounded,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        14 * scale,
        22 * scale,
        14 * scale,
        10 * scale,
      ),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w800,
          color: _textColor,
        ),
      ),
    );
  }

  Widget _modernListRow({
    required Widget icon,
    required String label,
    required IconData trailing,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 13 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.1),
      ),
      child: Row(
        children: [
          icon,
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.visible,
              style: GoogleFonts.outfit(
                fontSize: 13 * scale,
                height: 1.12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0D0D0D),
              ),
            ),
          ),
          Icon(trailing, size: 16 * scale, color: const Color(0xFF0D0D0D)),
        ],
      ),
    );
  }

  Widget _buildCalendarButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Agenda una reunión'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * scale),
          child: _pillRow(
            icon: Icon(
              Icons.calendar_month_rounded,
              size: 14 * scale,
              color: Colors.white,
            ),
            label: 'Agendar reunión',
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildFormPreview(SmartFormModel form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Formulario de contacto'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * scale),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              11 * scale,
              10 * scale,
              11 * scale,
              11 * scale,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18 * scale),
              border: Border.all(color: _textColor.withValues(alpha: 0.12)),
            ),
            child: Column(
              children: [
                _pillRow(
                  icon: Icon(
                    Icons.dynamic_form_rounded,
                    size: 14 * scale,
                    color: _accentColor,
                  ),
                  label: form.name,
                  filled: false,
                  trailing: Icons.keyboard_arrow_up_rounded,
                ),
                SizedBox(height: 10 * scale),
                for (final label in ['Nombre *', 'Correo *', 'Teléfono'])
                  Padding(
                    padding: EdgeInsets.only(bottom: 7 * scale),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * scale,
                        vertical: 9 * scale,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12 * scale),
                        border: Border.all(
                          color: _textColor.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Text(
                        label,
                        style: GoogleFonts.dmSans(
                          fontSize: 9 * scale,
                          fontWeight: FontWeight.w600,
                          color: _subColor,
                        ),
                      ),
                    ),
                  ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 9 * scale),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Enviar',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _pillRow({
    required Widget icon,
    required String label,
    required bool filled,
    IconData trailing = Icons.arrow_forward_rounded,
    bool allowWrap = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 13 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        color: filled ? _accentColor : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: filled ? _accentColor : _textColor.withValues(alpha: 0.12),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          icon,
          SizedBox(width: 9 * scale),
          Expanded(
            child: Text(
              label,
              maxLines: allowWrap ? 2 : 1,
              overflow: allowWrap
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 11 * scale,
                fontWeight: FontWeight.w800,
                color: filled ? Colors.white : _textColor,
              ),
            ),
          ),
          Icon(
            trailing,
            size: 16 * scale,
            color: filled ? Colors.white : _textColor,
          ),
        ],
      ),
    );
  }

  Widget _listRow({
    required Widget icon,
    required String title,
    required String subtitle,
    bool titleFirst = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9 * scale,
        vertical: 6.5 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11 * scale),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      ),
      child: Row(
        children: [
          icon,
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: titleFirst
                  ? [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 10.5 * scale,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 8.5 * scale,
                          fontWeight: FontWeight.w600,
                          color: _subColor,
                        ),
                      ),
                    ]
                  : [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 8.5 * scale,
                          fontWeight: FontWeight.w600,
                          color: _subColor,
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 10.5 * scale,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                        ),
                      ),
                    ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 13 * scale, color: _subColor),
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

  static Color _contrastTextColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : const Color(0xFF0D0D0D);
  }

  static Color _mix(Color a, Color b) {
    return Color.lerp(a, b, 0.5) ?? a;
  }

  Widget _buildAvatar(double initialsFontSize) {
    final photoUrl = card.profilePhotoUrl?.trim();
    final placeholder = _buildProfileIcon(initialsFontSize * 1.2);
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => placeholder,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : placeholder,
        ),
      );
    }
    return placeholder;
  }

  Widget _buildProfileIcon(double size) {
    return Container(
      decoration: BoxDecoration(
        color: _accentColor.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.person_outline_rounded,
          size: size,
          color: _accentColor,
        ),
      ),
    );
  }

  String _displayContactValue(ContactItemModel item) {
    final value = item.value.trim();
    if (item.type != ContactType.website || value.isEmpty) return value;
    try {
      final uri = Uri.parse(
        value.startsWith('http') ? value : 'https://$value',
      );
      final host = uri.host.replaceFirst(RegExp(r'^www\.'), '');
      return host.isNotEmpty ? host : value;
    } catch (_) {
      return value
          .replaceFirst(RegExp(r'^https?://'), '')
          .replaceFirst(RegExp(r'^www\.'), '')
          .split('/')
          .first;
    }
  }

  String _modernContactLabel(ContactItemModel item) {
    return switch (item.type) {
      ContactType.phone => 'Llamar',
      ContactType.whatsapp => 'Enviar WhatsApp',
      ContactType.email => 'Enviar correo',
      ContactType.address => 'Cómo llegar',
      ContactType.website =>
        item.displayLabel.isNotEmpty ? item.displayLabel : 'Visitar sitio web',
    };
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
    if (url.trim().startsWith('@')) return url.trim();
    return url;
  }
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
