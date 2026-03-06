import 'package:flutter/material.dart';
import 'routes.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/richieste/richieste_page.dart';
import '../features/impostazioni/settings_page.dart';
import '../features/shared/placeholder_page.dart';
import '../features/dettaglio/dettaglio_intervento_page.dart';
import '../features/flotta/flotta_page.dart';
import '../features/analytics/analytics_page.dart';

class SoccorsoApp extends StatefulWidget {
  const SoccorsoApp({super.key});

  // Metodo statico per accedere al cambio tema da qualsiasi pagina
  static _SoccorsoAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_SoccorsoAppState>()!;

  @override
  State<SoccorsoApp> createState() => _SoccorsoAppState();
}

class _SoccorsoAppState extends State<SoccorsoApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6A7AF4);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Soccorso Admin',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: seed,
        scaffoldBackgroundColor: const Color(0xFFF1F3F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF1F3F9),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: seed,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      themeMode: _themeMode,

      // ---------------- ROTTE ----------------
      initialRoute: Routes.dashboard,
      routes: {
        Routes.dashboard: (_) => const DashboardPage(),
        Routes.richieste: (_) => const RichiestePage(),
        Routes.impostazioni: (_) => const SettingsPage(),
        Routes.flotta: (_) => const FlottaPage(),
        Routes.analytics: (_) => const AnalyticsPage(),
        Routes.logout: (_) => const PlaceholderPage(title: 'Logout', currentRoute: Routes.logout),
      },
      onGenerateRoute: (settings) {
        if (settings.name == Routes.dettaglio) {
          final args = (settings.arguments as DettaglioArgs?) ??
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
