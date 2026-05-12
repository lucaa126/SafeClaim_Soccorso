/// ESEMPIO DI INTEGRAZIONE - Non copiare direttamente, ma usare come riferimento
/// 
/// Questo file mostra come integrare i nuovi servizi API in una schermata Flutter
/// reale usando riverpod per la gestione dello stato.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontendflutter/app/backend_auth_service.dart';
import 'package:frontendflutter/app/dashboard_api_service.dart';
import 'package:frontendflutter/app/api_error_handler.dart';
import 'package:frontendflutter/models/dashboard.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PROVIDER RIVERPOD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final dashboardServiceProvider = Provider((ref) => DashboardApiService());
final backendAuthServiceProvider = Provider((ref) => BackendAuthService());

/// Provider per il sommario della dashboard
final dashboardSummaryProvider =
    FutureProvider<DashboardSummary>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return service.getDashboardSummary();
});

/// Provider per le richieste in dashboard
final dashboardRequestsProvider =
    FutureProvider<DashboardRequestsResponse>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return service.getDashboardRequests();
});

/// Provider per controllare lo stato operativo
final operationalStatusProvider = StateNotifierProvider<
    OperationalStatusNotifier,
    AsyncValue<bool>>((ref) {
  final service = ref.watch(dashboardServiceProvider);
  return OperationalStatusNotifier(service);
});

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NOTIFIER PER STATO OPERATIVO
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class OperationalStatusNotifier extends StateNotifier<AsyncValue<bool>> {
  final DashboardApiService _service;

  OperationalStatusNotifier(this._service)
      : super(AsyncValue.data(false)); // Valore di default

  Future<void> toggleStatus(bool newStatus) async {
    state = const AsyncValue.loading();
    try {
      final summary = await _service.updateOperationalStatus(newStatus);
      state = AsyncValue.data(summary.operativoOnline);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SCHERMATA DASHBOARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Guarda il sommario della dashboard
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final requestsAsync = ref.watch(dashboardRequestsProvider);
    final statusAsync = ref.watch(operationalStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Soccorso'),
        elevation: 0,
        actions: [
          // Pulsante di refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Invalida i provider per forzare il ricaricamento
              ref.refresh(dashboardSummaryProvider);
              ref.refresh(dashboardRequestsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Ricarica i dati quando fai swipe down
          ref.refresh(dashboardSummaryProvider);
          ref.refresh(dashboardRequestsProvider);
          await ref.read(dashboardSummaryProvider.future);
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // SEZIONE 1: SOMMARIO
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                summaryAsync.when(
                  data: (summary) => _buildSummarySection(
                    context,
                    ref,
                    summary,
                    statusAsync,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, st) => _buildErrorWidget(
                    context,
                    error as Exception,
                    () => ref.refresh(dashboardSummaryProvider),
                  ),
                ),

                const SizedBox(height: 24),

                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // SEZIONE 2: RICHIESTE
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                requestsAsync.when(
                  data: (response) => _buildRequestsSection(context, response),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, st) => _buildErrorWidget(
                    context,
                    error as Exception,
                    () => ref.refresh(dashboardRequestsProvider),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // UI BUILDER: SOMMARIO
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildSummarySection(
    BuildContext context,
    WidgetRef ref,
    DashboardSummary summary,
    AsyncValue<bool> statusAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titolo con nome officina
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.workshopName,
                  style: Theme.of(context).textTheme.headline5?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Stato operativo',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            // Toggle stato operativo
            statusAsync.when(
              data: (isOnline) => Switch(
                value: isOnline,
                onChanged: (newValue) {
                  ref
                      .read(operationalStatusProvider.notifier)
                      .toggleStatus(newValue);
                },
              ),
              loading: () => const SizedBox(
                width: 60,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, st) => IconButton(
                icon: const Icon(Icons.error),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore: $error')),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // KPI Cards
        _buildKpiCards(context, summary.kpi),
      ],
    );
  }

  Widget _buildKpiCards(BuildContext context, KpiData kpi) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        _buildKpiCard(
          context,
          icon: Icons.assignment,
          label: 'Attive',
          value: '${kpi.richiesteAttive}',
          color: Colors.blue,
        ),
        _buildKpiCard(
          context,
          icon: Icons.check_circle,
          label: 'Completate',
          value: '${kpi.completatiOggi}',
          color: Colors.green,
        ),
        _buildKpiCard(
          context,
          icon: Icons.schedule,
          label: 'Tempo medio',
          value: '${kpi.tempoMedioMinuti} m',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, color: color, size: 28),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // UI BUILDER: RICHIESTE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildRequestsSection(
    BuildContext context,
    DashboardRequestsResponse response,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Richieste in attesa (${response.count})',
          style: Theme.of(context).textTheme.headline6?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (response.data.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Nessuna richiesta in attesa',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final request = response.data[index];
              return _buildRequestCard(context, request);
            },
          ),
      ],
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    DashboardRequest request,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.id,
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        request.cliente,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.directions_car, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  request.vehicleLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    request.posizione,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: request.availableActions
                  .map((action) => _buildActionButton(context, action))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String action) {
    final isPositive = action == 'take_in_charge' || action == 'complete';
    final isNegative = action == 'reject';

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isNegative
            ? Colors.red
            : isPositive
                ? Colors.green
                : Colors.blue,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Azione: $action')),
        );
        // TODO: Implementa logica per presa in carico, rifiuto, completamento
      },
      child: Text(_formatActionLabel(action)),
    );
  }

  String _formatActionLabel(String action) {
    switch (action) {
      case 'take_in_charge':
        return 'Prendi in carico';
      case 'reject':
        return 'Rifiuta';
      case 'complete':
        return 'Completa';
      default:
        return action;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'handled':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BUILDER: ERROR WIDGET
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildErrorWidget(
    BuildContext context,
    Exception error,
    VoidCallback onRetry,
  ) {
    final apiError = ApiErrorHandler.parseError(error);

    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'Errore',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              apiError.getUserMessage(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Riprova'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
