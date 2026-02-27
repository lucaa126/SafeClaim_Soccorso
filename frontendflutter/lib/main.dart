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
  // Stati degli switch
  bool notificationsEnabled = true;
  bool emailEnabled = true;
  bool smsEnabled = false;
  bool autoAccept = false;

  // Dati Profilo
  String nomeProfilo = "Officina Centrale";
  String ruoloProfilo = "Amministratore";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
      drawer: _buildDrawer(isDark),
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
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [if(!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: Colors.indigo, size: 22),
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

  // --- PROFILO E MODALE DI MODIFICA ---
  Widget _buildProfileCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [if(!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          const CircleAvatar(radius: 45, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
          const SizedBox(height: 16),
          Text(nomeProfilo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(ruoloProfilo, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _mostraModaleModificaProfilo(isDark),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text("Modifica Profilo"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2979FF),
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

  void _mostraModaleModificaProfilo(bool isDark) {
    // Controller temporanei per i campi del form
    TextEditingController nomeController = TextEditingController(text: nomeProfilo);
    TextEditingController ruoloController = TextEditingController(text: ruoloProfilo);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permette al modale di salire se si apre la tastiera
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Gestisce l'altezza della tastiera
            left: 24, right: 24, top: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Modifica i tuoi dati", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _customTextField("Nome Completo / Officina", "", isDark, controller: nomeController),
              const SizedBox(height: 16),
              _customTextField("Ruolo", "", isDark, controller: ruoloController),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    nomeProfilo = nomeController.text;
                    ruoloProfilo = ruoloController.text;
                  });
                  Navigator.pop(context); // Chiude il modale
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Salva Modifiche", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // --- CARDS PRINCIPALI ---
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
      _enhancedSwitchRow(
        title: "Avvisi via SMS", subtitle: "Solo per emergenze",
        icon: Icons.sms_outlined, value: smsEnabled,
        isDark: isDark, onChanged: (v) => setState(() => smsEnabled = v),
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

  Widget _buildQuickInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [if(!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Assistenza", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          _quickInfoRow(Icons.headset_mic_outlined, "Supporto Tecnico", "supporto@soccorso.it"),
          const Divider(height: 24),
          _quickInfoRow(Icons.description_outlined, "Termini e Condizioni", "Leggi il documento"),
        ],
      ),
    );
  }

  // --- WIDGETS GRAFICI MIGLIORATI ---
  
  // Campo di testo migliorato
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
            fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  // Switch Interattivo ridisegnato (Stile "Tile" moderna)
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
            decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.indigo, size: 20),
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
          Switch.adaptive( // Adaptive usa lo stile di iOS su iPhone e Material su Android
            value: value, 
            onChanged: onChanged, 
            activeColor: Colors.white,
            activeTrackColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _quickInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(value, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          child: const Text("Salva tutte le impostazioni", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}