import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/digital_card_model.dart';
import '../../../core/theme/app_colors.dart';

/// Visual "plastic card" preview — same proportions as a real NFC card (85.6×54mm = ~CR80).
class CardPreviewWidget extends StatelessWidget {
  final DigitalCardModel card;
  final double width;

  const CardPreviewWidget({super.key, required this.card, this.width = 340});

  double get height => width * (54 / 85.6); // CR80 ratio

  @override
  Widget build(BuildContext context) {
    final isDark =
        card.themeStyle == CardThemeStyle.dark ||
        card.themeStyle == CardThemeStyle.neon ||
        card.themeStyle == CardThemeStyle.premium;
    final isGradient = card.themeStyle == CardThemeStyle.gradient;
    final isFrosted = card.themeStyle == CardThemeStyle.frosted;
    final isNeon = card.themeStyle == CardThemeStyle.neon;
    final isPremium = card.themeStyle == CardThemeStyle.premium;
    final isRetro = card.themeStyle == CardThemeStyle.retro;

    Color bgColor = AppColors.white;
    if (isDark) bgColor = AppColors.black;
    if (isFrosted) bgColor = const Color(0xFFF0F2F8);
    if (isRetro) bgColor = const Color(0xFFFFF8F0);

    Gradient? bgGradient;
    if (isGradient) {
      bgGradient = LinearGradient(
        colors: [
          card.backgroundColorStart ?? AppColors.black,
          card.backgroundColorEnd ?? AppColors.primary,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (isPremium) {
      bgGradient = const LinearGradient(
        colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (isNeon) {
      bgGradient = const LinearGradient(
        colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    final accentColor = isNeon
        ? const Color(0xFF00FFB2)
        : isPremium
        ? const Color(0xFFD4AF37)
        : isRetro
        ? const Color(0xFFE8803A)
        : card.primaryColor;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.04),
        gradient: bgGradient,
        color: bgGradient == null ? bgColor : null,
        boxShadow: [
          BoxShadow(
            color: isNeon
                ? accentColor.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: isDark ? 0.35 : 0.15),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
        border: isDark || isGradient || isPremium || isNeon
            ? (isNeon
                  ? Border.all(color: accentColor.withValues(alpha: 0.4))
                  : null)
            : Border.all(
                color: isFrosted
                    ? Colors.white.withValues(alpha: 0.4)
                    : AppColors.border,
              ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.04),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -width * 0.12,
              top: -width * 0.12,
              child: Container(
                width: width * 0.45,
                height: width * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: isDark ? 0.25 : 0.08),
                ),
              ),
            ),
            Positioned(
              right: -width * 0.04,
              bottom: -width * 0.08,
              child: Container(
                width: width * 0.28,
                height: width * 0.28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: isDark ? 0.15 : 0.05),
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(width * 0.06),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: width * (1 - 0.12),
                  height: height * (1 - 0.12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: logo + NFC
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Logo o company logo
                          card.companyLogoUrl != null
                              ? Image.network(
                                  card.companyLogoUrl!,
                                  height: height * 0.22,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    'assets/images/liomont-logo.png',
                                    height: height * 0.35,
                                    color: isDark ? Colors.white : null,
                                    colorBlendMode: isDark
                                        ? BlendMode.srcIn
                                        : null,
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/liomont-logo.png',
                                  height: height * 0.35,
                                  color: isDark ? Colors.white : null,
                                  colorBlendMode: isDark
                                      ? BlendMode.srcIn
                                      : null,
                                ),
                          // NFC icon
                          Icon(
                            Icons.wifi,
                            size: height * 0.22,
                            color: isNeon
                                ? accentColor
                                : isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : AppColors.grey,
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Profile row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: height * 0.18,
                            backgroundColor: accentColor,
                            backgroundImage: card.profilePhotoUrl != null
                                ? NetworkImage(card.profilePhotoUrl!)
                                : null,
                            child: card.profilePhotoUrl == null
                                ? Text(
                                    _initials(card.name),
                                    style: GoogleFonts.outfit(
                                      fontSize: height * 0.18,
                                      fontWeight: FontWeight.w700,
                                      color: isNeon || isPremium
                                          ? AppColors.black
                                          : Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(width: width * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  card.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: height * 0.19,
                                    fontWeight: FontWeight.w700,
                                    color: isDark || isGradient
                                        ? Colors.white
                                        : isRetro
                                        ? const Color(0xFF3D2B1F)
                                        : AppColors.black,
                                    height: 1.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${card.jobTitle} · ${card.company}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: height * 0.13,
                                    color: isDark || isGradient
                                        ? Colors.white.withValues(alpha: 0.65)
                                        : isRetro
                                        ? const Color(0xFF6B4C3B)
                                        : AppColors.grey,
                                    height: 1.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
