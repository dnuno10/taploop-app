import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_layout.dart';
import '../widgets/social_divider.dart';
import '../widgets/google_sign_in_button.dart';
import '../../../core/widgets/taploop_button.dart';
import '../../../core/widgets/taploop_text_field.dart';

class LoginView extends StatefulWidget {
  final String? pendingNfc;

  const LoginView({super.key, this.pendingNfc});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onSendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      print('[LoginView] Enviando OTP a ${_emailCtrl.text.trim()}');
      await AuthService.sendOtp(_emailCtrl.text.trim());
      if (!mounted) return;
      context.push(
        '/otp-verify',
        extra: <String, String?>{
          'email': _emailCtrl.text.trim(),
          'name': null,
          'pendingNfc': widget.pendingNfc,
        },
      );
    } catch (e) {
      print('[LoginView] ERROR sendOtp: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMsg = _friendlyError(e.toString());
        });
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  String _friendlyError(String raw) {
    if (raw.contains('rate limit') || raw.contains('too many')) {
      return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
    }
    if (raw.contains('invalid') && raw.contains('email')) {
      return 'El correo ingresado no es válido.';
    }
    if (raw.contains('signup is disabled') ||
        raw.contains('Signups not allowed')) {
      return 'El servicio no está disponible en este momento.';
    }
    return 'Error al enviar el código. Intenta de nuevo.';
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(
              title: 'Bienvenido de nuevo',
              subtitle: 'Ingresa tu correo para recibir tu código de acceso',
            ),
            const SizedBox(height: 32),

            TapLoopTextField(
              label: 'Correo electrónico',
              hint: 'tu@email.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(
                Icons.mail_outline,
                size: 20,
                color: AppColors.grey,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                if (!v.contains('@')) return 'Correo inválido';
                return null;
              },
              onSubmitted: (_) => _onSendOtp(),
            ),

            if (_errorMsg != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _errorMsg!,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            TapLoopButton(
              label: 'Enviar código',
              onPressed: _loading ? null : _onSendOtp,
              variant: TapLoopButtonVariant.secondary,
              isLoading: _loading,
            ),
            const SizedBox(height: 24),

            const SocialDivider(),
            const SizedBox(height: 24),

            GoogleSignInButton(onPressed: () {}, isLoading: false),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿No tienes cuenta? ',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final pendingNfc = widget.pendingNfc;
                    if (pendingNfc != null && pendingNfc.isNotEmpty) {
                      context.go(
                        '/register',
                        extra: {'pendingNfc': pendingNfc},
                      );
                      return;
                    }
                    context.go('/register');
                  },
                  child: Text(
                    'Regístrate gratis',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
