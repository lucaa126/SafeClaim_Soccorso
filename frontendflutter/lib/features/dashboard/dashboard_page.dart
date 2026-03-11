import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../app/app.dart';
import '../../app/routes.dart';
import '../../widgets/app_drawer.dart';
import '../dettaglio/dettaglio_intervento_page.dart';

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

// ============================================================================
// DASHBOARD (replica schermata) con lo stile del tuo file
// ============================================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool operativoOnline = true;
  late final MapController _mapController;
  late _QueueRow _selectedRichiesta;

  final richieste = const [
    _QueueRow(
      id: 'SOS-2491',
      tipo: '(Furgone)',
      cliente: '+39 333 1234567',
      posizione: 'Milano Centro',
      lat: 45.4642,
      lng: 9.1900,
      statusKind: _StatusKind.pending,
      statusText: 'In Attesa',
      actionText: 'Accetta',
      actionKind: _ActionKind.outlinePrimary,
    ),
    _QueueRow(
      id: 'SOS-2492',
      tipo: '(SUV)',
      cliente: '+39 338 9876543',
      posizione: 'Rho Fiera',
      lat: 45.5184,
      lng: 9.0519,
      statusKind: _StatusKind.accepted,
      statusText: 'accepted',
      actionText: 'Completa',
      actionKind: _ActionKind.filledSuccess,
    ),
    _QueueRow(
      id: 'SOS-2488',
      tipo: '(City Car)',
      cliente: '+39 339 0000000',
      posizione: 'Linate',
      lat: 45.4610,
      lng: 9.2782,
      statusKind: _StatusKind.handled,
      statusText: 'handled',
      actionKind: _ActionKind.none,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedRichiesta = richieste.first;
  }

  void _focusRichiesta(_QueueRow richiesta) {
    setState(() => _selectedRichiesta = richiesta);
    _mapController.move(LatLng(richiesta.lat, richiesta.lng), 13.8);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (come screenshot: titolo grande + welcome)
            Text(
              "Dashboard Operativa",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF374151),
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Benvenuto, Officina Centrale",
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),

            // Stato Operativo
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
                          "Stato Operativo",
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
                          operativoOnline
                              ? "Online - Ricezione chiamate"
                              : "Offline - Pausa",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: operativoOnline,
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF6A7AF4),
                    onChanged: (v) => setState(() => operativoOnline = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // KPI Cards
            _kpi(
              isDark: isDark,
              cardColor: cardColor,
              bubble: const Color(0xFF6A7AF4),
              bubbleChild: const Text(
                "SOS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              value: "3",
              label: "Richieste Attive",
            ),
            const SizedBox(height: 14),
            _kpi(
              isDark: isDark,
              cardColor: cardColor,
              bubble: const Color(0xFF2EE6A6),
              bubbleChild: const Icon(Icons.check_rounded, color: Colors.white),
              value: "12",
              label: "Completati Oggi",
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
              value: "14m",
              label: "Tempo Medio",
            ),

            const SizedBox(height: 26),

            Text(
              "Richieste in Coda",
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  showCheckboxColumn: false,
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  dataRowMaxHeight: 70,
                  dataRowMinHeight: 70,
                  horizontalMargin: 24,
                  dividerThickness: 0.5,
                  columnSpacing: 40,
                  columns: const [
                    DataColumn(label: Text("Posizione")),
                    DataColumn(label: Text("Stato")),
                    DataColumn(label: Text("Azioni")),
                  ],
                  rows: richieste.map((r) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _buildPosizioneCell(isDark, r.posizione),
                          onTap: () => _focusRichiesta(r),
                        ),
                        DataCell(
                          _statusChip(isDark, r.statusKind),
                          onTap: () => _focusRichiesta(r),
                        ),
                        DataCell(
                          _buildActionButtons(context, r),
                          onTap: () => _focusRichiesta(r),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "Mappa Intervento",
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
              child: Column(
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
                              _selectedRichiesta.id,
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
                              '${_selectedRichiesta.posizione} ${_selectedRichiesta.tipo}',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.grey,
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
                                _selectedRichiesta.lat,
                                _selectedRichiesta.lng,
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
                                      _selectedRichiesta.lat,
                                      _selectedRichiesta.lng,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Veicolo fermo",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_selectedRichiesta.lat.toStringAsFixed(4)}, ${_selectedRichiesta.lng.toStringAsFixed(4)}',
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
                                "Leaflet | © OpenStreetMap",
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

Widget _buildActionButtons(BuildContext context, _QueueRow richiesta) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (richiesta.statusKind == _StatusKind.pending) ...[
        _iconButton(
          icon: Icons.check,
          color: Colors.green,
          onTap: () => _openDettaglio(context, richiesta),
        ),
        const SizedBox(width: 8),
      ],
      _iconButton(
        icon: Icons.close,
        color: Colors.redAccent,
        onTap: () => _openDettaglio(context, richiesta),
      ),
    ],
  );
}

void _openDettaglio(BuildContext context, _QueueRow richiesta) {
  Navigator.pushNamed(
    context,
    Routes.dettaglio,
    arguments: DettaglioArgs(
      id: richiesta.id,
      cliente: richiesta.cliente,
      lat: richiesta.lat,
      lng: richiesta.lng,
    ),
  );
}

Widget _iconButton({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
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

enum _StatusKind { pending, accepted, handled }

enum _ActionKind { outlinePrimary, filledSuccess, none }

Widget _statusChip(bool isDark, _StatusKind kind) {
  Color bg;
  Color fg;
  String text;

  switch (kind) {
    case _StatusKind.pending:
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFE65100);
      text = 'PENDING';
      break;
    case _StatusKind.accepted:
      bg = const Color(0xFFE8EAF6);
      fg = const Color(0xFF3F51B5);
      text = 'ACCEPTED';
      break;
    case _StatusKind.handled:
      bg = const Color(0xFFE0F2F1);
      fg = const Color(0xFF00796B);
      text = 'HANDLED';
      break;
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

class _QueueRow {
  final String id;
  final String tipo;
  final String cliente;
  final String posizione;
  final double lat;
  final double lng;
  final _StatusKind statusKind;
  final String statusText;
  final String actionText;
  final _ActionKind actionKind;

  const _QueueRow({
    required this.id,
    required this.tipo,
    required this.cliente,
    required this.posizione,
    required this.lat,
    required this.lng,
    required this.statusKind,
    this.statusText = '',
    this.actionText = '',
    this.actionKind = _ActionKind.none,
  });
}

// ============================================================================
// Pagine originali del tuo file: Richieste + Settings
// (le ho lasciate uguali per coerenza; in Richieste ho solo aggiornato il drawer route)
// ============================================================================
