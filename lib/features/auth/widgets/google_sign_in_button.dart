import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme_extensions.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({super.key, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: context.textPrimary,
          backgroundColor: context.bgCard,
          side: BorderSide(color: context.borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.textSecondary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google "G" icon drawn with colored text
                  _GoogleIcon(),
                  const SizedBox(width: 10),
                  Text(
                    'Continuar con Google',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    // Blue arc (top-right)
    _drawArc(
      canvas,
      cx,
      cy,
      r,
      -90,
      165,
      const Color(0xFF4285F4),
      size.width * 0.22,
    );
    // Red arc (top-left)
    _drawArc(
      canvas,
      cx,
      cy,
      r,
      75,
      105,
      const Color(0xFFEA4335),
      size.width * 0.22,
    );
    // Yellow arc (bottom-left to bottom)
    _drawArc(
      canvas,
      cx,
      cy,
      r,
      180,
      75,
      const Color(0xFFFBBC05),
      size.width * 0.22,
    );
    // Green arc (bottom)
    _drawArc(
      canvas,
      cx,
      cy,
      r,
      255,
      105,
      const Color(0xFF34A853),
      size.width * 0.22,
    );

    // White center to create ring
    final white = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r - size.width * 0.22, white);

    // Blue horizontal bar
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(cx + r, cy), bluePaint);
  }

  void _drawArc(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double startDeg,
    double sweepDeg,
    Color color,
    double strokeWidth,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    const pi = 3.141592653589793;
    final startRad = startDeg * pi / 180;
    final sweepRad = sweepDeg * pi / 180;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r - strokeWidth / 2),
      startRad,
      sweepRad,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GooglePainter oldDelegate) => false;
}
