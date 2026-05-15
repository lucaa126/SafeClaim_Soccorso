import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/safeclaim_ui.dart';
import 'analytics_api_service.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  final AnalyticsApiService _analyticsApi = AnalyticsApiService();

  // ===== VARIABILI DI STATO =====
  int total = 0;
  int pending = 0;
  int accepted = 0;
  int handled = 0;
  List<int> last7Days = [];
  Map<String, int> fleetStatus = {};
  int averageHandlingMins = 0;

  bool loadingAnalytics = true;

  String selectedCategory = 'overview';
  late TabController _tabController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      setState(() {
        loadingAnalytics = true;
        _errorMessage = null;
      });

      final summary = await _analyticsApi.getAnalyticsSummary();

      if (!mounted) {
        return;
      }

      setState(() {
        total = summary.total;
        pending = summary.pending;
        accepted = summary.accepted;
        handled = summary.handled;
        last7Days = summary.last7Days;
        fleetStatus = summary.fleetStatus;
        averageHandlingMins = summary.averageHandlingMins;
        loadingAnalytics = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        loadingAnalytics = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      _showSnack(_errorMessage ?? 'Errore caricamento dati analytics');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _refreshData() {
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: isDarkMode
          ? SafeClaimColors.darkBackground
          : SafeClaimColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode
            ? SafeClaimColors.darkSurface
            : SafeClaimColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Analytics',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Aggiorna dati',
          ),
        ],
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const AppDrawer(currentRoute: Routes.analytics),
      ),
      body: loadingAnalytics
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      SafeClaimColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Caricamento dati analytics...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    _buildHeader(),
                    const SizedBox(height: 20),

                    // SUMMARY CARDS (4 card responsive)
                    _buildSummaryCards(isMobile),
                    const SizedBox(height: 24),

                    // TAB NAVIGATION
                    _buildTabNavigation(),
                    const SizedBox(height: 16),

                    // CONTENUTO DINAMICO BASE CATEGORIA
                    _buildCategoryContent(),
                  ],
                ),
              ),
            ),
    );
  }

  // ===== HEADER SECTION =====
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Panoramica e metriche operative',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: safeClaimSubtleTextColor(
              Theme.of(context).brightness == Brightness.dark,
            ),
          ),
        ),
      ],
    );
  }

  // ===== SUMMARY CARDS GRID =====
  Widget _buildSummaryCards(bool isMobile) {
    final cards = [
      {
        'label': 'Richieste totali',
        'value': total.toString(),
        'color': SafeClaimColors.primary,
        'icon': Icons.assignment_ind,
      },
      {
        'label': 'In attesa',
        'value': pending.toString(),
        'color': SafeClaimColors.textMuted,
        'icon': Icons.schedule,
      },
      {
        'label': 'In corso',
        'value': accepted.toString(),
        'color': SafeClaimColors.primaryDark,
        'icon': Icons.directions_run,
      },
      {
        'label': 'Completate',
        'value': handled.toString(),
        'color': SafeClaimColors.textStrong,
        'icon': Icons.check_circle,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return _analyticsCard(
          label: card['label'] as String,
          value: card['value'] as String,
          color: card['color'] as Color,
          icon: card['icon'] as IconData,
          isSelected: selectedCategory == card['label'],
          onTap: () {
            setState(() {
              selectedCategory = card['label'] as String;
              _tabController.animateTo(index == 0 ? 0 : index);
            });
          },
        );
      },
    );
  }

  // ===== ANALYTICS CARD WIDGET =====
  Widget _analyticsCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? SafeClaimColors.darkCard
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : SafeClaimColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                ],
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== TAB NAVIGATION =====
  Widget _buildTabNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? SafeClaimColors.darkCard
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            final newCategories = [
              'overview',
              'requests',
              'operations',
              'fleet',
            ];
            selectedCategory = newCategories[index];
          });
        },
        labelColor: SafeClaimColors.primary,
        unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white70
            : SafeClaimColors.textMuted,
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(
            color: SafeClaimColors.primary,
            width: 3,
          ),
          insets: const EdgeInsets.symmetric(horizontal: 0),
        ),
        tabs: const [
          Tab(text: 'Panoramica'),
          Tab(text: 'Richieste'),
          Tab(text: 'Operazioni'),
          Tab(text: 'Flotta'),
        ],
      ),
    );
  }

  // ===== CONTENUTO DINAMICO =====
  Widget _buildCategoryContent() {
    switch (selectedCategory) {
      case 'requests':
        return _buildRequestsSection();
      case 'operations':
        return _buildOperationsSection();
      case 'fleet':
        return _buildFleetSection();
      default:
        return _buildOverviewSection();
    }
  }

  // ===== OVERVIEW SECTION (PANORAMICA) =====
  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequestsChart(),
        const SizedBox(height: 20),
        _buildOperationsCard(),
        const SizedBox(height: 20),
        _buildFleetCard(),
      ],
    );
  }

  // ===== REQUESTS SECTION =====
  Widget _buildRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequestsChart(),
        const SizedBox(height: 20),
        Text(
          'Statistiche Richieste',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildStatCard('Totale', total, SafeClaimColors.primary),
        const SizedBox(height: 8),
        _buildStatCard('In attesa', pending, SafeClaimColors.textMuted),
        const SizedBox(height: 8),
        _buildStatCard('In corso', accepted, SafeClaimColors.primaryDark),
        const SizedBox(height: 8),
        _buildStatCard('Completate', handled, SafeClaimColors.textStrong),
      ],
    );
  }

  // ===== REQUESTS CHART =====
  Widget _buildRequestsChart() {
    final max = last7Days.isEmpty
        ? 1
        : last7Days.reduce((a, b) => a > b ? a : b);
    final safeMax = max == 0 ? 1 : max;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? SafeClaimColors.darkCard
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Richieste ultimi 7 giorni',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: last7Days.isEmpty
                ? Center(
                    child: Text(
                      'Nessun dato disponibile',
                      style: TextStyle(
                        color: safeClaimSubtleTextColor(
                          Theme.of(context).brightness == Brightness.dark,
                        ),
                      ),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(last7Days.length, (index) {
                      final value = last7Days[index];
                      final height = (value / safeMax) * 120;
                      final isToday = index == last7Days.length - 1;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Tooltip(
                            message: '$value richieste',
                            child: Container(
                              width: 30,
                              height: height,
                              decoration: BoxDecoration(
                                color: SafeClaimColors.primary,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: SafeClaimColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isToday ? 'oggi' : 'g${last7Days.length - 1 - index}',
                            style: TextStyle(
                              fontSize: 11,
                              color: safeClaimSubtleTextColor(
                                Theme.of(context).brightness == Brightness.dark,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }

  // ===== OPERATIONS SECTION =====
  Widget _buildOperationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOperationsCard(),
        const SizedBox(height: 20),
        Text(
          'Dettagli Operazioni',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildStatusBar('In attesa', pending, total, SafeClaimColors.textMuted),
        const SizedBox(height: 12),
        _buildStatusBar(
          'In corso',
          accepted,
          total,
          SafeClaimColors.primaryDark,
        ),
        const SizedBox(height: 12),
        _buildStatusBar(
          'Completate',
          handled,
          total,
          SafeClaimColors.textStrong,
        ),
      ],
    );
  }

  // ===== OPERATIONS CARD =====
  Widget _buildOperationsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? SafeClaimColors.darkCard
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stato operazioni',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStatusBar(
            'In attesa',
            pending,
            total,
            SafeClaimColors.textMuted,
          ),
          const SizedBox(height: 12),
          _buildStatusBar(
            'In corso',
            accepted,
            total,
            SafeClaimColors.primaryDark,
          ),
          const SizedBox(height: 12),
          _buildStatusBar(
            'Completate',
            handled,
            total,
            SafeClaimColors.textStrong,
          ),
          const Divider(height: 24),
          Text(
            'Tempo medio gestione:',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            '$averageHandlingMins minuti',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: SafeClaimColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ===== STATUS BAR WIDGET =====
  Widget _buildStatusBar(String label, int value, int total, Color color) {
    final percentage = total == 0 ? 0.0 : (value / total) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '$value (${percentage.toStringAsFixed(1)}%)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 28,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.14)
                : SafeClaimColors.primaryLightest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ===== FLEET SECTION =====
  Widget _buildFleetSection() {
    return _buildFleetCard();
  }

  // ===== FLEET CARD =====
  Widget _buildFleetCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? SafeClaimColors.darkCard
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stato flotta',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (fleetStatus.isEmpty)
            Text(
              'Nessun dato di flotta disponibile',
              style: TextStyle(
                color: safeClaimSubtleTextColor(
                  Theme.of(context).brightness == Brightness.dark,
                ),
              ),
            )
          else
            ...fleetStatus.entries.map((entry) {
              final colors = {
                'available': SafeClaimColors.textStrong,
                'busy': SafeClaimColors.primaryDark,
                'maintenance': SafeClaimColors.textMuted,
              };
              final labels = {
                'available': 'Disponibili',
                'busy': 'Impegnati',
                'maintenance': 'Manutenzione',
              };

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[entry.key],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          labels[entry.key] ?? entry.key,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Text(
                      entry.value.toString(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ===== STAT CARD =====
  Widget _buildStatCard(String label, int value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? SafeClaimColors.darkCard
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: safeClaimSubtleTextColor(
                    Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.trending_up, color: color, size: 24),
          ),
        ],
      ),
    );
  }
}
