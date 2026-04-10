import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../app/app.dart';
import '../../app/routes.dart';
import '../../widgets/app_drawer.dart';
import 'dashboard_api_service.dart';
import '../dettaglio/dettaglio_intervento_page.dart';
import '../interventi/intervento_api_service.dart';

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
      Icon(Icons.nightlight_round, size: 18),
    ],
  );
}

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
      _showSnack(error.toString().replaceFirst('Exception: ', ''));
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
      _showSnack(error.toString().replaceFirst('Exception: ', ''));
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

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final summary = _summary;

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
                color: isDark ? Colors.white : const Color(0xFF374151),
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Benvenuto, ${summary?.workshopName ?? 'Officina Centrale'}',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.grey,
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
                          'Stato Operativo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (summary?.operativoOnline ?? false)
                              ? 'Online - Ricezione chiamate'
                              : 'Offline - Pausa',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: summary?.operativoOnline ?? false,
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF6A7AF4),
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
              bubble: const Color(0xFF6A7AF4),
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
              bubble: const Color(0xFF2EE6A6),
              bubbleChild: const Icon(Icons.check_rounded, color: Colors.white),
              value: '${summary?.completatiOggi ?? 0}',
              label: 'Completati Oggi',
            ),
            const SizedBox(height: 14),
            _kpi(
              isDark: isDark,
              cardColor: cardColor,
              bubble: const Color(0xFFFFC24A),
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
                color: isDark ? Colors.white : const Color(0xFF374151),
                letterSpacing: -0.7,
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
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        showCheckboxColumn: false,
                        headingTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        dataRowMaxHeight: 72,
                        dataRowMinHeight: 72,
                        horizontalMargin: 24,
                        dividerThickness: 0.5,
                        columnSpacing: 28,
                        columns: const [
                          DataColumn(label: Text('Posizione')),
                          DataColumn(label: Text('Stato')),
                          DataColumn(label: Text('Azioni')),
                        ],
                        rows: _richieste.map((richiesta) {
                          return DataRow(
                            cells: [
                              DataCell(
                                _buildPosizioneCell(
                                  isDark,
                                  richiesta.posizione,
                                ),
                                onTap: () => _focusRichiesta(richiesta),
                              ),
                              DataCell(
                                _statusChip(isDark, richiesta.status),
                                onTap: () => _focusRichiesta(richiesta),
                              ),
                              DataCell(
                                _buildActionButtons(
                                  isDark: isDark,
                                  richiesta: richiesta,
                                  isBusy:
                                      _pendingActionRequestId == richiesta.id,
                                  onFocus: () => _focusRichiesta(richiesta),
                                  onOpenDetail: () => _openDettaglio(richiesta),
                                  onAction: (action) =>
                                      _performAction(richiesta.id, action),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
            const SizedBox(height: 18),
            Text(
              'Mappa Intervento',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF374151),
                letterSpacing: -0.6,
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
                        child: Text('Seleziona una richiesta dalla tabella.'),
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
                                color: Color(0xFF6A7AF4),
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
                                          : const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_selectedRichiesta!.posizione} ${_selectedRichiesta!.tipoLabel}',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.grey,
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
                                            color: Color(0xFF6A7AF4),
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
                                                : const Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_selectedRichiesta!.lat.toStringAsFixed(4)}, ${_selectedRichiesta!.lng.toStringAsFixed(4)}',
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.grey,
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
                color: isDark ? Colors.white : const Color(0xFF111827),
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

Widget _buildPosizioneCell(bool isDark, String label) {
  return Row(
    children: [
      Icon(
        Icons.location_on_rounded,
        size: 16,
        color: isDark ? Colors.white : Colors.black87,
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6A7AF4),
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}

Widget _buildActionButtons({
  required bool isDark,
  required QueueRequest richiesta,
  required bool isBusy,
  required VoidCallback onFocus,
  required VoidCallback onOpenDetail,
  required ValueChanged<String> onAction,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _iconButton(
        icon: Icons.visibility_rounded,
        color: isDark ? Colors.white70 : const Color(0xFF374151),
        onTap: onOpenDetail,
      ),
      if (richiesta.availableActions.contains('take_in_charge')) ...[
        const SizedBox(width: 8),
        _iconButton(
          icon: Icons.check,
          color: Colors.green,
          onTap: isBusy ? null : () => onAction('take_in_charge'),
        ),
      ],
      if (richiesta.availableActions.contains('complete')) ...[
        const SizedBox(width: 8),
        _iconButton(
          icon: Icons.done_all_rounded,
          color: const Color(0xFF2E8B57),
          onTap: isBusy ? null : () => onAction('complete'),
        ),
      ],
      if (richiesta.availableActions.contains('reject')) ...[
        const SizedBox(width: 8),
        _iconButton(
          icon: Icons.close,
          color: Colors.redAccent,
          onTap: isBusy ? null : () => onAction('reject'),
        ),
      ],
      if (isBusy) ...[
        const SizedBox(width: 8),
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ],
      if (!isBusy &&
          !richiesta.availableActions.contains('take_in_charge') &&
          !richiesta.availableActions.contains('complete') &&
          !richiesta.availableActions.contains('reject')) ...[
        const SizedBox(width: 8),
        InkWell(
          onTap: onFocus,
          child: const Text(
            'Nessuna',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ],
  );
}

Widget _iconButton({
  required IconData icon,
  required Color color,
  required VoidCallback? onTap,
}) {
  return Material(
    color: Colors.transparent,
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.85), width: 3),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    ),
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
    decoration: BoxDecoration(
      color: color,
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
        ),
      ],
    ),
  );
}

Widget _statusChip(bool isDark, String status) {
  late Color bg;
  late Color fg;
  late String text;

  switch (status) {
    case 'pending':
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFE65100);
      text = 'PENDING';
      break;
    case 'accepted':
      bg = const Color(0xFFE8EAF6);
      fg = const Color(0xFF3F51B5);
      text = 'ACCEPTED';
      break;
    case 'handled':
      bg = const Color(0xFFE0F2F1);
      fg = const Color(0xFF00796B);
      text = 'HANDLED';
      break;
    default:
      bg = const Color(0xFFFFEBEE);
      fg = const Color(0xFFC62828);
      text = status.toUpperCase();
  }

  if (isDark) {
    bg = bg.withValues(alpha: 0.22);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 13),
    ),
  );
}
