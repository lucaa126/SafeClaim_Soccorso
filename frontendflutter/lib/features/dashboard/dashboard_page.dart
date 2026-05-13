import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../app/auth_service.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/safeclaim_ui.dart';
import 'dashboard_api_service.dart';
import '../dettaglio/dettaglio_intervento_page.dart';
import '../interventi/intervento_api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardApiService _dashboardApi = DashboardApiService();
  final InterventoApiService _interventoApi = InterventoApiService();
  late final MapController _mapController;

  DashboardSummary? _summary;
  List<QueueRequest> _richieste = const [];
  QueueRequest? _selectedRichiesta;
  bool _isLoading = true;
  bool _isUpdatingOperational = false;
  String? _pendingActionRequestId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadDashboard();
  }

  Future<void> _loadDashboard({String? preserveSelectionId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        _dashboardApi.getDashboardSummary(),
        _dashboardApi.getDashboardRequests(),
      ]);
      final summary = results[0] as DashboardSummary;
      final requests = results[1] as List<QueueRequest>;
      final selected = _resolveSelection(
        requests,
        preserveSelectionId ??
            _selectedRichiesta?.id ??
            summary.selectedRequestId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _summary = summary;
        _richieste = requests;
        _selectedRichiesta = selected;
        _isLoading = false;
      });
      _moveMapToSelected();
    } catch (error) {
      if (!mounted) {
        return;
      }
      if (error is TokenInvalidException) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  QueueRequest? _resolveSelection(
    List<QueueRequest> requests,
    String? preferredId,
  ) {
    if (requests.isEmpty) {
      return null;
    }
    if (preferredId != null) {
      for (final richiesta in requests) {
        if (richiesta.id == preferredId) {
          return richiesta;
        }
      }
    }
    return requests.first;
  }

  void _moveMapToSelected() {
    final richiesta = _selectedRichiesta;
    if (richiesta == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _mapController.move(LatLng(richiesta.lat, richiesta.lng), 13.8);
    });
  }

  void _focusRichiesta(QueueRequest richiesta) {
    setState(() => _selectedRichiesta = richiesta);
    _moveMapToSelected();
  }

  Future<void> _toggleOperational(bool value) async {
    setState(() => _isUpdatingOperational = true);
    try {
      final summary = await _dashboardApi.setOperationalStatus(value);
      if (!mounted) {
        return;
      }
      setState(() {
        _summary = summary;
        _isUpdatingOperational = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isUpdatingOperational = false);
      _handleAuthError(error);
    }
  }

  Future<void> _performAction(String requestId, String action) async {
    setState(() => _pendingActionRequestId = requestId);
    try {
      late final ActionResponse response;
      switch (action) {
        case 'take_in_charge':
          response = await _interventoApi.takeInCharge(requestId);
          break;
        case 'reject':
          response = await _interventoApi.reject(requestId);
          break;
        case 'complete':
          response = await _interventoApi.complete(requestId);
          break;
        default:
          throw Exception('Azione non supportata');
      }
      if (!mounted) {
        return;
      }
      _showSnack(response.message);
      await _loadDashboard(preserveSelectionId: response.requestId);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _handleAuthError(error);
    } finally {
      if (mounted) {
        setState(() => _pendingActionRequestId = null);
      }
    }
  }

  void _openDettaglio(QueueRequest richiesta) {
    Navigator.pushNamed(
      context,
      Routes.dettaglio,
      arguments: DettaglioArgs(
        id: richiesta.id,
        cliente: richiesta.cliente,
        lat: richiesta.lat,
        lng: richiesta.lng,
      ),
    ).then((_) => _loadDashboard(preserveSelectionId: richiesta.id));
  }

  void _handleAuthError(Object error) {
    if (error is TokenInvalidException) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
      return;
    }

    _showSnack(error.toString().replaceFirst('Exception: ', ''));
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = safeClaimCardColor(isDark);
    final summary = _summary;

    return Scaffold(
      appBar: AppBar(),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const AppDrawer(currentRoute: Routes.dashboard),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            Text(
              'Dashboard Operativa',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : SafeClaimColors.foreground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Benvenuto, ${summary?.workshopName ?? 'Officina Centrale'}',
              style: TextStyle(
                fontSize: 15,
                color: safeClaimSubtleTextColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            if (_errorMessage != null) ...[
              _buildErrorCard(isDark, cardColor),
              const SizedBox(height: 14),
            ],
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
                        colors: [
                          SafeClaimColors.primaryLight,
                          SafeClaimColors.primary,
                        ],
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
                          'Stato Operativo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? Colors.white
                                : SafeClaimColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (summary?.operativoOnline ?? false)
                              ? 'Online - Ricezione chiamate'
                              : 'Offline - Pausa',
                          style: TextStyle(
                            color: safeClaimSubtleTextColor(isDark),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: summary?.operativoOnline ?? false,
                    activeThumbColor: Colors.white,
                    activeTrackColor: SafeClaimColors.primary,
                    onChanged: _isUpdatingOperational
                        ? null
                        : _toggleOperational,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _kpi(
              isDark: isDark,
              cardColor: cardColor,
              bubble: SafeClaimColors.primary,
              bubbleChild: const Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              value: '${summary?.richiesteAttive ?? 0}',
              label: 'Richieste Attive',
            ),
            const SizedBox(height: 14),
            _kpi(
              isDark: isDark,
              cardColor: cardColor,
              bubble: SafeClaimColors.primaryLight,
              bubbleChild: const Icon(Icons.check_rounded, color: Colors.white),
              value: '${summary?.completatiOggi ?? 0}',
              label: 'Completati Oggi',
            ),
            const SizedBox(height: 14),
            _kpi(
              isDark: isDark,
              cardColor: cardColor,
              bubble: SafeClaimColors.textMuted,
              bubbleChild: const Icon(
                Icons.access_time_rounded,
                color: Colors.white,
              ),
              value: '${summary?.tempoMedioMinuti ?? 0}m',
              label: 'Tempo Medio',
            ),
            const SizedBox(height: 26),
            Text(
              'Richieste in Coda',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : SafeClaimColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? SafeClaimColors.darkSurface
                    : SafeClaimColors.primaryLightest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: SafeClaimColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_richieste.length} richieste da gestire',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : SafeClaimColors.foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    'Tap per selezionare',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white60
                          : SafeClaimColors.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _card(
              isDark: isDark,
              color: cardColor,
              padding: const EdgeInsets.all(16),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _richieste.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('Nessuna richiesta disponibile.'),
                      ),
                    )
                  : Column(
                      children: _richieste.map((richiesta) {
                        final isSelected =
                            _selectedRichiesta?.id == richiesta.id;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: richiesta == _richieste.last ? 0 : 12,
                          ),
                          child: _buildRequestCard(
                            isDark: isDark,
                            richiesta: richiesta,
                            isSelected: isSelected,
                            isBusy: _pendingActionRequestId == richiesta.id,
                            onTap: () => _focusRichiesta(richiesta),
                            onOpenDetail: () => _openDettaglio(richiesta),
                            onAction: (action) =>
                                _performAction(richiesta.id, action),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 18),
            Text(
              'Mappa Intervento',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : SafeClaimColors.foreground,
              ),
            ),
            const SizedBox(height: 12),
            _card(
              isDark: isDark,
              color: cardColor,
              padding: const EdgeInsets.all(16),
              child: _selectedRichiesta == null
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('Seleziona una richiesta dalla lista.'),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: SafeClaimColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedRichiesta!.id,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? Colors.white
                                          : SafeClaimColors.foreground,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_selectedRichiesta!.posizione} ${_selectedRichiesta!.tipoLabel}',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : SafeClaimColors.textMuted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            height: 280,
                            child: Stack(
                              children: [
                                FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: LatLng(
                                      _selectedRichiesta!.lat,
                                      _selectedRichiesta!.lng,
                                    ),
                                    initialZoom: 13.8,
                                    minZoom: 5,
                                    maxZoom: 19,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName:
                                          'com.safeclaim.frontendflutter',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: LatLng(
                                            _selectedRichiesta!.lat,
                                            _selectedRichiesta!.lng,
                                          ),
                                          width: 56,
                                          height: 56,
                                          child: const Icon(
                                            Icons.location_on_rounded,
                                            size: 44,
                                            color: SafeClaimColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Positioned(
                                  left: 12,
                                  top: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xE62C2C2C)
                                          : const Color(0xF7FFFFFF),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedRichiesta!.statusText,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: isDark
                                                ? Colors.white
                                                : SafeClaimColors.foreground,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_selectedRichiesta!.lat.toStringAsFixed(4)}, ${_selectedRichiesta!.lng.toStringAsFixed(4)}',
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white70
                                                : SafeClaimColors.textMuted,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  bottom: 10,
                                  child: Opacity(
                                    opacity: 0.55,
                                    child: Text(
                                      'Leaflet | © OpenStreetMap',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black87,
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
                      ],
                    ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(bool isDark, Color cardColor) {
    return _card(
      isDark: isDark,
      color: cardColor,
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF4D5A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage ?? 'Errore sconosciuto',
              style: TextStyle(
                color: isDark ? Colors.white : SafeClaimColors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(onPressed: _loadDashboard, child: const Text('Riprova')),
        ],
      ),
    );
  }
}

Widget _buildRequestCard({
  required bool isDark,
  required QueueRequest richiesta,
  required bool isSelected,
  required bool isBusy,
  required VoidCallback onTap,
  required VoidCallback onOpenDetail,
  required ValueChanged<String> onAction,
}) {
  final borderColor = isSelected
      ? SafeClaimColors.primary
      : isDark
      ? Colors.white.withValues(alpha: 0.08)
      : SafeClaimColors.primaryLight.withValues(alpha: 0.45);
  final backgroundColor = isSelected
      ? (isDark ? SafeClaimColors.darkSurface : SafeClaimColors.primaryLightest)
      : (isDark ? SafeClaimColors.darkCard : Colors.white);

  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: isSelected ? 1.8 : 1),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: SafeClaimColors.primary.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? SafeClaimColors.primary
                        : SafeClaimColors.primary.withValues(alpha: 0.14),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: isSelected ? Colors.white : SafeClaimColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        richiesta.posizione,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : SafeClaimColors.foreground,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        richiesta.cliente,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : SafeClaimColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final pillMaxWidth = constraints.maxWidth;

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _statusChip(
                      isDark: isDark,
                      status: richiesta.status,
                      maxWidth: pillMaxWidth,
                    ),
                    _metaPill(
                      isDark: isDark,
                      icon: Icons.tag_rounded,
                      label: richiesta.id,
                      maxWidth: pillMaxWidth,
                    ),
                    _metaPill(
                      isDark: isDark,
                      icon: Icons.directions_car_filled_rounded,
                      label: richiesta.tipoLabel,
                      maxWidth: pillMaxWidth,
                    ),
                    if (isSelected)
                      _metaPill(
                        isDark: isDark,
                        icon: Icons.my_location_rounded,
                        label: 'Selezionata',
                        accent: SafeClaimColors.primary,
                        maxWidth: pillMaxWidth,
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : SafeClaimColors.primaryLight.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 14),
            _buildActionButtons(
              isDark: isDark,
              richiesta: richiesta,
              isBusy: isBusy,
              onOpenDetail: onOpenDetail,
              onAction: onAction,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildActionButtons({
  required bool isDark,
  required QueueRequest richiesta,
  required bool isBusy,
  required VoidCallback onOpenDetail,
  required ValueChanged<String> onAction,
}) {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      _actionButton(
        isDark: isDark,
        icon: Icons.visibility_rounded,
        label: 'Dettaglio',
        color: isDark ? Colors.white70 : SafeClaimColors.textStrong,
        onPressed: onOpenDetail,
      ),
      if (richiesta.availableActions.contains('take_in_charge')) ...[
        _actionButton(
          isDark: isDark,
          icon: Icons.check,
          label: 'Prendi in carico',
          color: SafeClaimColors.primary,
          onPressed: isBusy ? null : () => onAction('take_in_charge'),
        ),
      ],
      if (richiesta.availableActions.contains('complete')) ...[
        _actionButton(
          isDark: isDark,
          icon: Icons.done_all_rounded,
          label: 'Completa',
          color: SafeClaimColors.textStrong,
          onPressed: isBusy ? null : () => onAction('complete'),
        ),
      ],
      if (richiesta.availableActions.contains('reject')) ...[
        _actionButton(
          isDark: isDark,
          icon: Icons.close,
          label: 'Rifiuta',
          color: Colors.redAccent,
          onPressed: isBusy ? null : () => onAction('reject'),
        ),
      ],
      if (isBusy) ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : SafeClaimColors.primaryLightest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 10),
              Text(
                'Aggiornamento...',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
      if (!isBusy &&
          !richiesta.availableActions.contains('take_in_charge') &&
          !richiesta.availableActions.contains('complete') &&
          !richiesta.availableActions.contains('reject')) ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : SafeClaimColors.primaryLightest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Nessuna azione disponibile',
            style: TextStyle(
              color: isDark ? Colors.white70 : SafeClaimColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ],
  );
}

Widget _metaPill({
  required bool isDark,
  required IconData icon,
  required String label,
  Color? accent,
  double? maxWidth,
}) {
  final pillColor = accent;
  return ConstrainedBox(
    constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: pillColor != null
            ? pillColor.withValues(alpha: 0.14)
            : (isDark ? SafeClaimColors.darkSurface : Colors.white),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color:
              pillColor?.withValues(alpha: 0.26) ??
              (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : SafeClaimColors.primaryLight.withValues(alpha: 0.45)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: pillColor ?? SafeClaimColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : SafeClaimColors.foreground,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _actionButton({
  required bool isDark,
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback? onPressed,
}) {
  return OutlinedButton.icon(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color.withValues(alpha: 0.5)),
      backgroundColor: isDark
          ? color.withValues(alpha: 0.08)
          : color.withValues(alpha: 0.05),
      disabledForegroundColor: color.withValues(alpha: 0.35),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
    ),
    icon: Icon(icon, size: 16),
    label: Text(label),
  );
}

Widget _card({
  required bool isDark,
  required Color color,
  required Widget child,
  EdgeInsets padding = const EdgeInsets.all(20),
}) {
  return Container(
    width: double.infinity,
    padding: padding,
    decoration: safeClaimCardDecoration(isDark, color: color),
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
                color: isDark ? Colors.white : SafeClaimColors.foreground,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: safeClaimSubtleTextColor(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _statusChip({
  required bool isDark,
  required String status,
  double? maxWidth,
}) {
  late Color bg;
  late Color fg;
  late String text;

  switch (status) {
    case 'pending':
      bg = SafeClaimColors.primaryLightest;
      fg = SafeClaimColors.textStrong;
      text = 'In attesa';
      break;
    case 'accepted':
      bg = SafeClaimColors.primaryLight.withValues(alpha: 0.22);
      fg = SafeClaimColors.primaryDark;
      text = 'Accettata';
      break;
    case 'handled':
      bg = SafeClaimColors.textStrong.withValues(alpha: 0.10);
      fg = SafeClaimColors.textStrong;
      text = 'Completata';
      break;
    default:
      bg = SafeClaimColors.dangerSoft;
      fg = SafeClaimColors.danger;
      text = status.toUpperCase();
  }

  if (isDark) {
    bg = bg.withValues(alpha: 0.22);
  }

  return ConstrainedBox(
    constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.45)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 13),
      ),
    ),
  );
}
