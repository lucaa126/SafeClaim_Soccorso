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
  static const _filterLabels = [
    "Tutte",
    "Da Gestire",
    "In Corso",
    "Completate",
  ];
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
      appBar: AppBar(),
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
                _buildCardsContainer(cardColor, isDark),
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

  Widget _buildCardsContainer(Color cardColor, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          : Column(
              children: _interventi.map((item) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: item == _interventi.last ? 0 : 12,
                  ),
                  child: _buildInterventoCard(item, isDark),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildInterventoCard(RichiestaIntervento item, bool isDark) {
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : SafeClaimColors.primaryLight.withValues(alpha: 0.45);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? SafeClaimColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
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
                      color: SafeClaimColors.primary.withValues(alpha: 0.14),
                    ),
                    child: const Icon(
                      Icons.assignment_rounded,
                      color: SafeClaimColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "#SOS-${item.id}",
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
                          _formatFullDateTime(item.dataRichiesta),
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
                        status: item.stato,
                        maxWidth: pillMaxWidth,
                      ),
                      _metaPill(
                        isDark: isDark,
                        icon: Icons.tag_rounded,
                        label: "#SOS-${item.id}",
                        maxWidth: pillMaxWidth,
                      ),
                      if (item.orarioArrivo != null)
                        _metaPill(
                          isDark: isDark,
                          icon: Icons.flag_circle_rounded,
                          label:
                              'Arrivo ${_formatShortDateTime(item.orarioArrivo!)}',
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
              _buildActionButtons(item.stato, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(String status, bool isDark) {
    final normalizedStatus = _normalizedStatus(status);
    final hasPrimaryAction = normalizedStatus == "PENDING";

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _actionButton(
          isDark: isDark,
          icon: Icons.visibility_rounded,
          label: 'Dettaglio',
          color: isDark ? Colors.white70 : SafeClaimColors.textStrong,
          onPressed: () {},
        ),
        if (normalizedStatus == "PENDING")
          _actionButton(
            isDark: isDark,
            icon: Icons.check,
            label: 'Prendi in carico',
            color: SafeClaimColors.primary,
            onPressed: () {},
          ),
        if (normalizedStatus == "ACCEPTED")
          _actionButton(
            isDark: isDark,
            icon: Icons.done_all_rounded,
            label: 'Completa',
            color: SafeClaimColors.textStrong,
            onPressed: () {},
          ),
        if (hasPrimaryAction)
          _actionButton(
            isDark: isDark,
            icon: Icons.close,
            label: 'Rifiuta',
            color: Colors.redAccent,
            onPressed: () {},
          ),
        if (normalizedStatus == "HANDLED")
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
    );
  }

  String _normalizedStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'pending':
      case 'in_attesa':
      case 'da_gestire':
        return 'PENDING';
      case 'accepted':
      case 'in_corso':
        return 'ACCEPTED';
      case 'handled':
      case 'completata':
        return 'HANDLED';
      default:
        return status.toUpperCase();
    }
  }

  Widget _statusChip({
    required bool isDark,
    required String status,
    double? maxWidth,
  }) {
    final style = safeClaimStatusStyle(status);
    final bg = isDark
        ? style.background.withValues(alpha: 0.22)
        : style.background;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: style.foreground.withValues(alpha: 0.45)),
        ),
        child: Text(
          style.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: style.foreground,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _metaPill({
    required bool isDark,
    required IconData icon,
    required String label,
    double? maxWidth,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? SafeClaimColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : SafeClaimColors.primaryLight.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: SafeClaimColors.primary),
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

  String _formatFullDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year alle $hour:$minute';
  }
}
