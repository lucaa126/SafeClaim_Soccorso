import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../widgets/app_drawer.dart';
import '../dashboard/dashboard_page.dart';

class RichiestePage extends StatefulWidget {
  const RichiestePage({super.key});

  @override
  State<RichiestePage> createState() => _RichiestePageState();
}

class _RichiestePageState extends State<RichiestePage> {
  int _selectedFilterIndex = 0;

  final List<Map<String, dynamic>> _interventi = [
    {"id": "#SOS-2491", "data": "04/03 09:11", "stato": "PENDING"},
    {"id": "#SOS-2492", "data": "04/03 08:56", "stato": "ACCEPTED"},
    {"id": "#SOS-2488", "data": "04/03 07:11", "stato": "HANDLED"},
  ];

  List<Map<String, dynamic>> get _interventiFiltrati {
    switch (_selectedFilterIndex) {
      case 1:
        return _interventi.where((i) => i["stato"] == "PENDING").toList();
      case 2:
        return _interventi.where((i) => i["stato"] == "ACCEPTED").toList();
      case 3:
        return _interventi.where((i) => i["stato"] == "HANDLED").toList();
      case 0:
      default:
        return _interventi;
    }
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
        child: const AppDrawer(currentRoute: Routes.richieste),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gestione Richieste",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Storico e gestione operativa degli interventi in entrata.",
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey),
            ),
            const SizedBox(height: 24),

            Builder(builder: (context) {
              final isMobile = MediaQuery.of(context).size.width < 600;

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
                  ],
                ),
                width: double.infinity,
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildFilterTab(0, "Tutte", Icons.list, isMobile),
                          const SizedBox(height: 8),
                          _buildFilterTab(1, "Da Gestire", Icons.warning_amber_rounded, isMobile),
                          const SizedBox(height: 8),
                          _buildFilterTab(2, "In Corso", Icons.directions_car_filled_outlined, isMobile),
                          const SizedBox(height: 8),
                          _buildFilterTab(3, "Completate", Icons.check_circle_outline, isMobile),
                        ],
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterTab(0, "Tutte", Icons.list, isMobile),
                            _buildFilterTab(1, "Da Gestire", Icons.warning_amber_rounded, isMobile),
                            _buildFilterTab(2, "In Corso", Icons.directions_car_filled_outlined, isMobile),
                            _buildFilterTab(3, "Completate", Icons.check_circle_outline, isMobile),
                          ],
                        ),
                      ),
              );
            }),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
                ],
              ),
              child: Center(
                child: _interventiFiltrati.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text(
                          "Nessuna richiesta trovata per questo stato.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : DataTable(
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
                          DataColumn(label: Text("ID Intervento")),
                          DataColumn(label: Text("Data/Ora")),
                          DataColumn(label: Text("Azioni")),
                        ],
                        rows: _interventiFiltrati.map((intervento) {
                          return DataRow(cells: [
                            DataCell(_buildColoredId(intervento["id"], intervento["stato"], isDark)),
                            DataCell(Text(
                              intervento["data"],
                              style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
                            )),
                            DataCell(_buildActionButtons(intervento["stato"])),
                          ]);
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

  Widget _buildFilterTab(int index, String label, IconData icon, bool isMobile) {
    bool isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        margin: isMobile ? EdgeInsets.zero : const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6A7AF4) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : Colors.blueGrey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColoredId(String id, String status, bool isDark) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case "PENDING":
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        break;
      case "ACCEPTED":
        bgColor = const Color(0xFFE8EAF6);
        textColor = const Color(0xFF3F51B5);
        break;
      case "HANDLED":
        bgColor = const Color(0xFFE0F2F1);
        textColor = const Color(0xFF00796B);
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    if (isDark) bgColor = bgColor.withOpacity(0.22);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        id,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == "PENDING") ...[
          _iconButton(Icons.check, Colors.green, const Color(0xFFE8F5E9)),
          const SizedBox(width: 8),
        ],
        _iconButton(Icons.close, Colors.redAccent, const Color(0xFFFFEBEE)),
      ],
    );
  }

  Widget _iconButton(IconData icon, Color color, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

