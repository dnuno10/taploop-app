import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/data/app_state.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/taploop_button.dart';
import '../../../core/widgets/taploop_progress_indicator.dart';
import '../../../core/widgets/taploop_text_field.dart';
import '../../../core/widgets/taploop_toast.dart';
import '../../auth/models/user_model.dart';
import '../../card/models/digital_card_model.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _changingPassword = false;
  bool _savingLanguage = false;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _changingPassword = true);
    try {
      await AuthService.changePasswordWithCurrent(
        currentPassword: _currentPasswordCtrl.text,
        newPassword: _newPasswordCtrl.text,
      );
      if (!mounted) return;
      _currentPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      _confirmPasswordCtrl.clear();
      TapLoopToast.show(
        context,
        'Contraseña actualizada correctamente.',
        TapLoopToastType.success,
      );
    } catch (error) {
      if (!mounted) return;
      TapLoopToast.show(
        context,
        _friendlyPasswordError(error),
        TapLoopToastType.error,
      );
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  Future<void> _setLanguage(String language) async {
    final user = appState.currentUser;
    if (user == null || user.language == language || _savingLanguage) return;
    setState(() => _savingLanguage = true);
    try {
      final updated = await AuthService.updateProfile(
        user.copyWith(language: language),
      );
      appState.setUser(updated);
      if (!mounted) return;
      TapLoopToast.show(
        context,
        'Idioma del perfil digital actualizado.',
        TapLoopToastType.success,
      );
    } catch (_) {
      if (!mounted) return;
      TapLoopToast.show(
        context,
        'No se pudo actualizar el idioma. Intenta de nuevo.',
        TapLoopToastType.error,
      );
    } finally {
      if (mounted) setState(() => _savingLanguage = false);
    }
  }

  String _friendlyPasswordError(Object error) {
    final raw = error.toString();
    if (raw.contains('Invalid login credentials')) {
      return 'La contraseña actual es incorrecta.';
    }
    if (raw.contains('Password should be')) {
      return 'La nueva contraseña no cumple con los requisitos mínimos.';
    }
    return 'No se pudo actualizar la contraseña. Intenta de nuevo.';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final user = appState.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(child: TapLoopProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
                  decoration: BoxDecoration(
                    color: context.bgCard,
                    border: Border(
                      bottom: BorderSide(color: context.borderColor),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configuración',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Administra la sesión activa, la tarjeta seleccionada y la seguridad de tu cuenta.',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                    children: [
                      _ProfileCard(user: user, card: appState.currentCard),
                      const SizedBox(height: 20),
                      _SettingsSection(
                        title: 'Seguridad',
                        child: Form(
                          key: _passwordFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cambiar contraseña',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: context.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Confirma tu contraseña actual y define una nueva contraseña para esta sesión.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: context.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 18),
                              TapLoopTextField(
                                label: 'Contraseña actual',
                                hint: 'Ingresa tu contraseña actual',
                                controller: _currentPasswordCtrl,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingresa tu contraseña actual';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TapLoopTextField(
                                label: 'Nueva contraseña',
                                hint: 'Mínimo 8 caracteres',
                                controller: _newPasswordCtrl,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingresa una nueva contraseña';
                                  }
                                  if (value.length < 8) {
                                    return 'La nueva contraseña debe tener al menos 8 caracteres';
                                  }
                                  if (value == _currentPasswordCtrl.text) {
                                    return 'La nueva contraseña debe ser diferente a la actual';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TapLoopTextField(
                                label: 'Confirmar nueva contraseña',
                                hint: 'Repite la nueva contraseña',
                                controller: _confirmPasswordCtrl,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Confirma la nueva contraseña';
                                  }
                                  if (value != _newPasswordCtrl.text) {
                                    return 'Las contraseñas no coinciden';
                                  }
                                  return null;
                                },
                                onSubmitted: (_) => _changePassword(),
                              ),
                              const SizedBox(height: 18),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TapLoopButton(
                                  label: 'Actualizar contraseña',
                                  onPressed: _changingPassword
                                      ? null
                                      : _changePassword,
                                  isLoading: _changingPassword,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _SettingsSection(
                        title: 'Idioma del perfil digital',
                        child: _LanguageSelector(
                          language: user.language,
                          saving: _savingLanguage,
                          onChanged: _setLanguage,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _SettingsSection(
                        title: 'Sesión',
                        child: Column(
                          children: [
                            _SettingsRow(
                              icon: Icons.mail_outline,
                              title: user.email,
                              subtitle: 'Correo de la sesión activa.',
                            ),
                            Divider(color: context.borderColor, height: 28),
                            _SettingsRow(
                              icon: Icons.logout_rounded,
                              title: 'Cerrar sesión',
                              subtitle:
                                  'Termina la sesión en este dispositivo.',
                              onTap: () async {
                                await AuthService.signOut();
                                appState.clear();
                              },
                              titleColor: AppColors.error,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserModel user;
  final DigitalCardModel? card;

  const _ProfileCard({required this.user, required this.card});

  @override
  Widget build(BuildContext context) {
    final title = card?.name.trim().isNotEmpty == true ? card!.name : user.name;
    final subtitleParts = [
      if (card?.jobTitle.trim().isNotEmpty == true) card!.jobTitle,
      if (card?.company.trim().isNotEmpty == true) card!.company,
      if (card?.publicSlug.trim().isNotEmpty == true) '@${card!.publicSlug}',
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Center(
              child: Text(
                _initials(title),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitleParts.isEmpty
                      ? user.email
                      : subtitleParts.join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HelpTitle(
            title: title,
            helpText: 'Agrupa las opciones relacionadas con $title.',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: context.bgSubtle,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: context.textSecondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor ?? context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String language;
  final bool saving;
  final ValueChanged<String> onChanged;

  const _LanguageSelector({
    required this.language,
    required this.saving,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Elige en qué idioma se muestran las etiquetas y textos fijos de '
          'tu perfil digital público (no afecta este panel ni el resto del '
          'dashboard).',
          style: GoogleFonts.dmSans(fontSize: 13, color: context.textSecondary),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _LanguageOption(
              label: 'Español',
              code: 'es',
              selected: language == 'es',
              disabled: saving,
              onTap: () => onChanged('es'),
            ),
            _LanguageOption(
              label: 'English',
              code: 'en',
              selected: language == 'en',
              disabled: saving,
              onTap: () => onChanged('en'),
            ),
          ],
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String code;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.code,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : context.bgSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : context.borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 16,
              color: selected ? AppColors.primary : context.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _initials(String value) {
  final parts = value
      .trim()
      .split(' ')
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  if (parts.isNotEmpty) return parts.first[0].toUpperCase();
  return 'TL';
}
