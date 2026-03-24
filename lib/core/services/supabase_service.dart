import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = 'https://ejhkjyofrazyxtxkohfo.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVqaGtqeW9mcmF6eXh0eGtvaGZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE3Mjg1MjMsImV4cCI6MjA4NzMwNDUyM30.MsYH7bPlJdjJelexsJn_4mLvWu3NMUCTt6mcgn08dZ8';

/// Call once at app start: `await SupabaseService.initialize();`
class SupabaseService {
  SupabaseService._();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentAuthUser => client.auth.currentUser;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;
}
