import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_extensions.dart';
import 'taploop_motion.dart';
import 'taploop_progress_indicator.dart';

enum TapLoopButtonVariant { primary, secondary, outline, text }

class TapLoopButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final TapLoopButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final double height;
  final Gradient? gradient;
  final Gradient? disabledGradient;
  final Color? disabledTextColor;
  final double borderRadius;
  final bool animateIconOnHover;
  final bool visuallyDisabled;
  final String? loadingLabel;

  const TapLoopButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = TapLoopButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
    this.gradient,
    this.disabledGradient,
    this.disabledTextColor,
    this.borderRadius = 10,
    this.animateIconOnHover = false,
    this.visuallyDisabled = false,
    this.loadingLabel,
  });

  @override
  State<TapLoopButton> createState() => _TapLoopButtonState();
}

class _TapLoopButtonState extends State<TapLoopButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final visuallyDisabled = widget.visuallyDisabled && !widget.isLoading;
    final Widget child = widget.isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TapLoopProgressIndicator(color: _loadingColor(context)),
              if (widget.loadingLabel != null) ...[
                const SizedBox(width: 10),
                Text(
                  widget.loadingLabel!,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textColor(context),
                  ),
                ),
              ],
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                AnimatedSlide(
                  offset: Offset(
                    widget.animateIconOnHover &&
                            _hovered &&
                            enabled &&
                            !visuallyDisabled
                        ? 0.18
                        : 0,
                    0,
                  ),
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  child: widget.icon!,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textColor(context),
                  ),
                ),
              ),
            ],
          );

    return MouseRegion(
      onEnter: (_) {
        if (enabled) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (_hovered) setState(() => _hovered = false);
        if (_pressed) setState(() => _pressed = false);
      },
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Listener(
        onPointerDown: (_) {
          if (enabled) setState(() => _pressed = true);
        },
        onPointerUp: (_) {
          if (_pressed) setState(() => _pressed = false);
        },
        onPointerCancel: (_) {
          if (_pressed) setState(() => _pressed = false);
        },
        child: AnimatedScale(
          scale: enabled
              ? _pressed
                    ? 0.985
                    : _hovered
                    ? 1.002
                    : 1
              : 1,
          duration: TapLoopMotion.fast,
          curve: TapLoopMotion.standard,
          child: SizedBox(
            width: widget.width ?? double.infinity,
            height: widget.height,
            child: widget.gradient == null
                ? _buildButton(context, child)
                : _buildGradientButton(context, child),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(BuildContext context, Widget child) {
    final radius = BorderRadius.circular(widget.borderRadius);
    final enabled = widget.onPressed != null && !widget.isLoading;
    final visuallyDisabled = widget.visuallyDisabled && !widget.isLoading;
    final fallbackGradient = widget.variant == TapLoopButtonVariant.primary
        ? (_hovered && enabled && !visuallyDisabled
              ? const LinearGradient(
                  colors: [Color(0xFFFF6A2A), Color(0xFFFF9A52)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFFF5A1F), Color(0xFFFF8A3D)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ))
        : widget.gradient;
    final fallbackDisabledGradient =
        widget.variant == TapLoopButtonVariant.primary
        ? const LinearGradient(
            colors: [Color(0xFFFFF0E8), Color(0xFFFFE2D3)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
        : widget.disabledGradient;
    final showDisabledStyle =
        (visuallyDisabled || !enabled) &&
        !widget.isLoading &&
        fallbackDisabledGradient != null;
    final displayGradient = showDisabledStyle
        ? fallbackDisabledGradient
        : fallbackGradient;

    return Opacity(
      opacity: widget.isLoading || enabled || showDisabledStyle ? 1 : 0.65,
      child: AnimatedContainer(
        duration: TapLoopMotion.normal,
        curve: TapLoopMotion.standard,
        decoration: BoxDecoration(
          gradient: displayGradient,
          borderRadius: radius,
          boxShadow: enabled && _hovered && !visuallyDisabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: enabled ? widget.onPressed : null,
          style:
              ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                foregroundColor: _textColor(context),
                disabledForegroundColor: _textColor(context),
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: radius),
                elevation: 0,
              ).copyWith(
                mouseCursor: const WidgetStatePropertyAll(
                  SystemMouseCursors.click,
                ),
                overlayColor: WidgetStatePropertyAll(
                  Colors.white.withValues(alpha: 0.05),
                ),
              ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, Widget child) {
    switch (widget.variant) {
      case TapLoopButtonVariant.primary:
        return _buildGradientButton(context, child);
      case TapLoopButtonVariant.secondary:
        return ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style:
              ElevatedButton.styleFrom(
                backgroundColor: context.textPrimary,
                foregroundColor: context.isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                elevation: 0,
              ).copyWith(
                mouseCursor: WidgetStatePropertyAll(
                  widget.onPressed == null || widget.isLoading
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.click,
                ),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return context.textPrimary.withValues(alpha: 0.48);
                  }
                  return context.textPrimary;
                }),
                overlayColor: WidgetStatePropertyAll(
                  Colors.white.withValues(alpha: 0.04),
                ),
              ),
          child: child,
        );
      case TapLoopButtonVariant.outline:
        return OutlinedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style:
              OutlinedButton.styleFrom(
                foregroundColor: context.textPrimary,
                side: BorderSide(color: context.borderColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
              ).copyWith(
                mouseCursor: WidgetStatePropertyAll(
                  widget.onPressed == null || widget.isLoading
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.click,
                ),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return context.bgSubtle.withValues(alpha: 0.16);
                  }
                  return Colors.transparent;
                }),
                side: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return BorderSide(
                      color: context.borderStrongSoft,
                      width: 1.5,
                    );
                  }
                  return BorderSide(color: context.borderColor, width: 1.5);
                }),
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              ),
          child: child,
        );
      case TapLoopButtonVariant.text:
        return TextButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary)
              .copyWith(
                mouseCursor: WidgetStatePropertyAll(
                  widget.onPressed == null || widget.isLoading
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.click,
                ),
                overlayColor: WidgetStatePropertyAll(
                  context.bgSubtle.withValues(alpha: 0.16),
                ),
              ),
          child: child,
        );
    }
  }

  Color _textColor(BuildContext context) {
    final disabled =
        (widget.onPressed == null || widget.visuallyDisabled) &&
        !widget.isLoading;
    if (disabled && widget.disabledTextColor != null) {
      return widget.disabledTextColor!;
    }
    if (disabled && widget.variant == TapLoopButtonVariant.primary) {
      return const Color(0xFFD96A3A);
    }

    switch (widget.variant) {
      case TapLoopButtonVariant.primary:
        return Colors.white;
      case TapLoopButtonVariant.secondary:
        return context.isDark ? Colors.black : Colors.white;
      case TapLoopButtonVariant.outline:
        return context.textPrimary;
      case TapLoopButtonVariant.text:
        return AppColors.primary;
    }
  }

  Color _loadingColor(BuildContext context) {
    switch (widget.variant) {
      case TapLoopButtonVariant.primary:
        return Colors.white;
      case TapLoopButtonVariant.secondary:
        return context.isDark ? Colors.black : Colors.white;
      case TapLoopButtonVariant.outline:
      case TapLoopButtonVariant.text:
        return AppColors.primary;
    }
  }
}
