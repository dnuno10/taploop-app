import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/auth_layout.dart';
import '../../../core/widgets/taploop_logo.dart';
import '../../../core/widgets/taploop_button.dart';
import 'login_view.dart';

class VerifyEmailView extends StatefulWidget {
  final String email;

  const VerifyEmailView({super.key, required this.email});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  final List<TextEditingController> _codeCtrl = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  bool _resendLoading = false;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);
    _tick();
  }

  void _tick() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted && _resendCountdown > 0) {
      setState(() => _resendCountdown--);
      _tick();
    }
  }

  @override
  void dispose() {
    for (final c in _codeCtrl) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _fullCode => _codeCtrl.map((c) => c.text).join();

  void _onVerify() async {
    if (_fullCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa los 6 dígitos del código'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _loading = false);
      // Navigate to home / profile on success (placeholder)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
        (_) => false,
      );
    }
  }

  void _onResend() async {
    setState(() => _resendLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _resendLoading = false);
      _startResendCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código reenviado correctamente'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _onCodeChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: TapLoopLogo(height: 30)),
          const SizedBox(height: 24),

          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_unread_outlined,
                size: 38,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Verifica tu correo',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enviamos un código de 6 dígitos a\n${widget.email}',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.grey,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // OTP input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              6,
              (i) => _OtpBox(
                controller: _codeCtrl[i],
                focusNode: _focusNodes[i],
                onChanged: (v) => _onCodeChanged(i, v),
                onBackspace: i > 0
                    ? () {
                        if (_codeCtrl[i].text.isEmpty) {
                          _focusNodes[i - 1].requestFocus();
                          _codeCtrl[i - 1].clear();
                          setState(() {});
                        }
                      }
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 32),

          TapLoopButton(
            label: 'Verificar correo',
            onPressed: _onVerify,
            variant: TapLoopButtonVariant.secondary,
            isLoading: _loading,
          ),
          const SizedBox(height: 20),

          // Resend
          Center(
            child: _resendCountdown > 0
                ? Text(
                    'Reenviar código en ${_resendCountdown}s',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.grey,
                    ),
                  )
                : _resendLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : GestureDetector(
                    onTap: _onResend,
                    child: Text(
                      '¿No recibiste el código? Reenviar',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 24),

          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Cambiar correo electrónico',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final VoidCallback? onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final boxSize = (size.width - 48 - 5 * 10) / 6;
    final clampedSize = boxSize.clamp(44.0, 56.0);

    return SizedBox(
      width: clampedSize,
      height: clampedSize,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (e) {
          if (e is KeyDownEvent &&
              e.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace?.call();
          }
        },
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: controller.text.isNotEmpty
                ? AppColors.primary.withValues(alpha: 0.06)
                : AppColors.surface,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
