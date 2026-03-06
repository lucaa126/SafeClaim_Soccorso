import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../widgets/app_drawer.dart';
import 'analytics_service.dart';
import '../dashboard/dashboard_page.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  final AnalyticsService service = AnalyticsService();

  // ===== VARIABILI DI STATO =====
  late int total;
  late int pending;
  late int accepted;
  late int handled;
  late List<int> last7Days;
  late Map<String, int> fleetStatus;
  late int averageHandlingMins;

  List<TrafficIncident> traffic = [];
  bool loadingTraffic = false;

  String selectedCategory = 'overview';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 4, vsync: this, initialIndex: 0);
    _loadAllData();
    _loadTraffic();
  }

  void _loadAllData() {
    setState(() {
      total = service.getTotalRequests();
      pending = service.getPending();
      accepted = service.getAccepted();
      handled = service.getHandled();
      last7Days = service.getRequestsOverLastDays(7);
      fleetStatus = service.getFleetStatusCounts();
      averageHandlingMins = service.getAverageHandlingTimeMinutes();
    });
  }

  Future<void> _loadTraffic() async {
    setState(() => loadingTraffic = true);
    try {
      traffic = await service.getRealTimeTraffic('Milano');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore caricamento traffico: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => loadingTraffic = false);
    }
  }

  void _refreshData() {
    _loadAllData();
    _loadTraffic();
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
      backgroundColor: isDarkMode ? const Color(0xFF1c1d1f) : const Color(0xFFdcdcdf),
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            isDarkMode ? const Color(0xFF0d1117) : Colors.white,
        foregroundColor:
            isDarkMode ? Colors.white : const Color(0xFF363949),
        title: const Text(
          'Analytics',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          buildSharedThemeToggle(context, isDarkMode),
          const SizedBox(width: 16),
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
      body: SingleChildScrollView(
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
                color: Colors.grey,
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
        'color': const Color(0xFF7380ec),
        'icon': Icons.assignment_ind,
      },
      {
        'label': 'In attesa',
        'value': pending.toString(),
        'color': const Color(0xFFffbb55),
        'icon': Icons.schedule,
      },
      {
        'label': 'In corso',
        'value': accepted.toString(),
        'color': const Color(0xFF7380ec),
        'icon': Icons.directions_run,
      },
      {
        'label': 'Completate',
        'value': handled.toString(),
        'color': const Color(0xFF41f1b6),
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
              _tabController
                  .animateTo(index == 0 ? 0 : index);
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
              ? const Color(0xFF0d1117)
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
            color: isSelected ? color.withValues(alpha: 0.5) : Colors.transparent,
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
                        color: Colors.grey.shade600,
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
                    child: Icon(
                      icon,
                      size: 16,
                      color: color,
                    ),
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
            ? const Color(0xFF0d1117)
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
        labelColor: const Color(0xFF7380ec),
        unselectedLabelColor: Colors.grey,
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(
            color: Color(0xFF7380ec),
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
        const SizedBox(height: 20),
        _buildTrafficCard(),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildStatCard('Totale', total, const Color(0xFF7380ec)),
        const SizedBox(height: 8),
        _buildStatCard('In attesa', pending, const Color(0xFFffbb55)),
        const SizedBox(height: 8),
        _buildStatCard('In corso', accepted, const Color(0xFF7380ec)),
        const SizedBox(height: 8),
        _buildStatCard('Completate', handled, const Color(0xFF41f1b6)),
      ],
    );
  }

  // ===== REQUESTS CHART =====
  Widget _buildRequestsChart() {
    final max = service.getMaxRequestsValue();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0d1117)
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(last7Days.length, (index) {
                final value = last7Days[index];
                final height = (value / max) * 120;
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
                          color: const Color(0xFF7380ec),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7380ec)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isToday ? 'oggi' : 'g${6 - index}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildStatusBar('In attesa', pending, total, const Color(0xFFffbb55)),
        const SizedBox(height: 12),
        _buildStatusBar('In corso', accepted, total, const Color(0xFF7380ec)),
        const SizedBox(height: 12),
        _buildStatusBar(
          'Completate',
          handled,
          total,
          const Color(0xFF41f1b6),
        ),
      ],
    );
  }

  // ===== OPERATIONS CARD =====
  Widget _buildOperationsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0d1117)
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildStatusBar('In attesa', pending, total, const Color(0xFFffbb55)),
          const SizedBox(height: 12),
          _buildStatusBar('In corso', accepted, total, const Color(0xFF7380ec)),
          const SizedBox(height: 12),
          _buildStatusBar(
            'Completate',
            handled,
            total,
            const Color(0xFF41f1b6),
          ),
          const Divider(height: 24),
          Text(
            'Tempo medio gestione:',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            '${service.getAverageHandlingTimeMinutes()} minuti',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7380ec),
                ),
          ),
        ],
      ),
    );
  }

  // ===== STATUS BAR WIDGET =====
  Widget _buildStatusBar(
    String label,
    int value,
    int total,
    Color color,
  ) {
    final percentage = service.getPercentage(value, total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
            backgroundColor: Colors.grey.shade300,
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
            ? const Color(0xFF0d1117)
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...fleetStatus.entries.map((entry) {
            final colors = {
              'available': const Color(0xFF41f1b6),
              'busy': const Color(0xFF7380ec),
              'maintenance': const Color(0xFFffbb55),
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
                        style:
                            Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Text(
                    entry.value.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }



  // ===== TRAFFIC CARD =====
  Widget _buildTrafficCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0d1117)
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Traffico Live',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                onPressed: _loadTraffic,
                icon: loadingTraffic
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF7380ec),
                          ),
                        ),
                      )
                    : const Icon(Icons.refresh),
                tooltip: 'Aggiorna',
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (loadingTraffic && traffic.isEmpty)
            _buildLoadingState()
          else if (!loadingTraffic && traffic.isEmpty)
            _buildEmptyState()
          else
            _buildTrafficList(),
        ],
      ),
    );
  }

  // ===== TRAFFIC LOADING STATE =====
  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF7380ec),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ricerca notizie in corso...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== TRAFFIC EMPTY STATE =====
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF41f1b6).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF41f1b6),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Nessuna criticità rilevata.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== TRAFFIC LIST =====
  Widget _buildTrafficList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: traffic.length,
      separatorBuilder: (context, index) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final incident = traffic[index];
        return _buildTrafficItem(incident);
      },
    );
  }

  // ===== TRAFFIC ITEM =====
  Widget _buildTrafficItem(TrafficIncident incident) {
    final isDanger = incident.title.toLowerCase().contains('incidente');
    final isWarning = incident.title.toLowerCase().contains('coda') ||
        incident.title.toLowerCase().contains('code');

    Color iconBgColor;
    IconData icon;

    if (isDanger) {
      iconBgColor = const Color(0xFFff7782);
      icon = Icons.car_crash;
    } else if (isWarning) {
      iconBgColor = const Color(0xFFffbb55);
      icon = Icons.traffic;
    } else {
      iconBgColor = const Color(0xFF7380ec);
      icon = Icons.info;
    }

    return GestureDetector(
      onTap: () {
        // Potrebbe aprire link in future
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: iconBgColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: iconBgColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconBgColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            incident.source,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: const Color(0xFF7380ec),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            _formatTime(incident.pubDate),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== STAT CARD =====
  Widget _buildStatCard(String label, int value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0d1117)
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
                      color: Colors.grey,
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
            child: Icon(
              Icons.trending_up,
              color: color,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // ===== UTILITY FUNCTIONS =====
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
