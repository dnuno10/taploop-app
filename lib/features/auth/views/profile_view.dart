import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/taploop_button.dart';
import '../../../core/widgets/taploop_text_field.dart';
import '../../../core/data/app_state.dart';
import '../../../core/services/auth_service.dart';
import '../models/user_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _jobCtrl;
  late final TextEditingController _companyCtrl;
  bool _saving = false;
  final bool _changingPassword = false;
  bool _edited = false;

  @override
  void initState() {
    super.initState();
    final user = appState.currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _jobCtrl = TextEditingController(text: user?.jobTitle ?? '');
    _companyCtrl = TextEditingController(
      text: appState.currentCard?.company ?? '',
    );
    for (final c in [
      _nameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _jobCtrl,
      _companyCtrl,
    ]) {
      c.addListener(() => setState(() => _edited = true));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _jobCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    final user = appState.currentUser;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      final updated = user.copyWith(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        jobTitle: _jobCtrl.text.trim(),
      );
      final saved = await AuthService.updateProfile(updated);
      appState.setUser(saved);
      if (mounted) {
        setState(() {
          _saving = false;
          _edited = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onChangePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChangePasswordSheet(
        onSave: (current, next) async {
          await Future.delayed(const Duration(seconds: 1));
        },
      ),
    );
  }

  void _onDeleteAccount() {
    showDialog(context: context, builder: (_) => _DeleteAccountDialog());
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: AppColors.white,
        actions: [
          if (_edited)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: _onSave,
                child: Text(
                  'Guardar',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop || isTablet ? 760 : double.infinity,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop || isTablet ? 24 : 16,
              vertical: 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar section
                  if (appState.currentUser != null)
                    _AvatarSection(user: appState.currentUser!),
                  const SizedBox(height: 24),

                  // Personal info card
                  _SectionCard(
                    title: 'Información personal',
                    children: [
                      TapLoopTextField(
                        label: 'Nombre completo',
                        controller: _nameCtrl,
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: AppColors.grey,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nombre requerido'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TapLoopTextField(
                        label: 'Teléfono',
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          size: 20,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TapLoopTextField(
                        label: 'Cargo / Puesto',
                        controller: _jobCtrl,
                        prefixIcon: const Icon(
                          Icons.work_outline,
                          size: 20,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TapLoopTextField(
                        label: 'Empresa',
                        controller: _companyCtrl,
                        prefixIcon: const Icon(
                          Icons.business_outlined,
                          size: 20,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Account info card
                  _SectionCard(
                    title: 'Cuenta',
                    children: [
                      TapLoopTextField(
                        label: 'Correo electrónico',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.mail_outline,
                          size: 20,
                          color: AppColors.grey,
                        ),
                        suffixIcon:
                            (appState.currentUser?.emailVerified ?? false)
                            ? const Tooltip(
                                message: 'Correo verificado',
                                child: Icon(
                                  Icons.verified,
                                  size: 20,
                                  color: AppColors.success,
                                ),
                              )
                            : const Tooltip(
                                message: 'Correo no verificado',
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  size: 20,
                                  color: AppColors.warning,
                                ),
                              ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Correo requerido';
                          }
                          if (!RegExp(
                            r'^[^@]+@[^@]+\.[^@]+',
                          ).hasMatch(v.trim())) {
                            return 'Correo inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TapLoopButton(
                        label: 'Cambiar contraseña',
                        onPressed: _onChangePassword,
                        variant: TapLoopButtonVariant.outline,
                        isLoading: _changingPassword,
                        icon: const Icon(
                          Icons.lock_reset_outlined,
                          size: 18,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Save button
                  TapLoopButton(
                    label: 'Guardar cambios',
                    onPressed: _onSave,
                    variant: TapLoopButtonVariant.primary,
                    isLoading: _saving,
                  ),
                  const SizedBox(height: 24),

                  // Danger zone
                  _DangerZone(onDelete: _onDeleteAccount),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  final UserModel user;
  const _AvatarSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Text(
                      user.initials,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 13,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.email,
                style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey),
              ),
              if (user.emailVerified) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Correo verificado',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  final VoidCallback onDelete;
  const _DangerZone({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zona de peligro',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Estas acciones son permanentes e irreversibles.',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: onDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Eliminar mi cuenta',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Modals ───────────────────────────────────────────────────────────────────

class _ChangePasswordSheet extends StatefulWidget {
  final Future<void> Function(String current, String next) onSave;
  const _ChangePasswordSheet({required this.onSave});

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await widget.onSave(_currentCtrl.text, _newCtrl.text);
    if (mounted) {
      setState(() => _loading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña actualizada'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Cambiar contraseña',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            TapLoopTextField(
              label: 'Contraseña actual',
              controller: _currentCtrl,
              obscureText: true,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Ingresa tu contraseña actual'
                  : null,
            ),
            const SizedBox(height: 16),
            TapLoopTextField(
              label: 'Nueva contraseña',
              controller: _newCtrl,
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Ingresa la nueva contraseña';
                }
                if (v.length < 8) return 'Mínimo 8 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TapLoopTextField(
              label: 'Confirmar nueva contraseña',
              controller: _confirmCtrl,
              obscureText: true,
              validator: (v) {
                if (v != _newCtrl.text) return 'Las contraseñas no coinciden';
                return null;
              },
            ),
            const SizedBox(height: 24),
            TapLoopButton(
              label: 'Actualizar contraseña',
              onPressed: _save,
              variant: TapLoopButtonVariant.secondary,
              isLoading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccountDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_outlined,
                color: AppColors.error,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Eliminar cuenta',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta acción eliminará permanentemente tu cuenta y todos tus datos. No podrás recuperarlos.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Sí, eliminar mi cuenta',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
