import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme_extensions.dart';
import 'taploop_logo.dart';
import 'taploop_motion.dart';

class TapLoopLoadingView extends StatelessWidget {
  final bool scaffold;
  final String title;

  const TapLoopLoadingView({
    super.key,
    this.scaffold = false,
    this.title = 'Preparando tu perfil',
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 520;
    final content = TapLoopFadeSlide(
      duration: TapLoopMotion.slow,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 22 : 28,
            vertical: compact ? 32 : 40,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TapLoopLogo(height: compact ? 34 : 42),
                SizedBox(height: compact ? 38 : 52),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: context.textPrimary,
                    fontSize: compact ? 24 : 28,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: compact ? 28 : 36),
                const _PulsingDots(),
                SizedBox(height: compact ? 26 : 34),
                Text(
                  '¿Recibiste una tarjeta TapLoop?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: context.textPrimary,
                    fontSize: compact ? 14 : 15,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Inicia sesión y vincúlala a tu perfil digital.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: context.textSecondary,
                    fontSize: compact ? 14 : 15,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!scaffold) return content;

    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(child: content),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final phase = (_controller.value + (index * 0.18)) % 1;
            final scale = 0.82 + (math.sin(phase * math.pi) * 0.28);

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: context.textPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
