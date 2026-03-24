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

class RegisterView extends StatefulWidget {
  final String? pendingNfc;

  const RegisterView({super.key, this.pendingNfc});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _acceptedTerms = false;
  String? _errorMsg;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onSendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    print('[RegisterView] Enviando OTP a ${_emailCtrl.text.trim()}');
    try {
      await AuthService.sendOtp(_emailCtrl.text.trim());
      if (!mounted) return;
      print('[RegisterView] OTP enviado — navegando a verificación');
      context.push(
        '/otp-verify',
        extra: <String, String?>{
          'email': _emailCtrl.text.trim(),
          'name': _nameCtrl.text.trim(),
          'pendingNfc': widget.pendingNfc,
        },
      );
    } catch (e) {
      print('[RegisterView] ERROR sendOtp: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMsg = _friendlyError(e.toString());
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e.toString())),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }
    if (mounted) setState(() => _loading = false);
  }

  String _friendlyError(String raw) {
    if (raw.contains('rate limit') || raw.contains('too many')) {
      return 'Demasiados intentos. Espera un momento.';
    }
    if (raw.contains('signup is disabled') ||
        raw.contains('Signups not allowed')) {
      return 'El registro está temporalmente desactivado.';
    }
    if (raw.contains('invalid') && raw.contains('email')) {
      return 'El correo ingresado no es válido.';
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
              title: 'Crea tu cuenta',
              subtitle: 'Únete a TapLoop y conecta sin límites',
            ),
            const SizedBox(height: 32),

            // Full name
            TapLoopTextField(
              label: 'Nombre completo',
              hint: 'Juan García',
              controller: _nameCtrl,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(
                Icons.person_outline,
                size: 20,
                color: AppColors.grey,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Ingresa tu nombre';
                if (v.trim().length < 3) return 'Nombre demasiado corto';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
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
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegex.hasMatch(v.trim())) return 'Correo inválido';
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
            const SizedBox(height: 20),

            // Terms checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _acceptedTerms,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (v) =>
                        setState(() => _acceptedTerms = v ?? false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.grey,
                      ),
                      children: [
                        const TextSpan(text: 'Acepto los '),
                        TextSpan(
                          text: 'Términos de Servicio',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const TextSpan(text: ' y la '),
                        TextSpan(
                          text: 'Política de Privacidad',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const TextSpan(text: ' de TapLoop'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Register button
            TapLoopButton(
              label: 'Crear cuenta',
              onPressed: _loading ? null : _onSendOtp,
              variant: TapLoopButtonVariant.primary,
              isLoading: _loading,
            ),
            const SizedBox(height: 24),

            const SocialDivider(),
            const SizedBox(height: 24),

            GoogleSignInButton(onPressed: () {}, isLoading: false),
            const SizedBox(height: 32),

            // Login CTA
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿Ya tienes cuenta? ',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final pendingNfc = widget.pendingNfc;
                    if (pendingNfc != null && pendingNfc.isNotEmpty) {
                      context.go('/?pendingNfc=$pendingNfc');
                      return;
                    }
                    context.go('/');
                  },
                  child: Text(
                    'Inicia sesión',
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
