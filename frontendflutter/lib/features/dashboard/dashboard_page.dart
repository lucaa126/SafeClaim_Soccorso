import 'package:flutter/material.dart';

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

  final richieste = const [
    _QueueRow(
      tipo: '(Furgone)',
      posizione: 'Mappa',
      statusKind: _StatusKind.pending,
      statusText: 'In Attesa',
      actionText: 'Accetta',
      actionKind: _ActionKind.outlinePrimary,
    ),
    _QueueRow(
      tipo: '(SUV)',
      posizione: 'Mappa',
      statusKind: _StatusKind.accepted,
      statusText: 'accepted',
      actionText: 'Completa',
      actionKind: _ActionKind.filledSuccess,
    ),
    _QueueRow(
      tipo: '',
      posizione: 'Mappa',
      statusKind: _StatusKind.handled,
      statusText: 'handled',
      actionKind: _ActionKind.none,
    ),
  ];

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
                        DataCell(_buildPosizioneCell(isDark, r.posizione)),
                        DataCell(_statusChip(isDark, r.statusKind)),
                        DataCell(_buildActionButtons(context, r.statusKind)),
                      ],
                    );
                  }).toList(),
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

  Widget _buildActionButtons(BuildContext context, _StatusKind status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == _StatusKind.pending) ...[
          _iconButton(
            icon: Icons.check,
            color: Colors.green,
            onTap: () => _openDettaglio(context),
          ),
          const SizedBox(width: 8),
        ],
        _iconButton(
          icon: Icons.close,
          color: Colors.redAccent,
          onTap: () => _openDettaglio(context),
        ),
      ],
    );
  }

  void _openDettaglio(BuildContext context) {
    Navigator.pushNamed(
      context,
      Routes.dettaglio,
      arguments: const DettaglioArgs(
        id: 'SOS-2491',
        cliente: '+39 333 1234567',
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, color: color, size: 18),
          ),
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
  final String tipo;
  final String posizione;
  final _StatusKind statusKind;
  final String statusText;
  final String actionText;
  final _ActionKind actionKind;

  const _QueueRow({
    required this.tipo,
    required this.posizione,
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
