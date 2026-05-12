import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/safeclaim_ui.dart';

// Modello per i veicoli (simile a Angular)
class Vehicle {
  final String id;
  final String name;
  final String plate;
  final String status; // 'available', 'busy', 'maintenance'
  final String driver;
  final double lat;
  final double lng;
  final String? currentTask;

  Vehicle({
    required this.id,
    required this.name,
    required this.plate,
    required this.status,
    required this.driver,
    required this.lat,
    required this.lng,
    this.currentTask,
  });
}

class FlottaPage extends StatefulWidget {
  const FlottaPage({super.key});

  @override
  State<FlottaPage> createState() => _FlottaPageState();
}

class _FlottaPageState extends State<FlottaPage> {
  // Dati finti iniziali (Mock) - identici a Angular
  late List<Vehicle> fleet = [
    Vehicle(
      id: 'V-01',
      name: 'Carroattrezzi A (Pianale)',
      plate: 'GA 123 AB',
      status: 'available',
      driver: 'Mario Rossi',
      lat: 45.4600,
      lng: 9.1800,
    ),
    Vehicle(
      id: 'V-02',
      name: 'Carroattrezzi B (Gru)',
      plate: 'FF 987 KK',
      status: 'busy',
      driver: 'Luca Bianchi',
      lat: 45.4780,
      lng: 9.1240,
      currentTask: 'SOS-2492',
    ),
    Vehicle(
      id: 'V-03',
      name: 'Furgone Officina',
      plate: 'DZ 456 YY',
      status: 'maintenance',
      driver: 'Giuseppe Verdi',
      lat: 45.4500,
      lng: 9.1500,
    ),
  ];

  void contactDriver(String driverName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chiamata in corso a: $driverName...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'available':
        return 'Disponibile';
      case 'busy':
        return 'In Intervento';
      case 'maintenance':
        return 'In Manutenzione';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'available':
        return SafeClaimColors.textStrong;
      case 'busy':
        return SafeClaimColors.primaryDark;
      case 'maintenance':
        return SafeClaimColors.textMuted;
      default:
        return SafeClaimColors.primary;
    }
  }

  Color getStatusBgColor(String status) {
    switch (status) {
      case 'available':
        return SafeClaimColors.textStrong.withValues(alpha: 0.10);
      case 'busy':
        return SafeClaimColors.primaryLight.withValues(alpha: 0.22);
      case 'maintenance':
        return SafeClaimColors.neutral;
      default:
        return SafeClaimColors.primaryLightest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = safeClaimCardColor(isDark);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flotta',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
        actions: [
          buildSharedThemeToggle(context, isDark),
          const SizedBox(width: 16),
        ],
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const AppDrawer(currentRoute: Routes.flotta),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Gestione Flotta',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : SafeClaimColors.foreground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Monitoraggio in tempo reale stato mezzi e autisti.',
              style: TextStyle(
                fontSize: 14,
                color: safeClaimSubtleTextColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Grid di carte veicoli
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 1.3,
                mainAxisSpacing: 16,
              ),
              itemCount: fleet.length,
              itemBuilder: (context, index) {
                final vehicle = fleet[index];
                return _buildFleetCard(vehicle, isDark, cardColor);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFleetCard(Vehicle vehicle, bool isDark, Color cardColor) {
    final statusColor = getStatusColor(vehicle.status);
    final statusBgColor = getStatusBgColor(vehicle.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: safeClaimCardDecoration(isDark, color: cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icona e badge stato
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  color: statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? Colors.white
                            : SafeClaimColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Targa: ${vehicle.plate}',
                      style: TextStyle(
                        fontSize: 12,
                        color: safeClaimSubtleTextColor(isDark),
                        fontWeight: FontWeight.w600,
                      ),
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
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  getStatusLabel(vehicle.status),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Dettagli
          Column(
            children: [
              _buildDetailRow(
                isDark,
                Icons.person_outline,
                'Autista',
                vehicle.driver,
              ),
              const SizedBox(height: 12),
              if (vehicle.status == 'busy') ...[
                _buildDetailRow(
                  isDark,
                  Icons.warning_amber_outlined,
                  'In intervento su',
                  vehicle.currentTask ?? 'N/A',
                ),
                const SizedBox(height: 12),
              ],
              _buildDetailRow(
                isDark,
                Icons.location_on_outlined,
                'Posizione',
                '${vehicle.lat.toStringAsFixed(4)}, ${vehicle.lng.toStringAsFixed(4)}',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bottone Contatta
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: vehicle.status == 'maintenance'
                  ? null
                  : () => contactDriver(vehicle.driver),
              icon: const Icon(Icons.call, size: 18),
              label: const Text('Contatta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SafeClaimColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    bool isDark,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: safeClaimSubtleTextColor(isDark)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: safeClaimSubtleTextColor(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : SafeClaimColors.foreground,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
