import 'package:flutter/material.dart';

void main() {
  runApp(const SoccorsoApp());
}

class SoccorsoApp extends StatefulWidget {
  const SoccorsoApp({super.key});

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
        colorSchemeSeed: Colors.indigo,
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
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      themeMode: _themeMode,
      home: SettingsPage(onThemeChanged: toggleTheme, currentTheme: _themeMode),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final ThemeMode currentTheme;

  const SettingsPage({
    super.key, 
    required this.onThemeChanged, 
    required this.currentTheme
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool emailEnabled = true;
  bool smsEnabled = false;
  bool autoAccept = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // AppBar con icona menu automatica grazie all'inserimento del Drawer
      appBar: AppBar(
        title: const Text(
          "Impostazioni",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          _buildThemeToggle(isDark),
          const SizedBox(width: 16),
        ],
      ),
      // Il Drawer funge da menu di navigazione apri/chiudi
      drawer: _buildDrawer(isDark),
      // Contenuto principale impilato in singola colonna per il mobile
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
            const SizedBox(height: 24),
            _buildQuickInfoCard(isDark),
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET MENU DI NAVIGAZIONE (DRAWER) ---

  Widget _buildDrawer(bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text("SOCCORSO", style: TextStyle(color: Color(0xFFE57373), fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            _sidebarItem(Icons.grid_view_rounded, "Dashboard", isDark),
            _sidebarItem(Icons.campaign_outlined, "Richieste", isDark),
            _sidebarItem(Icons.local_shipping_outlined, "Flotta", isDark),
            _sidebarItem(Icons.analytics_outlined, "Analytics", isDark),
            _sidebarItem(Icons.settings, "Impostazioni", isDark, isSelected: true),
            const Spacer(),
            const Divider(),
            _sidebarItem(Icons.logout, "Logout", isDark),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, bool isDark, {bool isSelected = false}) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.indigo : Colors.grey),
      title: Text(label, style: TextStyle(color: isSelected ? Colors.indigo : (isDark ? Colors.white70 : Colors.black87), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      tileColor: isSelected ? Colors.indigo.withOpacity(0.1) : Colors.transparent,
      onTap: () {},
    );
  }

  // --- TOGGLE TEMA ---
  Widget _buildThemeToggle(bool isDark) {
    return ToggleButtons(
      isSelected: [!isDark, isDark],
      onPressed: (index) => widget.onThemeChanged(index == 1),
      borderRadius: BorderRadius.circular(8),
      constraints: const BoxConstraints(minHeight: 32, minWidth: 36),
      selectedColor: Colors.white,
      fillColor: Colors.indigo,
      children: const [
        Icon(Icons.wb_sunny_outlined, size: 18),
        Icon(Icons.nightlight_round, size: 18)
      ],
    );
  }

  // --- CONTAINER DELLE CARD ---

  Widget _buildCardContainer({required String title, required IconData icon, required List<Widget> children, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE8EAF6).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.indigo),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ],
      ),
    );
  }

  // --- LE SCHEDE (CARDS) ---

  Widget _buildProfileCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [if(!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const CircleAvatar(radius: 40, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
          const SizedBox(height: 12),
          const Text("Officina Centrale", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("Amministratore", style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2979FF),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Modifica Profilo"),
          )
        ],
      ),
    );
  }

  Widget _buildInfoOfficinaCard(bool isDark) => _buildCardContainer(
    title: "Informazioni Officina",
    icon: Icons.info_outline,
    isDark: isDark,
    children: [
      // I campi sono ora impilati verticalmente per adattarsi allo schermo del telefono
      _customTextField("Nome Officina", "Officina Centrale", isDark),
      const SizedBox(height: 16),
      _customTextField("Email", "officina@example.com", isDark),
      const SizedBox(height: 16),
      _customTextField("Telefono", "+39 02 1234567", isDark),
      const SizedBox(height: 16),
      _customTextField("Indirizzo", "Via Roma 123, Milano", isDark),
    ],
  );

  Widget _buildNotificheCard(bool isDark) => _buildCardContainer(
    title: "Notifiche",
    icon: Icons.notifications_none,
    isDark: isDark,
    children: [
      _switchRow("Abilita Notifiche", "Attiva/disattiva tutte le notifiche", notificationsEnabled, (v) => setState(() => notificationsEnabled = v)),
      const Divider(),
      _switchRow("Email", "Ricevi notifiche via email", emailEnabled, (v) => setState(() => emailEnabled = v)),
      const Divider(),
      _switchRow("SMS", "Ricevi notifiche via SMS", smsEnabled, (v) => setState(() => smsEnabled = v)),
    ],
  );

  Widget _buildParametriOperativiCard(bool isDark) => _buildCardContainer(
    title: "Parametri Operativi",
    icon: Icons.access_time,
    isDark: isDark,
    children: [
      _customTextField("Orario di Lavoro", "08:00-20:00", isDark),
      const SizedBox(height: 16),
      _customTextField("Richieste Massime Contemporanee", "10", isDark),
      const SizedBox(height: 16),
      _switchRow("Accettazione Automatica", "Accetta in automatico le richieste", autoAccept, (v) => setState(() => autoAccept = v)),
    ],
  );

  Widget _buildQuickInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Informazioni Rapide", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _quickInfoRow(Icons.email_outlined, "Email", "officina@example.com"),
          const Divider(height: 24),
          _quickInfoRow(Icons.phone_outlined, "Telefono", "+39 02 1234567"),
          const Divider(height: 24),
          _quickInfoRow(Icons.location_on_outlined, "Indirizzo", "Via Roma 123, Milano"),
        ],
      ),
    );
  }

  // --- HELPERS E BOTTONI ---

  Widget _customTextField(String label, String hint, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _switchRow(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeColor: Colors.indigo),
      ],
    );
  }

  Widget _quickInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(value, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildActionButtons() {
    // Sul telefono, i bottoni occupano tutta la larghezza e sono impilati
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.save, size: 18),
          label: const Text("Salva Impostazioni"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2979FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text("Reimposta"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Colors.redAccent),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}