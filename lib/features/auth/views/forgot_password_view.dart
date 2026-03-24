import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_layout.dart';
import '../../../core/widgets/taploop_button.dart';
import '../../../core/widgets/taploop_text_field.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onSend() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.resetPassword(_emailCtrl.text.trim());
      if (mounted)
        setState(() {
          _loading = false;
          _sent = true;
        });
    } catch (_) {
      // Still show success to avoid email enumeration
      if (mounted)
        setState(() {
          _loading = false;
          _sent = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: _sent
          ? _SuccessState(email: _emailCtrl.text.trim())
          : _FormState(
              formKey: _formKey,
              emailCtrl: _emailCtrl,
              loading: _loading,
              onSend: _onSend,
            ),
    );
  }
}

class _FormState extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool loading;
  final VoidCallback onSend;

  const _FormState({
    required this.formKey,
    required this.emailCtrl,
    required this.loading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.black,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(height: 16),
          const AuthHeader(
            title: 'Recuperar contraseña',
            subtitle:
                'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña',
          ),
          const SizedBox(height: 32),

          TapLoopTextField(
            label: 'Correo electrónico',
            hint: 'tu@email.com',
            controller: emailCtrl,
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
            onSubmitted: (_) => onSend(),
          ),
          const SizedBox(height: 24),

          TapLoopButton(
            label: 'Enviar enlace de recuperación',
            onPressed: onSend,
            variant: TapLoopButtonVariant.secondary,
            isLoading: loading,
          ),
          const SizedBox(height: 24),

          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Volver a iniciar sesión',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  final String email;

  const _SuccessState({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '¡Revisa tu correo!',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Enviamos un enlace de recuperación a\n$email',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppColors.grey,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TapLoopButton(
          label: 'Volver a iniciar sesión',
          onPressed: () => Navigator.pop(context),
          variant: TapLoopButtonVariant.secondary,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            '¿No recibiste el correo? Revisa tu carpeta de spam',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
