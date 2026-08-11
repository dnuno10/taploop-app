import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/taploop_button.dart';
import '../../../core/widgets/taploop_loading_view.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_layout.dart';

enum _AuthNoticeType { warning, error, success, loading }

class LoginView extends StatefulWidget {
  final String? pendingNfc;

  const LoginView({super.key, this.pendingNfc});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _loading = false;
  String? _errorMsg;
  _AuthNoticeType _noticeType = _AuthNoticeType.warning;

  bool get _hasCredentials =>
      _emailCtrl.text.trim().isNotEmpty && _passwordCtrl.text.isNotEmpty;

  bool get _canSubmit => _hasCredentials && !_loading;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_onFieldsChanged);
    _passwordCtrl.addListener(_onFieldsChanged);
  }

  @override
  void dispose() {
    _emailCtrl.removeListener(_onFieldsChanged);
    _passwordCtrl.removeListener(_onFieldsChanged);
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onFieldsChanged() {
    if (!mounted) return;
    setState(() {
      _errorMsg = null;
    });
  }

  void _onSignIn() async {
    if (!_canSubmit) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      final user = await AuthService.signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      appState.setLoadingCard(true);
      appState.setUser(user);
      if (mounted) setState(() {});
      final cards = await AuthService.fetchUserCards(user.id);
      appState.setCards(cards);
      appState.setLoadingCard(false);
      if (!mounted) return;
      final pendingNfc = widget.pendingNfc;
      if (pendingNfc != null && pendingNfc.isNotEmpty) {
        context.go('/nfc/$pendingNfc');
      } else {
        context.go('/');
      }
    } catch (e) {
      appState.setLoadingCard(false);
      if (mounted) {
        final friendlyError = _friendlyError(e.toString());
        setState(() {
          _loading = false;
          _errorMsg = friendlyError;
          _noticeType = _AuthNoticeType.error;
        });
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  String _friendlyError(String raw) {
    if (raw.contains('Invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (raw.contains('Email not confirmed')) {
      return 'Tu correo no ha sido confirmado.';
    }
    return 'No se pudo iniciar sesión. Intenta de nuevo.';
  }

  void _onContinuePressed() {
    if (_canSubmit) {
      _onSignIn();
      return;
    }

    final emailEmpty = _emailCtrl.text.trim().isEmpty;
    final passwordEmpty = _passwordCtrl.text.isEmpty;
    final message = emailEmpty && passwordEmpty
        ? 'Ingresa tu correo y contraseña para continuar.'
        : emailEmpty
        ? 'Ingresa tu correo para continuar.'
        : 'Ingresa tu contraseña para continuar.';

    if (emailEmpty) {
      _emailFocus.requestFocus();
    } else if (passwordEmpty) {
      _passwordFocus.requestFocus();
    }

    setState(() {
      _errorMsg = message;
      _noticeType = _AuthNoticeType.warning;
    });
  }

  Color _noticeAccentColor(_AuthNoticeType type) {
    switch (type) {
      case _AuthNoticeType.warning:
        return const Color(0xFFE6A100);
      case _AuthNoticeType.error:
        return AppColors.error;
      case _AuthNoticeType.success:
      case _AuthNoticeType.loading:
        return AppColors.success;
    }
  }

  Color _noticeSoftColor(_AuthNoticeType type) {
    switch (type) {
      case _AuthNoticeType.warning:
        return const Color(0xFFFFE7A8);
      case _AuthNoticeType.error:
        return const Color(0xFFFFD6D1);
      case _AuthNoticeType.success:
      case _AuthNoticeType.loading:
        return const Color(0xFFCFEFDD);
    }
  }

  IconData _noticeIcon(_AuthNoticeType type) {
    switch (type) {
      case _AuthNoticeType.warning:
        return Icons.warning_amber_rounded;
      case _AuthNoticeType.error:
        return Icons.error_outline_rounded;
      case _AuthNoticeType.success:
        return Icons.check_circle_outline_rounded;
      case _AuthNoticeType.loading:
        return Icons.sync_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (appState.isAuthenticated && appState.loadingCard) {
      return const TapLoopLoadingView(scaffold: true);
    }

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final headerToFormGap = isMobile ? 24.0 : 30.0;

    return AuthLayout(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(
              title: 'Inicia sesión en TapLoop',
              subtitle:
                  'Usa tu correo para continuar. Si aún no tienes una cuenta, podrás crearla.',
              logoHeight: isMobile ? 34 : 40,
              logoBottomSpacing: isMobile ? 12 : 16,
              titleBottomSpacing: isMobile ? 12 : 14,
              titleFontSize: isMobile ? 30 : (isTablet ? 36 : 40),
              subtitleFontSize: isMobile ? 15 : 18,
              titleMaxWidth: 520,
              subtitleMaxWidth: 500,
            ),
            SizedBox(height: headerToFormGap),

            _AuthInputField(
              label: 'Correo electrónico',
              hint: 'Email',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.mail_outline,
              focusNode: _emailFocus,
              autofocus: !isMobile,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa tu correo';
                }
                if (!v.contains('@')) return 'Correo inválido';
                return null;
              },
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: 14),

            _AuthInputField(
              label: 'Contraseña',
              hint: 'Contraseña',
              controller: _passwordCtrl,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.lock_outline,
              focusNode: _passwordFocus,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                return null;
              },
              onSubmitted: (_) => _onContinuePressed(),
            ),

            if (_errorMsg != null) ...[
              const SizedBox(height: 12),
              _AuthInlineNotice(
                message: _errorMsg!,
                accent: _noticeAccentColor(_noticeType),
                softAccent: _noticeSoftColor(_noticeType),
                icon: _noticeIcon(_noticeType),
              ),
            ],
            const SizedBox(height: 20),

            TapLoopButton(
              label: 'Continuar',
              onPressed: _loading ? null : _onContinuePressed,
              variant: TapLoopButtonVariant.primary,
              isLoading: _loading,
              loadingLabel: 'Entrando...',
              height: isMobile ? 58 : 67,
              icon: const Icon(Icons.arrow_forward, size: 22),
              animateIconOnHover: true,
              visuallyDisabled: !_hasCredentials,
              borderRadius: 18,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF5A1F), Color(0xFFFF8A3D)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              disabledGradient: const LinearGradient(
                colors: [Color(0xFFFFF0E8), Color(0xFFFFE2D3)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              disabledTextColor: const Color(0xFFD96A3A),
            ),
            const SizedBox(height: 14),
            Center(
              child: Wrap(
                spacing: 10,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => context.push('/terminos'),
                    child: Text(
                      'Términos y condiciones',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(
                    '•',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: context.textMuted,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/privacidad'),
                    child: Text(
                      'Políticas de privacidad',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isMobile ? 22 : 28),
            const _DividerWithDot(),
            SizedBox(height: isMobile ? 16 : 18),
            Text(
              '¿Recibiste una tarjeta TapLoop?',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: isMobile ? 15 : 16,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Inicia sesión y vincúlala a tu perfil digital.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w400,
                color: context.textSecondary,
              ),
            ),

            // Flujo anterior comentado a petición del proyecto:
            // const SizedBox(height: 24),
            // const SocialDivider(),
            // const SizedBox(height: 24),
            // GoogleSignInButton(onPressed: () {}, isLoading: false),
            // const SizedBox(height: 32),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text(
            //       '¿No tienes cuenta? ',
            //       style: GoogleFonts.dmSans(
            //         fontSize: 14,
            //         color: context.textSecondary,
            //       ),
            //     ),
            //     GestureDetector(
            //       onTap: () {
            //         final pendingNfc = widget.pendingNfc;
            //         if (pendingNfc != null && pendingNfc.isNotEmpty) {
            //           context.go('/register', extra: {'pendingNfc': pendingNfc});
            //           return;
            //         }
            //         context.go('/register');
            //       },
            //       child: Text(
            //         'Regístrate gratis',
            //         style: GoogleFonts.dmSans(
            //           fontSize: 14,
            //           fontWeight: FontWeight.w700,
            //           color: AppColors.primary,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

class _AuthInlineNotice extends StatelessWidget {
  final String message;
  final Color accent;
  final Color softAccent;
  final IconData icon;

  const _AuthInlineNotice({
    required this.message,
    required this.accent,
    required this.softAccent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 6 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: softAccent.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: softAccent),
        ),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: accent,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthInputField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final IconData prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;

  const _AuthInputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.keyboardType,
    required this.textInputAction,
    required this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<_AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<_AuthInputField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF202124),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onFieldSubmitted: widget.onSubmitted,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          style: GoogleFonts.dmSans(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w400,
            color: context.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.dmSans(
              fontSize: isMobile ? 16 : 18,
              color: const Color(0xFF8791A1),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isMobile ? 16 : 18,
            ),
            prefixIcon: Icon(
              widget.prefixIcon,
              size: isMobile ? 24 : 27,
              color: const Color(0xFF111111),
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    tooltip: _obscured
                        ? 'Mostrar contraseña'
                        : 'Ocultar contraseña',
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF8791A1),
                      size: 22,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
            border: _fieldBorder(const Color(0xFFE2E7EE)),
            enabledBorder: _fieldBorder(const Color(0xFFE2E7EE)),
            focusedBorder: _fieldBorder(AppColors.primary, width: 1.4),
            errorBorder: _fieldBorder(AppColors.error),
            focusedErrorBorder: _fieldBorder(AppColors.error, width: 1.4),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _DividerWithDot extends StatelessWidget {
  const _DividerWithDot();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE5E9F0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'o',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF8791A1),
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE5E9F0))),
      ],
    );
  }
}
