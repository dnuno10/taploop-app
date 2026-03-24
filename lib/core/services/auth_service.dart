import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/card/models/digital_card_model.dart';
import '../../features/card/models/contact_item_model.dart';
import '../../features/card/models/social_link_model.dart';
import '../services/supabase_service.dart';

class AuthService {
  AuthService._();

  static SupabaseClient get _db => SupabaseService.client;

  // ─── OTP: Send ──────────────────────────────────────────────────────────────

  /// Sends a 6-digit OTP to [email]. Works for both login and signup.
  static Future<void> sendOtp(String email) async {
    print('[AuthService.sendOtp] Enviando OTP a $email');
    await _db.auth.signInWithOtp(email: email.trim(), shouldCreateUser: true);
    print('[AuthService.sendOtp] OTP enviado OK');
  }

  // ─── OTP: Verify ─────────────────────────────────────────────────────────────

  /// Verifies the 6-digit [token] for [email].
  /// Pass [name] (non-null) when coming from the signup flow so that the
  /// public `users` row is created with the real name, not the email prefix.
  static Future<UserModel> verifyOtp({
    required String email,
    required String token,
    String? name,
  }) async {
    print('[AuthService.verifyOtp] Verificando OTP para $email');
    try {
      final res = await _db.auth.verifyOTP(
        email: email.trim(),
        token: token.trim(),
        type: OtpType.email,
      );
      print('[AuthService.verifyOtp] OK — user=${res.user?.id}');
      final authUser = res.user;
      if (authUser == null) throw Exception('No se pudo verificar el código.');
      return _fetchOrCreatePublicUser(
        authUser.id,
        email: email.trim(),
        name: name,
      );
    } catch (e, st) {
      print('[AuthService.verifyOtp] ERROR: $e');
      print(st);
      rethrow;
    }
  }

  // ─── Sign In ───────────────────────────────────────────────────────────────

