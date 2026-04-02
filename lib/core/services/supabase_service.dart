import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = 'https://lxkhroekbinahrmjdjys.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4a2hyb2VrYmluYWhybWpkanlzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ4OTg2MTQsImV4cCI6MjA5MDQ3NDYxNH0.vwy6XwsedgMU6f4jH-onNsHMhYHrix7q13VQr8TMRa0';

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
  static String get url => _supabaseUrl;

  static User? get currentAuthUser => client.auth.currentUser;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;
}
