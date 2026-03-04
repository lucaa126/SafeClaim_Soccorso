// main.dart
// UI + stile allineato al file che mi hai caricato (card bianche / dark #2C2C2C,
// radius 20, ombre solo in light, color primario #6A7AF4) + ROTTE (Navigator named)
// + HAMBURGER MENU IDENTICO (riusato pari pari dal tuo file).

import 'package:flutter/material.dart';

void main() {
  runApp(const SoccorsoApp());
}

class Routes {
  static const dashboard = '/dashboard';
  static const richieste = '/richieste';
  static const dettaglio = '/dettaglio';
  static const flotta = '/flotta';
  static const analytics = '/analytics';
  static const impostazioni = '/impostazioni';
  static const logout = '/logout';
}

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
        Routes.flotta: (_) => const PlaceholderPage(title: 'Flotta'),
        Routes.analytics: (_) => const PlaceholderPage(title: 'Analytics'),
        Routes.logout: (_) => const PlaceholderPage(title: 'Logout'),
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

// ============================================================================
// STESSO IDENTICO DRAWER (hamburger menu) DEL TUO FILE
// (ho cambiato SOLO la navigazione: pushReplacementNamed)
// ============================================================================

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    "SOCCORSO",
                    style: TextStyle(
                      color: Color(0xFFE57373),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _fullScreenSidebarItem(
              context,
              Icons.grid_view_rounded,
              "Dashboard",
              isDark,
              Routes.dashboard,
            ),
            _fullScreenSidebarItem(
              context,
              Icons.campaign_outlined,
              "Richieste",
              isDark,
              Routes.richieste,
            ),
            _fullScreenSidebarItem(
              context,
              Icons.local_shipping_outlined,
              "Flotta",
              isDark,
              Routes.flotta,
            ),
            _fullScreenSidebarItem(
              context,
              Icons.analytics_outlined,
              "Analytics",
              isDark,
              Routes.analytics,
            ),
            _fullScreenSidebarItem(
              context,
              Icons.settings,
              "Impostazioni",
              isDark,
              Routes.impostazioni,
            ),
            const Spacer(),
            const Divider(),
            _fullScreenSidebarItem(
              context,
              Icons.logout,
              "Logout",
              isDark,
              Routes.logout,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _fullScreenSidebarItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isDark,
    String route,
  ) {
    bool isSelected = currentRoute == route;

    return InkWell(
      onTap: () {
        Navigator.pop(context); // Chiude il drawer
        if (!isSelected) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 32,
              child: Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey,
                size: 28,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                color:
                    isSelected ? Colors.blue : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildSharedThemeToggle(BuildContext context, bool isDark) {
  return ToggleButtons(
    isSelected: [!isDark, isDark],
    onPressed: (index) {
      SoccorsoApp.of(context).toggleTheme(index == 1);
    },
    borderRadius: BorderRadius.circular(8),
    constraints: const BoxConstraints(minHeight: 32, minWidth: 36),
    selectedColor: Colors.white,
    fillColor: Colors.blue,
    children: const [
      Icon(Icons.wb_sunny_outlined, size: 18),
      Icon(Icons.nightlight_round, size: 18)
    ],
  );
}

// ============================================================================
// DASHBOARD (replica schermata) con lo stile del tuo file
// ============================================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool operativoOnline = true;

  final richieste = const [
    _QueueRow(
      veicolo: 'Fiat Ducato',
      tipo: '(Furgone)',
      statusText: 'In Attesa',
      statusKind: _StatusKind.pending,
      actionText: 'Accetta',
      actionKind: _ActionKind.outlinePrimary,
    ),
    _QueueRow(
      veicolo: 'BMW X3',
      tipo: '(SUV)',
      statusText: 'accepted',
      statusKind: _StatusKind.accepted,
      actionText: 'Completa',
      actionKind: _ActionKind.filledSuccess,
    ),
    _QueueRow(
      veicolo: 'Smart ForTwo',
      tipo: '',
      statusText: 'handled',
      statusKind: _StatusKind.handled,
      actionText: '',
      actionKind: _ActionKind.none,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        actions: [
          buildSharedThemeToggle(context, isDark),
          const SizedBox(width: 16),
        ],
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const AppDrawer(currentRoute: Routes.dashboard),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (come screenshot: titolo grande + welcome)
            Text(
              "Dashboard Operativa",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF374151),
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Benvenuto, Officina Centrale",
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),

            // Stato Operativo
            _card(
              isDark: isDark,
              color: cardColor,
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2EE6A6), Color(0xFF6A7AF4)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Stato Operativo",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          operativoOnline
                              ? "Online - Ricezione chiamate"
                              : "Offline - Pausa",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: operativoOnline,
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xFF6A7AF4),
                    onChanged: (v) => setState(() => operativoOnline = v),
                  )
                ],
              ),
            ),
            const SizedBox(height: 14),

            // KPI Cards
            _kpi(
              isDark: isDark,
              cardColor: cardColor,
              bubble: const Color(0xFF6A7AF4),
              bubbleChild: const Text(
                "SOS",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
              value: "3",
              label: "Richieste Attive",
            ),
            const SizedBox(height: 14),
            _kpi(
              isDark: isDark,
              cardColor: cardColor,
              bubble: const Color(0xFF2EE6A6),
              bubbleChild: const Icon(Icons.check_rounded, color: Colors.white),
              value: "12",
              label: "Completati Oggi",
            ),
            const SizedBox(height: 14),
            _kpi(
              isDark: isDark,
              cardColor: cardColor,
              bubble: const Color(0xFFFFC24A),
              bubbleChild: const Icon(Icons.access_time_rounded, color: Colors.white),
              value: "14m",
              label: "Tempo Medio",
            ),

            const SizedBox(height: 26),

            Text(
              "Richieste in Coda",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF374151),
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 14),

            _card(
              isDark: isDark,
              color: cardColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text("Veicolo",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black87,
                            )),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text("Posizione",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black87,
                            )),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text("Stato",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black87,
                            )),
                      ),
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text("Azioni",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black87,
                              )),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
                  ...List.generate(richieste.length, (i) {
                    final r = richieste[i];
                    return Column(
                      children: [
                        _queueRow(context, isDark, r),
                        if (i != richieste.length - 1)
                          Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _queueRow(BuildContext context, bool isDark, _QueueRow r) {
    final status = _statusChip(isDark, r.statusKind, r.statusText);

    Widget action = const SizedBox.shrink();
    if (r.actionKind != _ActionKind.none && r.actionText.isNotEmpty) {
      action = _actionButton(
        isDark: isDark,
        kind: r.actionKind,
        text: r.actionText,
        onTap: () {
          // apro dettaglio come screenshot
          Navigator.pushNamed(
            context,
            Routes.dettaglio,
            arguments: const DettaglioArgs(id: 'SOS-2491', cliente: '+39 333 1234567'),
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.veicolo,
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                if (r.tipo.isNotEmpty)
                  Text(
                    r.tipo,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(Icons.location_on_rounded,
                    size: 16, color: isDark ? Colors.white : Colors.black87),
                const SizedBox(width: 6),
                Text(
                  "Mappa",
                  style: const TextStyle(
                    color: Color(0xFF6A7AF4),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 3, child: Align(alignment: Alignment.centerLeft, child: status)),
          Expanded(
            flex: 3,
            child: Align(alignment: Alignment.centerRight, child: action),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DETTAGLIO INTERVENTO (replica) con stile del tuo file
// ============================================================================

class DettaglioArgs {
  final String id;
  final String cliente;
  const DettaglioArgs({required this.id, required this.cliente});
}

class DettaglioInterventoPage extends StatelessWidget {
  final DettaglioArgs args;
  const DettaglioInterventoPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dettaglio Intervento",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        centerTitle: false,
        actions: [
          buildSharedThemeToggle(context, isDark),
          const SizedBox(width: 16),
        ],
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const AppDrawer(currentRoute: Routes.dashboard),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card(
              isDark: isDark,
              color: cardColor,
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ID:",
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.grey,
                                  fontWeight: FontWeight.w800,
                                )),
                            const SizedBox(height: 10),
                            Text("Cliente:",
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.grey,
                                  fontWeight: FontWeight.w800,
                                )),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            args.id,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            args.cliente,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Mappa (mock UI)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      height: 260,
                      color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFEFEFEF),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 120,
                              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFF2F3A44),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  _zoomBox(isDark),
                                ],
                              ),
                            ),
                          ),

                          // pin
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.location_on_rounded, size: 44, color: Color(0xFF6A7AF4)),
                              ],
                            ),
                          ),

                          // tooltip
                          Positioned(
                            left: 150,
                            top: 28,
                            child: _tooltipBubble(isDark),
                          ),

                          Positioned(
                            right: 12,
                            bottom: 10,
                            child: Opacity(
                              opacity: 0.55,
                              child: Text(
                                "Leaflet | © OpenStreetMap",
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottoni
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A7AF4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Prendi in Carico",
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF4D5A),
                        side: const BorderSide(color: Color(0xFFFF4D5A), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Rifiuta",
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            Row(
              children: [
                Text(
                  "Traffico Live",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF374151),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.refresh_rounded,
                      color: isDark ? Colors.white70 : Colors.black54),
                )
              ],
            ),
            const SizedBox(height: 12),

            _trafficCard(
              isDark: isDark,
              cardColor: cardColor,
              iconBg: const Color(0xFFFF4D5A),
              icon: Icons.car_crash_rounded,
              title: "Incidente in tangenziale Est a Milano, cod...",
              source: "News Traffico",
              time: "18:20",
            ),
            const SizedBox(height: 12),
            _trafficCard(
              isDark: isDark,
              cardColor: cardColor,
              iconBg: const Color(0xFFFF4D5A),
              icon: Icons.car_crash_rounded,
              title: "Incidente Al adesso: 4 km di coda verso ...",
              source: "News Traffico",
              time: "08:39",
            ),
            const SizedBox(height: 12),
            _trafficCard(
              isDark: isDark,
              cardColor: cardColor,
              iconBg: const Color(0xFFFFC24A),
              icon: Icons.traffic_rounded,
              title: "Tir si ribalta sull’Autosole, oltre 6 chilome...",
              source: "News Traffico",
              time: "08:00",
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _zoomBox(bool isDark) {
    return Container(
      width: 52,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (!isDark)
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 14),
        ],
      ),
      child: Column(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.add_rounded,
                color: isDark ? Colors.white : Colors.black87),
          ),
          Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.remove_rounded,
                color: isDark ? Colors.white : Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _tooltipBubble(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 18)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Veicolo Fermo",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Intervento Richiesto",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
          const SizedBox(width: 14),
          Icon(Icons.close_rounded, size: 18, color: isDark ? Colors.white : Colors.black54),
        ],
      ),
    );
  }

  Widget _trafficCard({
    required bool isDark,
    required Color cardColor,
    required Color iconBg,
    required IconData icon,
    required String title,
    required String source,
    required String time,
  }) {
    return _card(
      isDark: isDark,
      color: cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: iconBg,
            child: Icon(icon, color: Colors.white, size: 26),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  source,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// COMPONENTI UI (stile come tuo file)
// ============================================================================

Widget _card({
  required bool isDark,
  required Color color,
  required Widget child,
  EdgeInsets padding = const EdgeInsets.all(20),
}) {
  return Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        if (!isDark)
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
      ],
    ),
    child: child,
  );
}