  static Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _db.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final authUser = res.user;
    if (authUser == null) throw Exception('Autenticación fallida.');
    return _fetchOrCreatePublicUser(authUser.id, email: email);
  }

  // ─── Sign Up ───────────────────────────────────────────────────────────────

  static Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    print('[AuthService.signUp] Iniciando registro para $email');
    late final dynamic res;
    try {
      res = await _db.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name},
      );
    } catch (e, st) {
      print('[AuthService.signUp] ERROR en auth.signUp: $e');
      print(st);
      rethrow;
    }
    print(
      '[AuthService.signUp] auth.signUp OK — user=${res.user?.id} session=${res.session != null}',
    );

    final authUser = res.user;
    if (authUser == null) throw Exception('No se pudo crear la cuenta.');

    if (res.session != null) {
      print('[AuthService.signUp] Sesión activa — escribiendo en DB');
      try {
        await _db.from('users').upsert({
          'id': authUser.id,
          'name': name.trim(),
          'email': email.trim(),
          'role': 'default',
          'is_active': true,
        });
        print('[AuthService.signUp] users upsert OK');
        final slug = _generateSlug(name, authUser.id);
        await _db.from('digital_cards').upsert({
          'user_id': authUser.id,
          'name': name.trim(),
          'job_title': '',
          'company': '',
          'bio': '',
          'public_slug': slug,
          'is_active': true,
          'theme_style': 'white',
          'layout_style': 'centered',
          'primary_color': 0xFFEF6820,
          'bg_style': 'plain',
        });
        print('[AuthService.signUp] digital_cards upsert OK');
      } catch (e) {
        print('[AuthService.signUp] ERROR en upsert DB: $e');
      }
      return _fetchOrCreatePublicUser(authUser.id, email: email.trim());
    }

    // Email confirmation required — records will be created lazily on first login.
    print('[AuthService.signUp] Sin sesión — confirmación de email requerida');
    return UserModel(
      id: authUser.id,
      name: name.trim(),
      email: email.trim(),
      emailVerified: false,
      createdAt: DateTime.now(),
    );
  }

  // ─── Restore session ───────────────────────────────────────────────────────

  static Future<UserModel?> restoreSession() async {
    final authUser = _db.auth.currentUser;
    if (authUser == null) return null;
    try {
      return await _fetchOrCreatePublicUser(
        authUser.id,
        email: authUser.email ?? '',
      );
    } catch (_) {
      return UserModel(
        id: authUser.id,
        name:
            (authUser.userMetadata?['name'] as String?) ??
            (authUser.email?.split('@').first ?? 'Usuario'),
        email: authUser.email ?? '',
        emailVerified: authUser.emailConfirmedAt != null,
        createdAt: DateTime.now(),
      );
    }
  }

  // ─── Sign Out ──────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    await _db.auth.signOut();
  }

  // ─── Reset Password ────────────────────────────────────────────────────────

  static Future<void> resetPassword(String email) async {
    await _db.auth.resetPasswordForEmail(email.trim());
  }

  // ─── Update Profile ────────────────────────────────────────────────────────

  static Future<UserModel> updateProfile(UserModel user) async {
    final payload = user.toJson()..remove('id');
    await _db.from('users').update(payload).eq('id', user.id);
    final data = await _db.from('users').select().eq('id', user.id).single();
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  // ─── Change Password ───────────────────────────────────────────────────────

  static Future<void> changePassword(String newPassword) async {
    await _db.auth.updateUser(UserAttributes(password: newPassword));
  }

  // ─── Fetch card for a user ─────────────────────────────────────────────────

  static Future<DigitalCardModel?> fetchUserCard(String userId) async {
    final rows = await SupabaseService.client
        .from('digital_cards')
        .select()
        .eq('user_id', userId)
        .order('created_at')
        .limit(1);
    if ((rows as List).isEmpty) return null;
    final cardJson = rows.first as Map<String, dynamic>;
    final cardId = cardJson['id'] as String;

    final contacts = await SupabaseService.client
        .from('contact_items')
        .select()
        .eq('card_id', cardId)
        .order('sort_order');

    final socials = await SupabaseService.client
        .from('social_links')
        .select()
        .eq('card_id', cardId)
        .order('sort_order');

    return DigitalCardModel.fromJson(
      cardJson,
      contactItems: (contacts as List)
          .map((e) => ContactItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      socialLinks: (socials as List)
          .map((e) => SocialLinkModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  static Future<UserModel> _fetchOrCreatePublicUser(
    String authId, {
    required String email,
    String? name, // preferred display name from signup form
  }) async {
    // 1. Try to fetch existing row
    try {
      final rows = await _db.from('users').select().eq('id', authId).limit(1);
      if ((rows as List).isNotEmpty) {
        return UserModel.fromJson((rows as List).first as Map<String, dynamic>);
      }
    } catch (_) {}

    // 2. Row missing — user has an active session now, create records.
    //    Use provided name (signup) or fall back to email prefix (login).
    final resolvedName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : email.split('@').first;
    try {
      await _db.from('users').upsert({
        'id': authId,
        'name': resolvedName,
        'email': email,
        'role': 'default',
        'is_active': true,
      });
      print('[AuthService] users upsert OK ($resolvedName)');
      final slug = _generateSlug(resolvedName, authId);
      await _db.from('digital_cards').upsert({
        'user_id': authId,
        'name': resolvedName,
        'job_title': '',
        'company': '',
        'bio': '',
        'public_slug': slug,
        'is_active': true,
        'theme_style': 'white',
        'layout_style': 'centered',
        'primary_color': 0xFFEF6820,
        'bg_style': 'plain',
      });
      print('[AuthService] digital_cards upsert OK (slug=$slug)');
    } catch (e) {
      print('[AuthService] ERROR en upsert DB: $e');
    }

    // 3. Try to fetch the freshly created row
    try {
      final data = await _db.from('users').select().eq('id', authId).single();
      return UserModel.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      // 4. Last resort: build from auth data so the login never hard-fails
      return UserModel(
        id: authId,
        name: resolvedName,
        email: email,
        createdAt: DateTime.now(),
      );
    }
  }

  static String _generateSlug(String name, String uid) {
    final base = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
    final suffix = uid.substring(0, 6);
    return '$base-$suffix';
  }
}
