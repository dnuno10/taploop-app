import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/theme/app_theme_extensions.dart';

/// Wraps auth screens in a centered, scrollable, responsive card layout.
class AuthLayout extends StatelessWidget {
  final Widget child;

  const AuthLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final cardWidth = Responsive.authCardWidth(context);
    final hPadding = Responsive.authPadding(context);

    return Scaffold(
      backgroundColor: isMobile ? context.bgPage : context.bgSubtle,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 0 : hPadding,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: cardWidth),
              child: isMobile
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: child,
                    )
                  : Card(
                      color: context.bgCard,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: context.borderColor, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: child,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
