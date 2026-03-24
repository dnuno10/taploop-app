import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_extensions.dart';

enum TapLoopButtonVariant { primary, secondary, outline, text }

class TapLoopButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TapLoopButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final double height;

  const TapLoopButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = TapLoopButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _loadingColor(context),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
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

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: _buildButton(context, child),
    );
  }

  Widget _buildButton(BuildContext context, Widget child) {
    switch (variant) {
      case TapLoopButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style:
              ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ).copyWith(
                mouseCursor: const WidgetStatePropertyAll(
                  SystemMouseCursors.click,
                ),
              ),
          child: child,
        );
      case TapLoopButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style:
              ElevatedButton.styleFrom(
                backgroundColor: context.textPrimary,
                foregroundColor: context.isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ).copyWith(
                mouseCursor: const WidgetStatePropertyAll(
                  SystemMouseCursors.click,
                ),
              ),
          child: child,
        );
      case TapLoopButtonVariant.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style:
              OutlinedButton.styleFrom(
                foregroundColor: context.textPrimary,
                side: BorderSide(color: context.borderColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ).copyWith(
                mouseCursor: const WidgetStatePropertyAll(
                  SystemMouseCursors.click,
                ),
              ),
          child: child,
        );
      case TapLoopButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary)
              .copyWith(
                mouseCursor: const WidgetStatePropertyAll(
                  SystemMouseCursors.click,
                ),
              ),
          child: child,
        );
    }
  }

  Color _textColor(BuildContext context) {
    switch (variant) {
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
    switch (variant) {
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
