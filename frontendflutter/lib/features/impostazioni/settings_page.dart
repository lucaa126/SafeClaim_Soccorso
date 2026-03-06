import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../widgets/app_drawer.dart';
import '../dashboard/dashboard_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Stati degli switch
  bool notificationsEnabled = true;
  bool emailEnabled = true;
  bool smsEnabled = false;
  bool autoAccept = false;

  // Dati Profilo modificabili
  String nomeProfilo = 'Officina Centrale';
  String contattiProfilo = 'officina@example.com - 02 1234567';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Impostazioni',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
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

  // --- PROFILO E MODALE DI MODIFICA ---
  Widget _buildProfileCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
          ),
          const SizedBox(height: 16),
          Text(
            nomeProfilo,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            contattiProfilo,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _mostraModaleModificaProfilo(isDark),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Modifica Profilo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _mostraModaleModificaProfilo(bool isDark) {
    final nomeController = TextEditingController(text: nomeProfilo);
    final contattiController = TextEditingController(text: contattiProfilo);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Modifica i tuoi dati',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _customTextField(
                'Nome Completo / Officina',
                '',
                isDark,
                controller: nomeController,
              ),
              const SizedBox(height: 16),
              _customTextField(
                'Contatti (Email/Telefono)',
                '',
                isDark,
                controller: contattiController,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    nomeProfilo = nomeController.text;
                    contattiProfilo = contattiController.text;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Salva Modifiche',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // --- CONTAINER DELLE CARD ---
  Widget _buildCardContainer({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.blue, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ],
      ),
    );
  }

  // --- CARDS PRINCIPALI ---
  Widget _buildInfoOfficinaCard(bool isDark) => _buildCardContainer(
    title: 'Informazioni Officina',
    icon: Icons.storefront,
    isDark: isDark,
    children: [
      _customTextField('Email di contatto', 'officina@example.com', isDark),
      const SizedBox(height: 16),
      _customTextField('Telefono', '+39 02 1234567', isDark),
      const SizedBox(height: 16),
      _customTextField('Indirizzo', 'Via Roma 123, Milano', isDark),
    ],
  );

  Widget _buildNotificheCard(bool isDark) => _buildCardContainer(
    title: 'Notifiche',
    icon: Icons.notifications_active_outlined,
    isDark: isDark,
    children: [
      _enhancedSwitchRow(
        title: 'Abilita Notifiche',
        subtitle: 'Ricevi avvisi per nuove richieste',
        icon: Icons.notifications_none,
        value: notificationsEnabled,
        isDark: isDark,
        onChanged: (v) => setState(() => notificationsEnabled = v),
      ),
      _enhancedSwitchRow(
        title: 'Avvisi via Email',
        subtitle: 'Ricevi riepiloghi e avvisi via mail',
        icon: Icons.email_outlined,
        value: emailEnabled,
        isDark: isDark,
        onChanged: (v) => setState(() => emailEnabled = v),
      ),
      _enhancedSwitchRow(
        title: 'Avvisi via SMS',
        subtitle: 'Solo per emergenze',
        icon: Icons.sms_outlined,
        value: smsEnabled,
        isDark: isDark,
        onChanged: (v) => setState(() => smsEnabled = v),
      ),
    ],
  );

  Widget _buildParametriOperativiCard(bool isDark) => _buildCardContainer(
    title: 'Parametri Operativi',
    icon: Icons.settings_applications_outlined,
    isDark: isDark,
    children: [
      Row(
        children: [
          Expanded(child: _customTextField('Orario Inizio', '08:00', isDark)),
          const SizedBox(width: 16),
          Expanded(child: _customTextField('Orario Fine', '20:00', isDark)),
        ],
      ),
      const SizedBox(height: 16),
      _customTextField('Richieste Massime in Coda', '10', isDark),
      const SizedBox(height: 24),
      _enhancedSwitchRow(
        title: 'Accettazione Automatica',
        subtitle: 'Accetta i soccorsi in automatico',
        icon: Icons.autorenew,
        value: autoAccept,
        isDark: isDark,
        onChanged: (v) => setState(() => autoAccept = v),
      ),
    ],
  );

  // --- WIDGETS GRAFICI ---
  Widget _customTextField(
    String label,
    String hint,
    bool isDark, {
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark
                ? const Color(0xFF282828)
                : const Color(0xFFF9FAFB),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _enhancedSwitchRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.blue,
            inactiveThumbColor: isDark ? Colors.grey[400] : Colors.grey[600],
            inactiveTrackColor: isDark ? Colors.grey[800] : Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Text(
            'Salva tutte le impostazioni',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text(
            'Reimposta ai valori di fabbrica',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Colors.redAccent),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
