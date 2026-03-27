import 'package:flutter/material.dart';

/// Adaptive color helpers exposed as BuildContext extensions.
/// Use these instead of AppColors.* in widgets to get automatic dark/light support.
extension AppThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ─── Page / structural backgrounds ──────────────────────────────────────
  /// Main scaffold background
  Color get bgPage =>
      isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);

  /// Card / surface background
  Color get bgCard =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);

  /// Subtle inset area (e.g. code blocks, inner panels)
  Color get bgSubtle =>
      isDark ? const Color(0xFF111827) : const Color(0xFFF7F7F5);

  /// Input/field background
  Color get bgInput =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFFAFAF8);

  // ─── Borders ─────────────────────────────────────────────────────────────
  Color get borderColor =>
      isDark ? const Color(0xFF334155) : const Color(0xFFD4DCE6);

  Color get borderStrong =>
      isDark ? const Color(0xFF475569) : const Color(0xFFBCC8D6);

  Color get borderSoft => borderColor.withValues(alpha: 0.2);

  Color get borderStrongSoft => borderStrong.withValues(alpha: 0.2);

  // ─── Text ─────────────────────────────────────────────────────────────────
  Color get textPrimary =>
      isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);

  Color get textSecondary =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);

  Color get textMuted =>
      isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  // ─── Shadows ──────────────────────────────────────────────────────────────
  List<BoxShadow> get cardShadow => [];

  List<BoxShadow> get subtleShadow => [];
}
