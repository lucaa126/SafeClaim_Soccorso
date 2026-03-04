import 'package:flutter/material.dart';

void main() {
  runApp(const SoccorsoApp());
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
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
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
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      themeMode: _themeMode,
      home: const RichiestePage(),
    );
  }
}

// ============================================================================
// WIDGET CONDIVISI: MENU E TOGGLE TEMA
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
                  const Text("SOCCORSO",
                      style: TextStyle(
                          color: Color(0xFFE57373),
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
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
            _fullScreenSidebarItem(context, Icons.grid_view_rounded, "Dashboard", isDark, '/dashboard'),
            _fullScreenSidebarItem(context, Icons.campaign_outlined, "Richieste", isDark, '/richieste'),
            _fullScreenSidebarItem(context, Icons.local_shipping_outlined, "Flotta", isDark, '/flotta'),
            _fullScreenSidebarItem(context, Icons.analytics_outlined, "Analytics", isDark, '/analytics'),
            _fullScreenSidebarItem(context, Icons.settings, "Impostazioni", isDark, '/impostazioni'),
            const Spacer(),
            const Divider(),
            _fullScreenSidebarItem(context, Icons.logout, "Logout", isDark, '/logout'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _fullScreenSidebarItem(BuildContext context, IconData icon, String label, bool isDark, String route) {
    bool isSelected = currentRoute == route;

    return InkWell(
      onTap: () {
        Navigator.pop(context); // Chiude il drawer
        if (!isSelected) {
          if (route == '/richieste') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RichiestePage()));
          } else if (route == '/impostazioni') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
          }
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
              child: Icon(icon, color: isSelected ? Colors.blue : Colors.grey, size: 28),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                color: isSelected ? Colors.blue : (isDark ? Colors.white70 : Colors.black87),
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
// PAGINA: GESTIONE RICHIESTE
// ============================================================================

class RichiestePage extends StatefulWidget {
  const RichiestePage({super.key});

  @override
  State<RichiestePage> createState() => _RichiestePageState();
}

class _RichiestePageState extends State<RichiestePage> {
  int _selectedFilterIndex = 0;

  final List<Map<String, dynamic>> _interventi = [
    {
      "id": "#SOS-2491",
      "data": "04/03 09:11",
      "stato": "PENDING"
    },
    {
      "id": "#SOS-2492",
      "data": "04/03 08:56",
      "stato": "ACCEPTED"
    },
    {
      "id": "#SOS-2488",
      "data": "04/03 07:11",
      "stato": "HANDLED"
    },
  ];

  // LOGICA FILTRI
  List<Map<String, dynamic>> get _interventiFiltrati {
    switch (_selectedFilterIndex) {
      case 1: // Da Gestire
        return _interventi.where((i) => i["stato"] == "PENDING").toList();
      case 2: // In Corso
        return _interventi.where((i) => i["stato"] == "ACCEPTED").toList();
      case 3: // Completate
        return _interventi.where((i) => i["stato"] == "HANDLED").toList();
      case 0: // Tutte
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
        child: const AppDrawer(currentRoute: '/richieste'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Gestione Richieste",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF374151)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Storico e gestione operativa degli interventi in entrata.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Barra filtri responsive
            Builder(
              builder: (context) {
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
              }
            ),
            const SizedBox(height: 24),

            // Tabella Dati (Fissa e Centrata, senza slider)
            Container(
              width: double.infinity, // Occupa tutta la larghezza disponibile
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
              ),
              child: Center(
                child: _interventiFiltrati.isEmpty 
                  ? const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("Nessuna richiesta trovata per questo stato.", style: TextStyle(color: Colors.grey)),
                    )
                  : DataTable(
                      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
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
                      // USIAMO LA LISTA FILTRATA
                      rows: _interventiFiltrati.map((intervento) {
                        return DataRow(cells: [
                          DataCell(_buildColoredId(intervento["id"], intervento["stato"])),
                          DataCell(Text(intervento["data"], style: const TextStyle(color: Colors.grey))),
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

  // Funzione per colorare l'ID in base allo stato
  Widget _buildColoredId(String id, String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case "PENDING":
        bgColor = const Color(0xFFFFF3E0); // Light Orange
        textColor = const Color(0xFFE65100); // Dark Orange
        break;
      case "ACCEPTED":
        bgColor = const Color(0xFFE8EAF6); // Light Indigo
        textColor = const Color(0xFF3F51B5); // Indigo
        break;
      case "HANDLED":
        bgColor = const Color(0xFFE0F2F1); // Light Green
        textColor = const Color(0xFF00796B); // Teal
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

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
          onTap: () {
            // Qui andrà la logica per accettare o rifiutare
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PAGINA ESISTENTE: IMPOSTAZIONI 
// ============================================================================

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
        title: const Text("Impostazioni", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        actions: [
          buildSharedThemeToggle(context, isDark),
          const SizedBox(width: 16),
        ],
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const AppDrawer(currentRoute: '/impostazioni'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileCard(isDark),
            const SizedBox(height: 24),
            _buildInfoOfficinaCard(isDark),
            const SizedBox(height: 24),
            _buildNotificheCard(isDark),
            const SizedBox(height: 24),
            _buildParametriOperativiCard(isDark),
            const SizedBox(height: 32),
            _buildActionButtons(),
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
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          const CircleAvatar(radius: 45, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
          const SizedBox(height: 16),
          Text(nomeProfilo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(contattiProfilo, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit, size: 18),
            label: const Text("Modifica Profilo"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCardContainer({required String title, required IconData icon, required List<Widget> children, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: Colors.blue, size: 22),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ],
      ),
    );
  }

  Widget _buildInfoOfficinaCard(bool isDark) => _buildCardContainer(
        title: "Informazioni Officina",
        icon: Icons.storefront,
        isDark: isDark,
        children: [
          _customTextField("Email di contatto", "officina@example.com", isDark),
          const SizedBox(height: 16),
          _customTextField("Telefono", "+39 02 1234567", isDark),
          const SizedBox(height: 16),
          _customTextField("Indirizzo", "Via Roma 123, Milano", isDark),
        ],
      );

  Widget _buildNotificheCard(bool isDark) => _buildCardContainer(
        title: "Notifiche",
        icon: Icons.notifications_active_outlined,
        isDark: isDark,
        children: [
          _enhancedSwitchRow(
            title: "Abilita Notifiche", subtitle: "Ricevi avvisi per nuove richieste",
            icon: Icons.notifications_none, value: notificationsEnabled,
            isDark: isDark, onChanged: (v) => setState(() => notificationsEnabled = v),
          ),
          _enhancedSwitchRow(
            title: "Avvisi via Email", subtitle: "Ricevi riepiloghi e avvisi via mail",
            icon: Icons.email_outlined, value: emailEnabled,
            isDark: isDark, onChanged: (v) => setState(() => emailEnabled = v),
          ),
        ],
      );

  Widget _buildParametriOperativiCard(bool isDark) => _buildCardContainer(
        title: "Parametri Operativi",
        icon: Icons.settings_applications_outlined,
        isDark: isDark,
        children: [
          Row(
            children: [
              Expanded(child: _customTextField("Orario Inizio", "08:00", isDark)),
              const SizedBox(width: 16),
              Expanded(child: _customTextField("Orario Fine", "20:00", isDark)),
            ],
          ),
          const SizedBox(height: 16),
          _customTextField("Richieste Massime in Coda", "10", isDark),
          const SizedBox(height: 24),
          _enhancedSwitchRow(
            title: "Accettazione Automatica", subtitle: "Accetta i soccorsi in automatico",
            icon: Icons.autorenew, value: autoAccept,
            isDark: isDark, onChanged: (v) => setState(() => autoAccept = v),
          ),
        ],
      );

  Widget _customTextField(String label, String hint, bool isDark, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark ? const Color(0xFF282828) : const Color(0xFFF9FAFB),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _enhancedSwitchRow({
    required String title, required String subtitle, required IconData icon,
    required bool value, required bool isDark, required Function(bool) onChanged
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text("Salva tutte le impostazioni", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}