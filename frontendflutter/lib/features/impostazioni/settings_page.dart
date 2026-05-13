import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/safeclaim_ui.dart';
import 'settings_api_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, SettingsApiService? settingsApi})
    : _settingsApi = settingsApi;

  final SettingsApiService? _settingsApi;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsApiService _settingsApi =
      widget._settingsApi ?? SettingsApiService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _avatarController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _maxQueueController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  bool _operativoOnline = false;
  bool _accettazioneAutomatica = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _maxQueueController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final settings = await _settingsApi.getSettings();
      if (!mounted) return;

      setState(() {
        _applySettings(settings);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _applySettings(WorkshopSettings.empty());
        _isLoading = false;
        _errorMessage =
            'Impostazioni non disponibili dal backend. '
            '${_normalizeError(error)}';
      });
    }
  }

  void _applySettings(WorkshopSettings settings) {
    _nameController.text = settings.serviceName;
    _emailController.text = settings.email;
    _phoneController.text = settings.phone;
    _avatarController.text = settings.avatarUrl;
    _startTimeController.text = settings.orarioInizio;
    _endTimeController.text = settings.orarioFine;
    _maxQueueController.text = settings.maxCoda.toString();
    _operativoOnline = settings.operativoOnline;
    _accettazioneAutomatica = settings.accettazioneAutomatica;
  }

  Future<void> _saveSettings() async {
    FocusScope.of(context).unfocus();

    final maxQueue = int.tryParse(_maxQueueController.text.trim());
    if (maxQueue == null || maxQueue < 0) {
      _showError('Numero massimo richieste in coda non valido.');
      return;
    }

    final startTime = _startTimeController.text.trim();
    final endTime = _endTimeController.text.trim();
    if (!_isValidOptionalTime(startTime) || !_isValidOptionalTime(endTime)) {
      _showError('Gli orari devono essere nel formato HH:MM.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _settingsApi.updateProfile(
        serviceName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarUrl: _avatarController.text.trim(),
      );

      await _settingsApi.updateOperationalParameters(
        operativoOnline: _operativoOnline,
        orarioInizio: startTime,
        orarioFine: endTime,
        maxCoda: maxQueue,
        accettazioneAutomatica: _accettazioneAutomatica,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impostazioni salvate con successo!'),
          backgroundColor: SafeClaimColors.primary,
        ),
      );

      await _loadSettings();
    } catch (error) {
      if (!mounted) return;
      _showError(_normalizeError(error));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  bool _isValidOptionalTime(String value) {
    if (value.isEmpty) return true;
    final match = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(value);
    return match;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Errore: $message'),
        backgroundColor: SafeClaimColors.danger,
      ),
    );
  }

  String _normalizeError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    final normalized = message.toLowerCase();

    if (normalized.contains('authentication failed') ||
        normalized.contains('mongodb') ||
        normalized.contains('database')) {
      return 'Configurazione database non disponibile. Contatta il supporto tecnico.';
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = safeClaimCardColor(isDark);

    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const AppDrawer(currentRoute: Routes.impostazioni),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSettings,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                children: [
                  Text(
                    'Impostazioni Soccorso',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : SafeClaimColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Profilo e parametri operativi del servizio.',
                    style: TextStyle(
                      fontSize: 14,
                      color: safeClaimSubtleTextColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) _buildErrorBanner(),
                  _settingsCard(
                    isDark: isDark,
                    cardColor: cardColor,
                    title: 'Profilo',
                    icon: Icons.support_agent_rounded,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome servizio soccorso',
                          prefixIcon: Icon(Icons.business_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email contatto',
                          prefixIcon: Icon(Icons.email_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Telefono contatto',
                          prefixIcon: Icon(Icons.phone_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _avatarController,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          labelText: 'Avatar URL',
                          prefixIcon: Icon(Icons.image_rounded),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _settingsCard(
                    isDark: isDark,
                    cardColor: cardColor,
                    title: 'Parametri Operativi',
                    icon: Icons.tune_rounded,
                    children: [
                      _switchTile(
                        title: 'Stato operativo online',
                        subtitle: 'Disponibilita del servizio soccorso',
                        value: _operativoOnline,
                        onChanged: (value) =>
                            setState(() => _operativoOnline = value),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _startTimeController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          labelText: 'Orario inizio servizio',
                          hintText: '08:00',
                          prefixIcon: Icon(Icons.schedule_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _endTimeController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          labelText: 'Orario fine servizio',
                          hintText: '18:30',
                          prefixIcon: Icon(Icons.schedule_send_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _maxQueueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Numero massimo richieste in coda',
                          prefixIcon: Icon(Icons.format_list_numbered_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _switchTile(
                        title: 'Accettazione automatica richieste',
                        subtitle: 'Assegna automaticamente le richieste nuove',
                        value: _accettazioneAutomatica,
                        onChanged: (value) =>
                            setState(() => _accettazioneAutomatica = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SafeClaimColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSaving ? null : _saveSettings,
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'SALVA IMPOSTAZIONI',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: SafeClaimColors.dangerSoft,
        border: Border.all(color: SafeClaimColors.danger),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _errorMessage!,
        style: const TextStyle(color: SafeClaimColors.danger),
      ),
    );
  }

  Widget _settingsCard({
    required bool isDark,
    required Color cardColor,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: safeClaimCardDecoration(isDark, color: cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: SafeClaimColors.primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : SafeClaimColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      activeThumbColor: Colors.white,
      activeTrackColor: SafeClaimColors.primary,
      contentPadding: EdgeInsets.zero,
      onChanged: onChanged,
    );
  }
}
