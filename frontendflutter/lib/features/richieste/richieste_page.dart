import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../widgets/app_drawer.dart';
import '../dashboard/dashboard_page.dart';

import 'richiesta_model.dart';
import 'richieste_api_service.dart';

class RichiestePage extends StatefulWidget {
  const RichiestePage({super.key});

  @override
  State<RichiestePage> createState() => _RichiestePageState();
}

class _RichiestePageState extends State<RichiestePage> {
  final RichiesteApiService _apiService = RichiesteApiService();
  
  int _selectedFilterIndex = 0;
  List<RichiestaIntervento> _interventi = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDati();
  }

  Future<void> _fetchDati() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Ora il metodo combacia con il servizio
      final dati = await _apiService.fetchRichieste();
      if (mounted) {
        setState(() {
          _interventi = dati;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().contains("Exception:") 
              ? e.toString().replaceFirst("Exception: ", "") 
              : "Errore di connessione al server.";
        });
      }
    }
  }

  List<RichiestaIntervento> get _interventiFiltrati {
    switch (_selectedFilterIndex) {
      case 1: return _interventi.where((i) => i.stato == "PENDING").toList();
      case 2: return _interventi.where((i) => i.stato == "ACCEPTED").toList();
      case 3: return _interventi.where((i) => i.stato == "HANDLED").toList();
      default: return _interventi;
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
      body: RefreshIndicator(
        onRefresh: _fetchDati,
        color: const Color(0xFF6A7AF4),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Gestione Richieste",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Storico e gestione operativa degli interventi in entrata.",
                style: TextStyle(
                  fontSize: 15, 
                  color: isDark ? Colors.white70 : Colors.blueGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              _buildFilterSection(isDark, cardColor),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(60.0), child: CircularProgressIndicator()))
              else if (_errorMessage != null)
                _buildErrorState()
              else
                _buildTableContainer(cardColor, isDark),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- I restanti metodi helper (_buildFilterSection, _filterTab, _buildTableContainer, ecc.) 
  // rimangono identici a quelli del tuo file originale, 
  // assicurati solo di copiarli integralmente. ---
  
  Widget _buildFilterSection(bool isDark, Color cardColor) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: isMobile 
        ? Column(children: _getFilterButtons(true))
        : SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _getFilterButtons(false))),
    );
  }

  List<Widget> _getFilterButtons(bool isMobile) {
    return [
      _filterTab(0, "Tutte", Icons.list, isMobile),
      _filterTab(1, "Da Gestire", Icons.warning_amber_rounded, isMobile),
      _filterTab(2, "In Corso", Icons.directions_car_filled_outlined, isMobile),
      _filterTab(3, "Completate", Icons.check_circle_outline, isMobile),
    ];
  }

  Widget _filterTab(int index, String label, IconData icon, bool isMobile) {
    bool isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6A7AF4) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.blueGrey),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.blueGrey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableContainer(Color cardColor, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: _interventiFiltrati.isEmpty
          ? const Padding(padding: EdgeInsets.all(60.0), child: Center(child: Text("Nessuna richiesta trovata.")))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87),
                dataRowMaxHeight: 75,
                dataRowMinHeight: 75,
                columns: const [
                  DataColumn(label: Text("ID INTERVENTO")),
                  DataColumn(label: Text("DATA E ORA")),
                  DataColumn(label: Text("AZIONI")),
                ],
                rows: _interventiFiltrati.map((item) {
                  return DataRow(cells: [
                    DataCell(_buildColoredId("#SOS-${item.id}", item.stato, isDark)),
                    DataCell(Text(DateFormat('dd/MM HH:mm').format(item.dataRichiesta), style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black54))),
                    DataCell(_buildActionButtons(item.stato)),
                  ]);
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildColoredId(String id, String status, bool isDark) {
    Color bgColor; Color textColor;
    switch (status) {
      case "PENDING": bgColor = const Color(0xFFFFF3E0); textColor = const Color(0xFFE65100); break;
      case "ACCEPTED": bgColor = const Color(0xFFE8EAF6); textColor = const Color(0xFF3F51B5); break;
      case "HANDLED": bgColor = const Color(0xFFE0F2F1); textColor = const Color(0xFF00796B); break;
      default: bgColor = Colors.grey.shade200; textColor = Colors.grey.shade800;
    }
    if (isDark) bgColor = bgColor.withOpacity(0.15);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Text(id, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13)),
    );
  }

  Widget _buildActionButtons(String status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == "PENDING") ...[_iconButton(Icons.check, Colors.green), const SizedBox(width: 8)],
        _iconButton(Icons.visibility_outlined, Colors.blueAccent),
        const SizedBox(width: 8),
        _iconButton(Icons.close, Colors.redAccent),
      ],
    );
  }

  Widget _iconButton(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.3))),
      child: IconButton(
        icon: Icon(icon, size: 18, color: color),
        onPressed: () {},
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(onPressed: _fetchDati, child: const Text("Riprova")),
        ],
      ),
    );
  }
}