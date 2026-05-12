import 'package:flutter/material.dart';

import '../../app/auth_service.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/safeclaim_ui.dart';

import 'richiesta_model.dart';
import 'richieste_api_service.dart';

class RichiestePage extends StatefulWidget {
  const RichiestePage({super.key});

  @override
  State<RichiestePage> createState() => _RichiestePageState();
}

class _RichiestePageState extends State<RichiestePage> {
  static const _filterLabels = ["Tutte", "Da Gestire", "In Corso", "Completate"];
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
      final dati = await _apiService.fetchRichieste(
        stato: _filterLabels[_selectedFilterIndex],
      );
      if (mounted) {
        setState(() {
          _interventi = dati;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      if (e is TokenInvalidException) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().contains("Exception:")
            ? e.toString().replaceFirst("Exception: ", "")
            : "Errore di connessione al server.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = safeClaimCardColor(isDark);

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
        color: SafeClaimColors.primary,
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
                  color: isDark ? Colors.white : SafeClaimColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Storico e gestione operativa degli interventi in entrata.",
                style: TextStyle(
                  fontSize: 15,
                  color: safeClaimSubtleTextColor(isDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              _buildFilterSection(isDark, cardColor),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(60.0),
                    child: CircularProgressIndicator(),
                  ),
                )
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
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
            ),
        ],
      ),
      child: isMobile
          ? Column(children: _getFilterButtons(true))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _getFilterButtons(false)),
            ),
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
      onTap: () {
        setState(() => _selectedFilterIndex = index);
        _fetchDati();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? SafeClaimColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? SafeClaimColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: isMobile
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : SafeClaimColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : SafeClaimColors.textMuted,
              ),
            ),
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
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
            ),
        ],
      ),
      child: _interventi.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(60.0),
              child: Center(child: Text("Nessuna richiesta trovata.")),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : SafeClaimColors.foreground,
                ),
                dataRowMaxHeight: 75,
                dataRowMinHeight: 75,
                columns: const [
                  DataColumn(label: Text("ID INTERVENTO")),
                  DataColumn(label: Text("DATA E ORA")),
                  DataColumn(label: Text("AZIONI")),
                ],
                rows: _interventi.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(
                        _buildColoredId("#SOS-${item.id}", item.stato, isDark),
                      ),
                      DataCell(
                        Text(
                          _formatShortDateTime(item.dataRichiesta),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white70
                                : SafeClaimColors.textMuted,
                          ),
                        ),
                      ),
                      DataCell(_buildActionButtons(item.stato)),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildColoredId(String id, String status, bool isDark) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case "PENDING":
        bgColor = SafeClaimColors.primaryLightest;
        textColor = SafeClaimColors.textStrong;
        break;
      case "ACCEPTED":
        bgColor = SafeClaimColors.primaryLight.withValues(alpha: 0.22);
        textColor = SafeClaimColors.primaryDark;
        break;
      case "HANDLED":
        bgColor = SafeClaimColors.textStrong.withValues(alpha: 0.10);
        textColor = SafeClaimColors.textStrong;
        break;
      default:
        bgColor = SafeClaimColors.neutral;
        textColor = SafeClaimColors.textStrong;
    }
    if (isDark) bgColor = bgColor.withValues(alpha: 0.18);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.45)),
      ),
      child: Text(
        id,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == "PENDING") ...[
          _iconButton(Icons.check, SafeClaimColors.primary),
          const SizedBox(width: 8),
        ],
        _iconButton(Icons.visibility_outlined, SafeClaimColors.textStrong),
        const SizedBox(width: 8),
        _iconButton(Icons.close, SafeClaimColors.danger),
      ],
    );
  }

  Widget _iconButton(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
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
          const Icon(
            Icons.error_outline,
            color: SafeClaimColors.danger,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _fetchDati, child: const Text("Riprova")),
        ],
      ),
    );
  }

  String _formatShortDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}