Widget _kpi({
  required bool isDark,
  required Color cardColor,
  required Color bubble,
  required Widget bubbleChild,
  required String value,
  required String label,
}) {
  return _card(
    isDark: isDark,
    color: cardColor,
    child: Row(
      children: [
        CircleAvatar(radius: 30, backgroundColor: bubble, child: bubbleChild),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF111827),
                letterSpacing: -1.0,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        )
      ],
    ),
  );
}

enum _StatusKind { pending, accepted, handled }

Widget _statusChip(bool isDark, _StatusKind kind, String text) {
  Color bg;
  Color fg;

  switch (kind) {
    case _StatusKind.pending:
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFE65100);
      break;
    case _StatusKind.accepted:
      bg = const Color(0xFFE8EAF6);
      fg = const Color(0xFF3F51B5);
      break;
    case _StatusKind.handled:
      bg = const Color(0xFFE0F2F1);
      fg = const Color(0xFF00796B);
      break;
  }

  // in dark abbasso un filo l'intensità mantenendo palette uguale al tuo file
  if (isDark) {
    bg = bg.withOpacity(0.20);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text,
      style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 13),
    ),
  );
}

enum _ActionKind { outlinePrimary, filledSuccess, none }

Widget _actionButton({
  required bool isDark,
  required _ActionKind kind,
  required String text,
  required VoidCallback onTap,
}) {
  final primary = const Color(0xFF6A7AF4);
  final success = Colors.green;

  late final Color fg;
  late final Color bg;
  late final BoxBorder? border;

  switch (kind) {
    case _ActionKind.outlinePrimary:
      fg = primary;
      bg = Colors.transparent;
      border = Border.all(color: primary, width: 1.6);
      break;
    case _ActionKind.filledSuccess:
      fg = Colors.white;
      bg = success.withOpacity(isDark ? 0.55 : 0.80);
      border = null;
      break;
    case _ActionKind.none:
      fg = Colors.transparent;
      bg = Colors.transparent;
      border = null;
      break;
  }

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class _QueueRow {
  final String veicolo;
  final String tipo;
  final String statusText;
  final _StatusKind statusKind;
  final String actionText;
  final _ActionKind actionKind;

  const _QueueRow({
    required this.veicolo,
    required this.tipo,
    required this.statusText,
    required this.statusKind,
    required this.actionText,
    required this.actionKind,
  });
}

// ============================================================================
// Pagine originali del tuo file: Richieste + Settings
// (le ho lasciate uguali per coerenza; in Richieste ho solo aggiornato il drawer route)
// ============================================================================

class RichiestePage extends StatefulWidget {
  const RichiestePage({super.key});

  @override
  State<RichiestePage> createState() => _RichiestePageState();
}

class _RichiestePageState extends State<RichiestePage> {
  int _selectedFilterIndex = 0;

  final List<Map<String, dynamic>> _interventi = [
    {"id": "#SOS-2491", "data": "04/03 09:11", "stato": "PENDING"},
    {"id": "#SOS-2492", "data": "04/03 08:56", "stato": "ACCEPTED"},
    {"id": "#SOS-2488", "data": "04/03 07:11", "stato": "HANDLED"},
  ];

  List<Map<String, dynamic>> get _interventiFiltrati {
    switch (_selectedFilterIndex) {
      case 1:
        return _interventi.where((i) => i["stato"] == "PENDING").toList();
      case 2:
        return _interventi.where((i) => i["stato"] == "ACCEPTED").toList();
      case 3:
        return _interventi.where((i) => i["stato"] == "HANDLED").toList();
      case 0:
      default:
        return _interventi;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        actions: [
          buildSharedThemeToggle(context, isDark),
          const SizedBox(width: 16),
        ],
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const AppDrawer(currentRoute: Routes.richieste),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gestione Richieste",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Storico e gestione operativa degli interventi in entrata.",
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey),
            ),
            const SizedBox(height: 24),

            Builder(builder: (context) {
              final isMobile = MediaQuery.of(context).size.width < 600;

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
                  ],
                ),
                width: double.infinity,
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildFilterTab(0, "Tutte", Icons.list, isMobile),
                          const SizedBox(height: 8),
                          _buildFilterTab(1, "Da Gestire", Icons.warning_amber_rounded, isMobile),
                          const SizedBox(height: 8),
                          _buildFilterTab(2, "In Corso", Icons.directions_car_filled_outlined, isMobile),
                          const SizedBox(height: 8),
                          _buildFilterTab(3, "Completate", Icons.check_circle_outline, isMobile),
                        ],
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterTab(0, "Tutte", Icons.list, isMobile),
                            _buildFilterTab(1, "Da Gestire", Icons.warning_amber_rounded, isMobile),
                            _buildFilterTab(2, "In Corso", Icons.directions_car_filled_outlined, isMobile),
                            _buildFilterTab(3, "Completate", Icons.check_circle_outline, isMobile),
                          ],
                        ),
                      ),
              );
            }),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
                ],
              ),
              child: Center(
                child: _interventiFiltrati.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text(
                          "Nessuna richiesta trovata per questo stato.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : DataTable(
                        headingTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        dataRowMaxHeight: 70,
                        dataRowMinHeight: 70,
                        horizontalMargin: 24,
                        dividerThickness: 0.5,
                        columnSpacing: 40,
                        columns: const [
                          DataColumn(label: Text("ID Intervento")),
                          DataColumn(label: Text("Data/Ora")),
                          DataColumn(label: Text("Azioni")),
                        ],
                        rows: _interventiFiltrati.map((intervento) {
                          return DataRow(cells: [
                            DataCell(_buildColoredId(intervento["id"], intervento["stato"], isDark)),
                            DataCell(Text(
                              intervento["data"],
                              style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
                            )),
                            DataCell(_buildActionButtons(intervento["stato"])),
                          ]);
                        }).toList(),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(int index, String label, IconData icon, bool isMobile) {
    bool isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        margin: isMobile ? EdgeInsets.zero : const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6A7AF4) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : Colors.blueGrey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColoredId(String id, String status, bool isDark) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case "PENDING":
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        break;
      case "ACCEPTED":
        bgColor = const Color(0xFFE8EAF6);
        textColor = const Color(0xFF3F51B5);
        break;
      case "HANDLED":
        bgColor = const Color(0xFFE0F2F1);
        textColor = const Color(0xFF00796B);
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    if (isDark) bgColor = bgColor.withOpacity(0.22);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        id,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == "PENDING") ...[
          _iconButton(Icons.check, Colors.green, const Color(0xFFE8F5E9)),
          const SizedBox(width: 8),
        ],
        _iconButton(Icons.close, Colors.redAccent, const Color(0xFFFFEBEE)),
      ],
    );
  }

  Widget _iconButton(IconData icon, Color color, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool emailEnabled = true;
  bool autoAccept = false;

  String nomeProfilo = "Officina Centrale";
  String contattiProfilo = "officina@example.com - 02 1234567";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Impostazioni",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        actions: [
          buildSharedThemeToggle(context, isDark),
          const SizedBox(width: 16),
        ],
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const AppDrawer(currentRoute: Routes.impostazioni),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileCard(isDark),
            const SizedBox(height: 24),
            _buildSwitchCard(
              isDark: isDark,
              title: "Notifiche",
              subtitle: "Gestisci notifiche push e avvisi critici.",
              value: notificationsEnabled,
              onChanged: (v) => setState(() => notificationsEnabled = v),
            ),
            const SizedBox(height: 16),
            _buildSwitchCard(
              isDark: isDark,
              title: "Email",
              subtitle: "Ricevi riepiloghi e alert via email.",
              value: emailEnabled,
              onChanged: (v) => setState(() => emailEnabled = v),
            ),
            const SizedBox(height: 16),
            _buildSwitchCard(
              isDark: isDark,
              title: "Auto-accettazione",
              subtitle: "Accetta automaticamente richieste in arrivo.",
              value: autoAccept,
              onChanged: (v) => setState(() => autoAccept = v),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
          ),
          const SizedBox(height: 16),
          Text(nomeProfilo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(contattiProfilo, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey, fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit, size: 18),
            label: const Text("Modifica Profilo"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey)),
            ]),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ============================================================================
// Placeholder per le voci menu che non hai ancora implementato
// ============================================================================

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const AppDrawer(currentRoute: Routes.dashboard),
      ),
      body: Center(
        child: Text(
          "$title (TODO)",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
      ),
    );
  }
}