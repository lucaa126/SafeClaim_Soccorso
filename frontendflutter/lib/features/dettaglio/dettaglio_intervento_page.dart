import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/auth_service.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/safeclaim_ui.dart';
import '../interventi/intervento_api_service.dart';

class DettaglioArgs {
  final String id;
  final String cliente;
  final double lat;
  final double lng;

  const DettaglioArgs({
    required this.id,
    required this.cliente,
    this.lat = 45.4642,
    this.lng = 9.1900,
  });
}

class DettaglioInterventoPage extends StatefulWidget {
  final DettaglioArgs args;

  const DettaglioInterventoPage({super.key, required this.args});

  @override
  State<DettaglioInterventoPage> createState() =>
      _DettaglioInterventoPageState();
}

class _DettaglioInterventoPageState extends State<DettaglioInterventoPage> {
  final InterventoApiService _api = InterventoApiService();
  late final MapController _mapController;
  late double _zoom;

  InterventionDetail? _detail;
  bool _isLoading = true;
  String? _errorMessage;
  String? _actionInFlight;

  double get _currentLat => _detail?.lat ?? widget.args.lat;
  double get _currentLng => _detail?.lng ?? widget.args.lng;
  String get _currentCliente => _detail?.cliente ?? widget.args.cliente;
  String get _currentId => _detail?.id ?? widget.args.id;

