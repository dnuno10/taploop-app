import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/visit_event_model.dart';
import '../../../core/theme/app_colors.dart';

class VisitEventTile extends StatelessWidget {
  final VisitEventModel event;

  const VisitEventTile({super.key, required this.event});

  bool get _isInteraction =>
      event.source == 'link' ||
      event.source == 'contact' ||
      event.source == 'social' ||
      event.source == 'form';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(_sourceIcon, size: 18, color: _sourceColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isInteraction &&
                                (event.label?.trim().isNotEmpty ?? false)
                            ? event.label!
                            : _sourceLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      event.formattedTime,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (!_isInteraction) ...[
                      const Icon(
                        Icons.place_outlined,
                        size: 12,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        event.locationDisplay,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      Text(
                        event.formattedDate,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    _SourceBadge(source: event.source),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _sourceLabel {
    switch (event.source) {
      case 'contact':
        return 'Contacto';
      case 'social':
        return 'Red social';
      case 'form':
        return 'Formulario';
      case 'nfc':
      case 'qr':
        return 'Escaneo NFC';
      case 'link':
        return 'Abrió perfil';
      default:
        return event.source ?? '';
    }
  }

  Color get _sourceColor {
    switch (event.source) {
      case 'nfc':
        return const Color(0xFF7B61FF);
      case 'qr':
        return AppColors.primary;
      case 'link':
        return const Color(0xFF0A66C2);
      case 'contact':
        return const Color(0xFF16A34A);
      case 'social':
        return const Color(0xFFEA580C);
      case 'form':
        return const Color(0xFF0891B2);
      default:
        return AppColors.grey;
    }
  }

  IconData get _sourceIcon {
    switch (event.source) {
      case 'nfc':
        return Icons.wifi;
      case 'qr':
        return Icons.nfc_outlined;
      case 'link':
        return Icons.link;
      case 'contact':
        return Icons.phone_outlined;
      case 'social':
        return Icons.share_outlined;
      case 'form':
        return Icons.assignment_outlined;
      default:
        return Icons.open_in_browser_outlined;
    }
  }
}

class _SourceBadge extends StatelessWidget {
  final String? source;
  const _SourceBadge({this.source});

  @override
  Widget build(BuildContext context) {
    if (source == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }

  String get _label {
    switch (source) {
      case 'qr':
      case 'nfc':
        return 'NFC';
      case 'link':
        return 'LINK';
      case 'contact':
        return 'CONTACTO';
      case 'social':
        return 'SOCIAL';
      case 'form':
        return 'FORM';
      default:
        return source!.toUpperCase();
    }
  }

  Color get _color {
    switch (source) {
      case 'nfc':
        return const Color(0xFF7B61FF);
      case 'qr':
        return AppColors.primary;
      case 'link':
        return const Color(0xFF0A66C2);
      case 'contact':
        return const Color(0xFF16A34A);
      case 'social':
        return const Color(0xFFEA580C);
      case 'form':
        return const Color(0xFF0891B2);
      default:
        return AppColors.grey;
    }
  }
}
