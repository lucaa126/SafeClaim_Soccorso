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

  // Account
  final _accountNomeController = TextEditingController();
  final _accountTelefonoController = TextEditingController();
  AccountProfile _account = AccountProfile.empty();
  bool _isSavingAccount = false;

  // Workshop
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _avatarController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _maxQueueController = TextEditingController();

  bool _isLoading = true;
  bool _isSavingWorkshop = false;
  String? _errorMessage;

  bool _operativoOnline = false;
  bool _accettazioneAutomatica = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _accountNomeController.dispose();
    _accountTelefonoController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _maxQueueController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // I due caricamenti sono indipendenti: un fallimento dell'uno non
    // deve bloccare l'altro.
    AccountProfile account = AccountProfile.empty();
    WorkshopSettings workshop = WorkshopSettings.empty();
    String? warnings;

    try {
      account = await _settingsApi.getAccount();
    } catch (e) {
      warnings = 'Account: ${_normalizeError(e)}';
    }

    try {
      workshop = await _settingsApi.getSettings();
    } catch (e) {
      warnings = (warnings == null ? '' : '$warnings\n') +
          'Impostazioni servizio: ${_normalizeError(e)}';
    }

    if (!mounted) return;

    setState(() {
      _applyAccount(account);
      _applyWorkshop(workshop);
      _isLoading = false;
      _errorMessage = warnings;
    });
  }

  void _applyAccount(AccountProfile account) {
    _account = account;
    _accountNomeController.text = account.nome;
    _accountTelefonoController.text = account.telefono;
  }

  void _applyWorkshop(WorkshopSettings settings) {
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

  Future<void> _saveAccount() async {
    FocusScope.of(context).unfocus();
    setState(() => _isSavingAccount = true);

    try {
      final updated = await _settingsApi.updateAccount(
        nome: _accountNomeController.text.trim(),
        telefono: _accountTelefonoController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _applyAccount(updated));
      _showSnack('Account aggiornato con successo', success: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(_normalizeError(e));
    } finally {
      if (mounted) setState(() => _isSavingAccount = false);
    }
  }

  Future<void> _saveWorkshop() async {
    FocusScope.of(context).unfocus();

    final maxQueue = int.tryParse(_maxQueueController.text.trim());
    if (maxQueue == null || maxQueue < 0) {
      _showSnack('Numero massimo richieste in coda non valido.');
      return;
    }

    final startTime = _startTimeController.text.trim();
    final endTime = _endTimeController.text.trim();
    if (!_isValidOptionalTime(startTime) || !_isValidOptionalTime(endTime)) {
      _showSnack('Gli orari devono essere nel formato HH:MM.');
      return;
    }

    setState(() => _isSavingWorkshop = true);

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
      _showSnack('Impostazioni servizio salvate', success: true);
      await _loadAll();
    } catch (e) {
      if (!mounted) return;
      _showSnack(_normalizeError(e));
    } finally {
      if (mounted) setState(() => _isSavingWorkshop = false);
    }
  }

  Future<void> _openChangePasswordDialog() async {
    final result = await showDialog<_PasswordResult>(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );
    if (result == null) return;

    try {
      await _settingsApi.changePassword(
        oldPassword: result.oldPassword,
        newPassword: result.newPassword,
      );
      if (!mounted) return;
      _showSnack('Password aggiornata correttamente', success: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(_normalizeError(e));
    }
  }

  bool _isValidOptionalTime(String value) {
    if (value.isEmpty) return true;
    return RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(value);
  }

  void _showSnack(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? message : 'Errore: $message'),
        backgroundColor:
            success ? SafeClaimColors.primary : SafeClaimColors.danger,
      ),
    );
  }

  String _normalizeError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    final normalized = message.toLowerCase();

    if (normalized.contains('authentication failed') ||
        normalized.contains('mongodb') ||
        normalized.contains('database non disponibile')) {
      return 'Configurazione database non disponibile. Contatta il supporto tecnico.';
    }
    if (normalized.contains('password attuale errata')) {
      return 'Password attuale errata';
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
              onRefresh: _loadAll,
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  Text(
                    'Impostazioni',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : SafeClaimColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Account e parametri del servizio.',
                    style: TextStyle(
                      fontSize: 14,
                      color: safeClaimSubtleTextColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) _buildErrorBanner(),
                  _buildAccountCard(isDark, cardColor),
                  const SizedBox(height: 20),
                  _buildWorkshopProfileCard(isDark, cardColor),
                  const SizedBox(height: 20),
                  _buildOperationalCard(isDark, cardColor),
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
                      onPressed: _isSavingWorkshop ? null : _saveWorkshop,
                      child: _isSavingWorkshop
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'SALVA IMPOSTAZIONI SERVIZIO',
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

  // ----- Card Account --------------------------------------------------

  Widget _buildAccountCard(bool isDark, Color cardColor) {
    final hasCognome = _account.hasCognome;
    final fullName =
        hasCognome ? '${_account.nome} ${_account.cognome}'.trim() : _account.nome;

    return _settingsCard(
      isDark: isDark,
      cardColor: cardColor,
      title: 'Account',
      icon: Icons.person_rounded,
      children: [
        // Riga riassuntiva read-only
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? SafeClaimColors.darkSurface
                : SafeClaimColors.primaryLightest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName.isEmpty ? '—' : fullName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : SafeClaimColors.foreground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _account.email.isEmpty ? 'Email non disponibile' : _account.email,
                style: TextStyle(
                  color: safeClaimSubtleTextColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_account.ruoli.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _account.ruoli
                      .map((r) => Chip(
                            label: Text(r),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: SafeClaimColors.primary
                                .withValues(alpha: 0.12),
                            labelStyle: const TextStyle(
                              color: SafeClaimColors.primaryDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _accountNomeController,
          decoration: const InputDecoration(
            labelText: 'Nome',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        if (hasCognome) ...[
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _account.cognome,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Cognome (non modificabile)',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _account.email,
          enabled: false,
          decoration: const InputDecoration(
            labelText: 'Email (non modificabile)',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _accountTelefonoController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Telefono',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSavingAccount ? null : _saveAccount,
                icon: _isSavingAccount
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined, color: Colors.white),
                label: const Text(
                  'Salva account',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SafeClaimColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openChangePasswordDialog,
                icon: const Icon(Icons.lock_reset_rounded),
                label: const Text('Cambia password'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SafeClaimColors.primary,
                  side: const BorderSide(color: SafeClaimColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkshopProfileCard(bool isDark, Color cardColor) {
    return _settingsCard(
      isDark: isDark,
      cardColor: cardColor,
      title: 'Profilo Servizio Soccorso',
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
            labelText: 'Email contatto servizio',
            prefixIcon: Icon(Icons.email_rounded),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Telefono contatto servizio',
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
    );
  }

  Widget _buildOperationalCard(bool isDark, Color cardColor) {
    return _settingsCard(
      isDark: isDark,
      cardColor: cardColor,
      title: 'Parametri Operativi',
      icon: Icons.tune_rounded,
      children: [
        _switchTile(
          title: 'Stato operativo online',
          subtitle: 'Disponibilità del servizio soccorso',
          value: _operativoOnline,
          onChanged: (value) => setState(() => _operativoOnline = value),
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

class _PasswordResult {
  final String oldPassword;
  final String newPassword;
  const _PasswordResult(this.oldPassword, this.newPassword);
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _hideOld = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _PasswordResult(_oldController.text, _newController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambia password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _oldController,
              obscureText: _hideOld,
              decoration: InputDecoration(
                labelText: 'Password attuale',
                suffixIcon: IconButton(
                  icon: Icon(
                      _hideOld ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _hideOld = !_hideOld),
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Obbligatoria' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newController,
              obscureText: _hideNew,
              decoration: InputDecoration(
                labelText: 'Nuova password',
                suffixIcon: IconButton(
                  icon: Icon(
                      _hideNew ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _hideNew = !_hideNew),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Obbligatoria';
                if (v.length < 8) return 'Almeno 8 caratteri';
                if (v == _oldController.text) {
                  return 'Deve essere diversa dalla password attuale';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmController,
              obscureText: _hideConfirm,
              decoration: InputDecoration(
                labelText: 'Conferma nuova password',
                suffixIcon: IconButton(
                  icon: Icon(_hideConfirm
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _hideConfirm = !_hideConfirm),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Obbligatoria';
                if (v != _newController.text) {
                  return 'Le password non coincidono';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Cambia password'),
        ),
      ],
    );
  }
}
