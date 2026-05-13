import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../widgets/app_drawer.dart';
import '../../app/theme.dart';
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

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _notificheAttive = false;
  bool _notificationsSupported = true;

  int _officinaId = 1;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    _resolveOfficinaIdAndLoad();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _resolveOfficinaIdAndLoad() async {
    try {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      final resolvedId = _extractOfficinaId(routeArgs);

      if (resolvedId != null) {
        _officinaId = resolvedId;
      }

      await _loadSettings();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _notificheAttive = false;
        _notificationsSupported = false;
        _isLoading = false;
        _errorMessage =
            'Impostazioni non disponibili dal backend. '
            '${_normalizeError(error)}';
      });
    }
  }

  int? _extractOfficinaId(dynamic args) {
    if (args == null) return null;

    if (args is int) return args;

    if (args is Map) {
      final dynamic value = args['officina_id'] ?? args['officinaId'];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
    }

    return null;
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final settings = await _settingsApi.getSettings(officinaId: _officinaId);

      if (!mounted) return;

      setState(() {
        if (settings.officinaId > 0) {
          _officinaId = settings.officinaId;
        }

        _nameController.text = settings.workshopName;
        _emailController.text = settings.email;
        _phoneController.text = settings.phone;
        _notificheAttive = settings.notificheAttive ?? false;
        _notificationsSupported = settings.notificheAttive != null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _notificheAttive = false;
        _notificationsSupported = false;
        _isLoading = false;
        _errorMessage =
            'Impostazioni non disponibili dal backend. '
            '${_normalizeError(error)}';
      });
    }
  }

  Future<void> _saveSettings() async {
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);

    try {
      await _settingsApi.updateProfile(
        officinaId: _officinaId,
        workshopName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (_notificationsSupported) {
        try {
          await _settingsApi.updateNotifications(
            officinaId: _officinaId,
            push: _notificheAttive,
          );
        } catch (_) {
          _notificationsSupported = false;
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _notificationsSupported
                ? 'Impostazioni salvate con successo!'
                : 'Profilo salvato. Le notifiche non sono supportate dal backend attuale',
          ),
          backgroundColor: SafeClaimColors.primary,
        ),
      );

      await _loadSettings();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore: ${_normalizeError(error)}'),
          backgroundColor: SafeClaimColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _normalizeError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = safeClaimCardColor(isDark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
        actions: [
          buildSharedThemeToggle(context, isDark),
          const SizedBox(width: 16),
        ],
      ),
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
                    'Configurazione Officina',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : SafeClaimColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Officina ID: $_officinaId',
                    style: TextStyle(
                      fontSize: 14,
                      color: safeClaimSubtleTextColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Container(
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
                    ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: safeClaimCardDecoration(
                      isDark,
                      color: cardColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome Officina',
                            prefixIcon: Icon(Icons.build),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email di contatto',
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Numero di telefono',
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SwitchListTile.adaptive(
                          title: const Text('Ricevi notifiche push'),
                          subtitle: Text(
                            _notificationsSupported
                                ? 'Avvisi per nuove richieste di soccorso'
                                : 'Non disponibile con il backend attuale',
                          ),
                          value: _notificheAttive,
                          activeThumbColor: Colors.white,
                          activeTrackColor: SafeClaimColors.primary,
                          contentPadding: EdgeInsets.zero,
                          onChanged: _notificationsSupported
                              ? (val) {
                                  setState(() => _notificheAttive = val);
                                }
                              : null,
                        ),
                      ],
                    ),
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
}
