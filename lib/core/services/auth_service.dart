import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/card/models/digital_card_model.dart';
import '../data/repositories/card_repository.dart';
import '../services/supabase_service.dart';

class AuthService {
  AuthService._();

  static SupabaseClient get _db => SupabaseService.client;

  // ─── OTP: Send ──────────────────────────────────────────────────────────────

  /// Sends a 6-digit OTP to [email]. Works for both login and signup.
  static Future<void> sendOtp(String email) async {
    await _db.auth.signInWithOtp(email: email.trim(), shouldCreateUser: true);
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
    try {
      final res = await _db.auth.verifyOTP(
        email: email.trim(),
        token: token.trim(),
        type: OtpType.email,
      );
      final authUser = res.user;
      if (authUser == null) throw Exception('No se pudo verificar el código.');
      return _fetchOrCreatePublicUser(
        authUser.id,
        email: email.trim(),
        name: name,
      );
    } catch (_) {
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
    late final dynamic res;
    try {
      res = await _db.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name},
      );
    } catch (_) {
      rethrow;
    }

    final authUser = res.user;
    if (authUser == null) throw Exception('No se pudo crear la cuenta.');

    if (res.session != null) {
      try {
        await _db.from('users').upsert({
          'id': authUser.id,
          'name': name.trim(),
          'email': email.trim(),
          'role': 'default',
          'is_active': true,
        });
      } catch (_) {}
      return _fetchOrCreatePublicUser(authUser.id, email: email.trim());
    }

    // Email confirmation required — records will be created lazily on first login.
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
    return UserModel.fromJson(data);
  }

  // ─── Change Password ───────────────────────────────────────────────────────

  static Future<void> changePassword(String newPassword) async {
    await _db.auth.updateUser(UserAttributes(password: newPassword));
  }

  static Future<void> changePasswordWithCurrent({
    required String currentPassword,
    required String newPassword,
  }) async {
    final currentUser = _db.auth.currentUser;
    final email = currentUser?.email?.trim();
    if (currentUser == null || email == null || email.isEmpty) {
      throw Exception('No se encontró una sesión activa.');
    }

    await _db.auth.signInWithPassword(email: email, password: currentPassword);
    await _db.auth.updateUser(UserAttributes(password: newPassword));
  }

  // ─── Fetch card for a user ─────────────────────────────────────────────────

  static Future<List<DigitalCardModel>> fetchUserCards(String userId) {
    return CardRepository.fetchCardsForUser(userId);
  }

  static Future<DigitalCardModel?> fetchUserCard(String userId) async {
    final cards = await fetchUserCards(userId);
    if (cards.isEmpty) return null;
    return cards.first;
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
      if (rows.isNotEmpty) {
        return UserModel.fromJson(rows.first);
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
    } catch (_) {}

    // 3. Try to fetch the freshly created row
    try {
      final data = await _db.from('users').select().eq('id', authId).single();
      return UserModel.fromJson(data);
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
}
