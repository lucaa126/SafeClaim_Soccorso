import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/richieste/richieste_page.dart';
import '../features/impostazioni/settings_page.dart';
import '../features/dettaglio/dettaglio_intervento_page.dart';
import '../features/flotta/flotta_page.dart';
import '../features/analytics/analytics_page.dart';
import '../features/login/login.dart';
import '../features/login/login_api_service.dart';

class SoccorsoApp extends StatefulWidget {
  const SoccorsoApp({super.key});

  // Metodo statico per accedere al cambio tema da qualsiasi pagina
  static SoccorsoAppState of(BuildContext context) =>
      context.findAncestorStateOfType<SoccorsoAppState>()!;

  @override
  State<SoccorsoApp> createState() => SoccorsoAppState();
}

class SoccorsoAppState extends State<SoccorsoApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Soccorso Admin',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: _themeMode,

      // ---------------- ROTTE ----------------
      initialRoute: Routes.login,
      routes: {
        Routes.login: (_) => const LoginPage(),
        Routes.dashboard: (_) => const DashboardPage(),
        Routes.richieste: (_) => const RichiestePage(),
        Routes.impostazioni: (_) => const SettingsPage(),
        Routes.flotta: (_) => const FlottaPage(),
        Routes.analytics: (_) => const AnalyticsPage(),
        Routes.logout: (_) => const _LogoutPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == Routes.dettaglio) {
          final args =
              (settings.arguments as DettaglioArgs?) ??
              const DettaglioArgs(id: 'SOS-2491', cliente: '+39 333 1234567');
          return MaterialPageRoute(
            builder: (_) => DettaglioInterventoPage(args: args),
          );
        }
        return null;
      },
    );
  }
}

class _LogoutPage extends StatefulWidget {
  const _LogoutPage();

  @override
  State<_LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<_LogoutPage> {
  final LoginApiService _loginApi = LoginApiService();

  @override
  void initState() {
    super.initState();
    _logout();
  }

  Future<void> _logout() async {
    String? errorMessage;

    try {
      await _loginApi.logout();
    } catch (e) {
      errorMessage = 'Logout Keycloak non completato: $e';
    }

    if (!mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    navigator.pushNamedAndRemoveUntil(Routes.login, (route) => false);

    if (errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
