import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/supabase_service.dart';
import 'core/services/auth_service.dart';
import 'core/data/app_state.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/taploop_loading_view.dart';
import 'core/widgets/taploop_motion.dart';
import 'features/home/views/home_shell.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/legal_pages_view.dart';
// import 'features/auth/views/register_view.dart';
// import 'features/auth/views/forgot_password_view.dart';
// import 'features/auth/views/otp_view.dart';
import 'features/card/views/public_card_view.dart';

/// Global theme mode notifier
/// Test Ivanovich
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
StreamSubscription<AuthState>? _authSubscription;
bool _syncingAuth = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await SupabaseService.initialize();
  await _bootstrapAppState();
  runApp(const TapLoopApp());
}

Future<void> _hydrateAuthenticatedState() async {
  final user = await AuthService.restoreSession();
  if (user == null) {
    appState.clear();
    return;
  }
  appState.setUser(user);
  appState.setLoadingCard(true);
  try {
    final cards = await AuthService.fetchUserCards(user.id);
    appState.setCards(cards);
  } finally {
    appState.setLoadingCard(false);
  }
}

Future<void> _bootstrapAppState() async {
  appState.setLoadingUser(true);
  try {
    await _hydrateAuthenticatedState();
  } catch (_) {
    appState.setError('No se pudo restaurar la sesión.');
  } finally {
    appState.setLoadingUser(false);
  }
}

Future<void> _handleAuthState(AuthState state) async {
  if (_syncingAuth) return;

  if (state.event == AuthChangeEvent.signedOut) {
    appState.clear();
    return;
  }

  final shouldSync =
      state.event == AuthChangeEvent.signedIn ||
      state.event == AuthChangeEvent.tokenRefreshed ||
      state.event == AuthChangeEvent.userUpdated;

  if (!shouldSync) return;

  _syncingAuth = true;
  try {
    await _hydrateAuthenticatedState();
  } catch (_) {
    // Preserve existing state if there is a transient auth/network issue.
  } finally {
    _syncingAuth = false;
  }
}

// ─── Router ───────────────────────────────────────────────────────────────────

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _motionPage(
        state,
        _AuthGate(pendingNfc: state.uri.queryParameters['pendingNfc']),
      ),
    ),
    GoRoute(
      path: '/terminos',
      pageBuilder: (context, state) =>
          _motionPage(state, const TermsAndConditionsView()),
    ),
    GoRoute(
      path: '/privacidad',
      pageBuilder: (context, state) =>
          _motionPage(state, const PrivacyPolicyView()),
    ),
    // Flujo anterior comentado a petición del proyecto:
    // GoRoute(
    //   path: '/register',
    //   builder: (context, state) {
    //     String? pendingNfc = state.uri.queryParameters['pendingNfc'];
    //     final extra = state.extra;
    //     if (extra is Map) {
    //       pendingNfc ??= extra['pendingNfc']?.toString();
    //     }
    //     return RegisterView(pendingNfc: pendingNfc);
    //   },
    // ),
    // GoRoute(
    //   path: '/forgot-password',
    //   builder: (context, state) => const ForgotPasswordView(),
    // ),
    // GoRoute(
    //   path: '/otp-verify',
    //   builder: (context, state) {
    //     final extra = state.extra;
    //     final data = extra is Map ? extra.cast<String, String?>() : null;
    //     final email = data?['email'];
    //     if (email == null || email.isEmpty) return const LoginView();
    //     return OtpView(
    //       email: email,
    //       name: data?['name'],
    //       pendingNfc: data?['pendingNfc'],
    //     );
    //   },
    // ),
    GoRoute(
      path: '/nfc/:serial',
      pageBuilder: (context, state) {
        final serial = state.pathParameters['serial']!;
        return _motionPage(state, PublicCardView(nfcSerial: serial));
      },
    ),
    GoRoute(
      path: '/u/:userId',
      pageBuilder: (context, state) {
        final userId = state.pathParameters['userId']!;
        final via = state.uri.queryParameters['via'];
        return _motionPage(state, PublicCardView(userId: userId, via: via));
      },
    ),
    GoRoute(
      path: '/:slug',
      pageBuilder: (context, state) {
        final slug = state.pathParameters['slug']!;
        final via = state.uri.queryParameters['via'];
        return _motionPage(state, PublicCardView(slug: slug, via: via));
      },
    ),
  ],
);

CustomTransitionPage<void> _motionPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: TapLoopMotion.normal,
    reverseTransitionDuration: TapLoopMotion.fast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: TapLoopMotion.entrance,
        reverseCurve: TapLoopMotion.exit,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.012),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

// ─── App ──────────────────────────────────────────────────────────────────────

class TapLoopApp extends StatefulWidget {
  const TapLoopApp({super.key});

  @override
  State<TapLoopApp> createState() => _TapLoopAppState();
}

class _TapLoopAppState extends State<TapLoopApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authSubscription ??= SupabaseService.authStateChanges.listen((state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(_handleAuthState(state));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (_, mode, __) => MaterialApp.router(
        title: 'TapLoop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        routerConfig: _router,
      ),
    );
  }
}

// ─── Auth Gate ────────────────────────────────────────────────────────────────

class _AuthGate extends StatelessWidget {
  final String? pendingNfc;

  const _AuthGate({this.pendingNfc});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final bootstrapping = appState.loadingUser && !appState.isAuthenticated;
        if (bootstrapping) return const _BootstrapView();
        if (appState.isAuthenticated) return const HomeShell();
        return LoginView(pendingNfc: pendingNfc);
      },
    );
  }
}

class _BootstrapView extends StatelessWidget {
  const _BootstrapView();

  @override
  Widget build(BuildContext context) {
    return const TapLoopLoadingView(scaffold: true);
  }
}