  LatLng get _interventoPoint => LatLng(_currentLat, _currentLng);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _zoom = 13;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _api.getInterventoDetail(widget.args.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
      _moveMap();
    } catch (error) {
      if (!mounted) {
        return;
      }
      if (error is TokenInvalidException) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
        return;
      }
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _moveMap() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _mapController.move(_interventoPoint, _zoom);
    });
  }

  Future<void> _setZoom(double zoom) async {
    final nextZoom = zoom.clamp(5.0, 18.0);
    setState(() => _zoom = nextZoom);
    _mapController.move(_interventoPoint, nextZoom);
  }

  Future<void> _openNavigation() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$_currentLat,$_currentLng&travelmode=driving',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aprire Google Maps.')),
      );
    }
  }

  Future<void> _runAction(String action) async {
    setState(() => _actionInFlight = action);
    try {
      late final ActionResponse response;
      switch (action) {
        case 'take_in_charge':
          response = await _api.takeInCharge(_currentId);
          break;
        case 'reject':
          response = await _api.reject(_currentId);
          break;
        case 'complete':
          response = await _api.complete(_currentId);
          break;
        default:
          throw Exception('Azione non supportata');
      }
      if (!mounted) {
        return;
      }
      setState(() => _detail = response.detail);
      _moveMap();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      if (error is TokenInvalidException) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _actionInFlight = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = safeClaimCardColor(isDark);
    final detail = _detail;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dettaglio Intervento',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
        centerTitle: false,
        actions: [
          buildSharedThemeToggle(context, isDark),
          const SizedBox(width: 16),
        ],
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const AppDrawer(currentRoute: Routes.dettaglio),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDetail,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            if (_errorMessage != null) ...[
              _card(
                isDark: isDark,
                color: cardColor,
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: SafeClaimColors.danger,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : SafeClaimColors.foreground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadDetail,
                      child: const Text('Riprova'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            _card(
              isDark: isDark,
              color: cardColor,
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _labelValue(
                              label: 'ID',
                              value: _currentId,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 10),
                            _labelValue(
                              label: 'Cliente',
                              value: _currentCliente,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 10),
                            _labelValue(
                              label: 'Stato',
                              value: detail?.statusText ?? 'Caricamento...',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: CircularProgressIndicator(),
                        )
                      else
                        _statusBadge(detail?.status ?? 'pending'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 260,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _interventoPoint,
                              initialZoom: _zoom,
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
                                    point: _interventoPoint,
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
                            left: 16,
                            top: 16,
                            child: _zoomBox(isDark),
                          ),
                          Positioned(
                            left: 86,
                            top: 20,
                            child: _tooltipBubble(isDark),
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Material(
                              color: isDark
                                  ? SafeClaimColors.darkSurface.withValues(
                                      alpha: 0.92,
                                    )
                                  : Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: _openNavigation,
                                borderRadius: BorderRadius.circular(14),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.navigation_rounded,
                                        size: 18,
                                        color: SafeClaimColors.primary,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Apri Maps',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                  const SizedBox(height: 16),
                  if (detail != null) ...[
                    _detailRow('Posizione', detail.posizione, isDark),
                    const SizedBox(height: 8),
                    _detailRow('Veicolo', detail.vehicleType, isDark),
                    const SizedBox(height: 8),
                    _detailRow(
                      'Assegnato a',
                      detail.assignedDriver ?? 'Non assegnato',
                      isDark,
                    ),
                    const SizedBox(height: 8),
                    _detailRow(
                      'Note',
                      detail.notes?.isNotEmpty == true
                          ? detail.notes!
                          : 'Nessuna nota',
                      isDark,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (detail?.availableActions.contains('take_in_charge') ??
                      false) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _actionInFlight == null
                            ? () => _runAction('take_in_charge')
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SafeClaimColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _actionInFlight == 'take_in_charge'
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Prendi in Carico',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (detail?.availableActions.contains('complete') ??
                      false) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _actionInFlight == null
                            ? () => _runAction('complete')
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SafeClaimColors.textStrong,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _actionInFlight == 'complete'
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Completa Intervento',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (detail?.availableActions.contains('reject') ?? false)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _actionInFlight == null
                            ? () => _runAction('reject')
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SafeClaimColors.danger,
                          side: const BorderSide(
                            color: SafeClaimColors.danger,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _actionInFlight == 'reject'
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Rifiuta',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  if ((detail?.availableActions.isEmpty ?? true) && !_isLoading)
                    Text(
                      'Nessuna azione disponibile per questo intervento.',
                      style: TextStyle(
                        color: safeClaimSubtleTextColor(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Text(
                  'Traffico Live',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : SafeClaimColors.foreground,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadDetail,
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: safeClaimSubtleTextColor(isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _trafficCard(
              isDark: isDark,
              cardColor: cardColor,
              iconBg: SafeClaimColors.danger,
              icon: Icons.car_crash_rounded,
              title: 'Incidente in tangenziale Est a Milano, cod...',
              source: 'News Traffico',
              time: '18:20',
            ),
            const SizedBox(height: 12),
            _trafficCard(
              isDark: isDark,
              cardColor: cardColor,
              iconBg: SafeClaimColors.danger,
              icon: Icons.car_crash_rounded,
              title: 'Incidente Al adesso: 4 km di coda verso ...',
              source: 'News Traffico',
              time: '08:39',
            ),
            const SizedBox(height: 12),
            _trafficCard(
              isDark: isDark,
              cardColor: cardColor,
              iconBg: SafeClaimColors.warning,
              icon: Icons.traffic_rounded,
              title: 'Tir si ribalta sull’Autosole, oltre 6 chilome...',
              source: 'News Traffico',
              time: '08:00',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _zoomBox(bool isDark) {
    return Container(
      width: 52,
      decoration: BoxDecoration(
        color: isDark ? SafeClaimColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
            ),
        ],
      ),
      child: Column(
        children: [
          IconButton(
            onPressed: () => _setZoom(_zoom + 1),
            icon: Icon(
              Icons.add_rounded,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
          IconButton(
            onPressed: () => _setZoom(_zoom - 1),
            icon: Icon(
              Icons.remove_rounded,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tooltipBubble(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? SafeClaimColors.darkSurface.withValues(alpha: 0.90)
            : Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 18,
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _detail?.statusText ?? 'Veicolo Fermo',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : SafeClaimColors.foreground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_currentLat.toStringAsFixed(4)}, ${_currentLng.toStringAsFixed(4)}',
                style: TextStyle(
                  color: safeClaimSubtleTextColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trafficCard({
    required bool isDark,
    required Color cardColor,
    required Color iconBg,
    required IconData icon,
    required String title,
    required String source,
    required String time,
  }) {
    return _card(
      isDark: isDark,
      color: cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: iconBg,
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : SafeClaimColors.foreground,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  source,
                  style: TextStyle(
                    color: safeClaimSubtleTextColor(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: TextStyle(
              color: safeClaimSubtleTextColor(isDark),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _labelValue({
  required String label,
  required String value,
  required bool isDark,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$label:',
        style: TextStyle(
          color: safeClaimSubtleTextColor(isDark),
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : SafeClaimColors.foreground,
        ),
      ),
    ],
  );
}

Widget _detailRow(String label, String value, bool isDark) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 110,
        child: Text(
          label,
          style: TextStyle(
            color: safeClaimSubtleTextColor(isDark),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : SafeClaimColors.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

Widget _statusBadge(String status) {
  Color background;
  Color foreground;

  switch (status) {
    case 'accepted':
      background = SafeClaimColors.primaryLight.withValues(alpha: 0.22);
      foreground = SafeClaimColors.primaryDark;
      break;
    case 'handled':
      background = SafeClaimColors.textStrong.withValues(alpha: 0.10);
      foreground = SafeClaimColors.textStrong;
      break;
    case 'rejected':
      background = SafeClaimColors.dangerSoft;
      foreground = SafeClaimColors.danger;
      break;
    default:
      background = SafeClaimColors.primaryLightest;
      foreground = SafeClaimColors.textStrong;
      break;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: foreground.withValues(alpha: 0.45)),
    ),
    child: Text(
      status.toUpperCase(),
      style: TextStyle(color: foreground, fontWeight: FontWeight.w900),
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
    decoration: safeClaimCardDecoration(isDark, color: color),
    child: child,
  );
}
