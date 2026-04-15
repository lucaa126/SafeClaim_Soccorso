import 'package:flutter/material.dart';
import 'dart:convert';

import '../../app/routes.dart';
import '../../widgets/app_drawer.dart';
// Assumo che tu abbia i tuoi import custom:
// import '../dashboard/dashboard_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Stati di caricamento
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isResetting = false;

  // Stati degli switch
  bool notificationsEnabled = false;
  bool emailEnabled = false;
  bool smsEnabled = false;
  bool autoAccept = false;

  // Controller per i campi di testo
  final _nomeController = TextEditingController();
  final _contattiController = TextEditingController(); // Email/Tel profilo

  final _emailOfficinaController = TextEditingController();
  final _telefonoOfficinaController = TextEditingController();
  final _indirizzoController = TextEditingController();

  final _orarioInizioController = TextEditingController();
  final _orarioFineController = TextEditingController();
  final _maxCodaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _caricaDatiIniziali();
  }

  @override
  void dispose() {
    // Importante liberare la memoria dei controller
    _nomeController.dispose();
    _contattiController.dispose();
    _emailOfficinaController.dispose();
    _telefonoOfficinaController.dispose();
    _indirizzoController.dispose();
    _orarioInizioController.dispose();
    _orarioFineController.dispose();
    _maxCodaController.dispose();
    super.dispose();
  }

  // --- LOGICA API ---

  Future<void> _caricaDatiIniziali() async {
    setState(() => _isLoading = true);

    try {
      // Chiamata API GET fittizia
      final responseData = await ImpostazioniApi.getImpostazioni();

      setState(() {
        // Popola i controller
        _nomeController.text = responseData['profilo']['nome'];
        _contattiController.text = responseData['profilo']['contatti'];

        _emailOfficinaController.text = responseData['officina']['email'];
        _telefonoOfficinaController.text = responseData['officina']['telefono'];
        _indirizzoController.text = responseData['officina']['indirizzo'];

        _orarioInizioController.text =
            responseData['parametri']['orario_inizio'];
        _orarioFineController.text = responseData['parametri']['orario_fine'];
        _maxCodaController.text = responseData['parametri']['max_coda']
            .toString();

        // Popola i boolean
        notificationsEnabled = responseData['notifiche']['push'];
        emailEnabled = responseData['notifiche']['email'];
        smsEnabled = responseData['notifiche']['sms'];
        autoAccept = responseData['parametri']['accettazione_automatica'];
      });
    } catch (e) {
      _mostraMessaggio('Errore nel caricamento dei dati', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvaTutto() async {
    setState(() => _isSaving = true);

    try {
      // Costruisci il JSON da inviare al backend
      final payload = {
        "profilo": {
          "nome": _nomeController.text,
          "contatti": _contattiController.text,
        },
        "officina": {
          "email": _emailOfficinaController.text,
          "telefono": _telefonoOfficinaController.text,
          "indirizzo": _indirizzoController.text,
        },
        "notifiche": {
          "push": notificationsEnabled,
          "email": emailEnabled,
          "sms": smsEnabled,
        },
        "parametri": {
          "orario_inizio": _orarioInizioController.text,
          "orario_fine": _orarioFineController.text,
          "max_coda": int.tryParse(_maxCodaController.text) ?? 10,
          "accettazione_automatica": autoAccept,
        },
      };

      // Chiamata API PUT/PATCH fittizia
      await ImpostazioniApi.salvaImpostazioni(payload);

      _mostraMessaggio('Impostazioni salvate con successo!');
    } catch (e) {
      _mostraMessaggio('Errore durante il salvataggio', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _ripristinaFabbrica() async {
    // Richiedi conferma prima di fare il reset
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attenzione'),
        content: const Text(
          'Vuoi davvero ripristinare i valori di fabbrica? Perderai le modifiche attuali.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Ripristina',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (conferma != true) return;

    setState(() => _isResetting = true);

    try {
      // Chiamata API POST di reset
      await ImpostazioniApi.resetFabbrica();
      _mostraMessaggio('Ripristino effettuato');
      // Ricarica i dati (che ora saranno quelli di default dal server)
      await _caricaDatiIniziali();
    } catch (e) {
      _mostraMessaggio('Errore durante il ripristino', isError: true);
    } finally {
      setState(() => _isResetting = false);
    }
  }

  void _mostraMessaggio(String testo, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(testo),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: const Text(
          'Impostazioni',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          // buildSharedThemeToggle(context, isDark),
          const SizedBox(width: 16),
        ],
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const AppDrawer(currentRoute: Routes.impostazioni),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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

  // --- WIDGETS ---

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
            _nomeController.text, // Modificato per leggere dal controller
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            _contattiController.text, // Modificato per leggere dal controller
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _mostraModaleModificaProfilo(isDark),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Modifica Profilo rapida'),
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
    // Utilizziamo dei controller temporanei per non sporcare la UI
    // principale finchè l'utente non preme "Salva Modifiche"
    final tempNomeController = TextEditingController(
      text: _nomeController.text,
    );
    final tempContattiController = TextEditingController(
      text: _contattiController.text,
    );

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
                'Inserisci il nome',
                isDark,
                controller: tempNomeController,
              ),
              const SizedBox(height: 16),
              _customTextField(
                'Contatti (Email/Telefono)',
                'Inserisci i contatti',
                isDark,
                controller: tempContattiController,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Aggiorniamo i controller principali e rifacciamo la build
                  // della schermata principale (in modo da mostrare il nome aggiornato)
                  setState(() {
                    _nomeController.text = tempNomeController.text;
                    _contattiController.text = tempContattiController.text;
                  });
                  Navigator.pop(context);
                  _mostraMessaggio(
                    "Ricordati di premere 'Salva tutte le impostazioni' in fondo!",
                  );
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
                  'Conferma Modifiche',
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
              color: Colors.black.withOpacity(0.04),
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
                  color: Colors.blue.withOpacity(0.1),
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

  Widget _buildInfoOfficinaCard(bool isDark) => _buildCardContainer(
    title: 'Informazioni Officina',
    icon: Icons.storefront,
    isDark: isDark,
    children: [
      _customTextField(
        'Email di contatto',
        'es: officina@mail.com',
        isDark,
        controller: _emailOfficinaController,
      ),
      const SizedBox(height: 16),
      _customTextField(
        'Telefono',
        'es: +39 02...',
        isDark,
        controller: _telefonoOfficinaController,
      ),
      const SizedBox(height: 16),
      _customTextField(
        'Indirizzo',
        'es: Via Roma...',
        isDark,
        controller: _indirizzoController,
      ),
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
          Expanded(
            child: _customTextField(
              'Orario Inizio',
              '08:00',
              isDark,
              controller: _orarioInizioController,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _customTextField(
              'Orario Fine',
              '20:00',
              isDark,
              controller: _orarioFineController,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _customTextField(
        'Richieste Massime in Coda',
        'es. 10',
        isDark,
        controller: _maxCodaController,
        isNumber: true,
      ),
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

  Widget _customTextField(
    String label,
    String hint,
    bool isDark, {
    TextEditingController? controller,
    bool isNumber = false,
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
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
              color: Colors.blue.withOpacity(0.1),
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
          onPressed: _isSaving
              ? null
              : _salvaTutto, // Disabilita se sta salvando
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Salva tutte le impostazioni',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isResetting ? null : _ripristinaFabbrica,
          icon: _isResetting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.redAccent,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.refresh, size: 18),
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

// =====================================================================
// CLASSE FITTIZIA PER SIMULARE LE CHIAMATE API
// (Da sostituire con le tue reali chiamate HTTP/Dio)
// =====================================================================
class ImpostazioniApi {
  // GET: /api/v1/officina/impostazioni
  static Future<Map<String, dynamic>> getImpostazioni() async {
    await Future.delayed(const Duration(seconds: 1)); // Simula latenza rete

    // Ritorna un JSON fittizio dal server
    return {
      "profilo": {
        "nome": "Officina Centrale Milano",
        "contatti": "info@officinamilano.it - 02 1234567",
      },
      "officina": {
        "email": "info@officinamilano.it",
        "telefono": "+39 02 1234567",
        "indirizzo": "Via Roma 123, Milano",
      },
      "notifiche": {"push": true, "email": true, "sms": false},
      "parametri": {
        "orario_inizio": "08:30",
        "orario_fine": "19:00",
        "max_coda": 15,
        "accettazione_automatica": false,
      },
    };
  }

  // PUT/PATCH: /api/v1/officina/impostazioni
  static Future<void> salvaImpostazioni(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(seconds: 2)); // Simula upload
    // Log di controllo: print("Dati inviati al server: ${jsonEncode(payload)}");
    return;
  }

  // POST: /api/v1/officina/impostazioni/reset
  static Future<void> resetFabbrica() async {
    await Future.delayed(const Duration(seconds: 1)); // Simula ripristino
    return;
  }
}
