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
    final bgBase = card.bgColor ?? Colors.white;
    final accentColor = card.primaryColor;

    Gradient? bgGradient;
    switch (card.bgStyle) {
      case CardBgStyle.gradient:
        bgGradient = LinearGradient(
          colors: [bgBase, card.bgColorEnd ?? Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case CardBgStyle.mesh:
        bgGradient = RadialGradient(
          center: const Alignment(0.2, -0.6),
          radius: 1.6,
          colors: [
            card.bgColorEnd ?? Colors.white.withValues(alpha: 0.45),
            bgBase,
          ],
        );
        break;
      default:
        break;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.04),
        gradient: bgGradient,
        color: bgGradient == null ? bgBase : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: card.textColorIsDark ? 0.35 : 0.15,
            ),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.border),
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
                  color: accentColor.withValues(
                    alpha: card.textColorIsDark ? 0.25 : 0.08,
                  ),
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
                  color: accentColor.withValues(
                    alpha: card.textColorIsDark ? 0.15 : 0.05,
                  ),
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
                          card.companyLogoUrl != null &&
                                  card.companyLogoUrl!.isNotEmpty
                              ? Image.network(
                                  card.companyLogoUrl!,
                                  height: height * 0.22,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                )
                              : Text(
                                  card.company.isNotEmpty
                                      ? card.company
                                      : 'TapLoop',
                                  style: GoogleFonts.outfit(
                                    fontSize: height * 0.12,
                                    fontWeight: FontWeight.w800,
                                    color: card.textColorIsDark
                                        ? Colors.white
                                        : AppColors.black,
                                  ),
                                ),
                          // NFC icon
                          Icon(
                            Icons.wifi,
                            size: height * 0.22,
                            color: card.textColorIsDark
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
                          SizedBox(
                            width: height * 0.36,
                            height: height * 0.36,
                            child: card.profilePhotoUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      card.profilePhotoUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      _initials(card.name),
                                      style: GoogleFonts.outfit(
                                        fontSize: height * 0.18,
                                        fontWeight: FontWeight.w700,
                                        color: accentColor,
                                      ),
                                    ),
                                  ),
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
                                    color: card.textColorIsDark
                                        ? AppColors.black
                                        : Colors.white,
                                    height: 1.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${card.jobTitle} · ${card.company}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: height * 0.13,
                                    color: card.textColorIsDark
                                        ? AppColors.grey
                                        : Colors.white.withValues(alpha: 0.65),
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
