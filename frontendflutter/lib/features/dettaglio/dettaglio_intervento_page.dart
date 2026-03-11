import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/routes.dart';
import '../../widgets/app_drawer.dart';
import '../dashboard/dashboard_page.dart';

class DettaglioArgs {
  final String id;
  final String cliente;
  final double lat;
  final double lng;

  const DettaglioArgs({
    required this.id,
    required this.cliente,
    this.lat = 45.4642,
    this.lng = 9.1900,
  });
}

class DettaglioInterventoPage extends StatefulWidget {
  final DettaglioArgs args;
  const DettaglioInterventoPage({super.key, required this.args});

  @override
  State<DettaglioInterventoPage> createState() =>
      _DettaglioInterventoPageState();
}

class _DettaglioInterventoPageState extends State<DettaglioInterventoPage> {
  late final MapController _mapController;
  late double _zoom;

  LatLng get _interventoPoint => LatLng(widget.args.lat, widget.args.lng);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _zoom = 13;
  }

  Future<void> _setZoom(double zoom) async {
    final nextZoom = zoom.clamp(5.0, 18.0);
    setState(() => _zoom = nextZoom);
    _mapController.move(_interventoPoint, nextZoom);
  }

  Future<void> _openNavigation() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${widget.args.lat},${widget.args.lng}&travelmode=driving',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aprire Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dettaglio Intervento",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        centerTitle: false,
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
            _card(
              isDark: isDark,
              color: cardColor,
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ID:",
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.grey,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Cliente:",
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.grey,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.args.id,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.args.cliente,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Mappa (mock UI)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 260,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _interventoPoint,
                              initialZoom: _zoom,
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
                                    point: _interventoPoint,
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
                            left: 16,
                            top: 16,
                            child: _zoomBox(isDark),
                          ),
                          Positioned(
                            left: 86,
                            top: 20,
                            child: _tooltipBubble(isDark),
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Material(
                              color: isDark
                                  ? const Color(0xCC2C2C2C)
                                  : const Color(0xF2FFFFFF),
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: _openNavigation,
                                borderRadius: BorderRadius.circular(14),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.navigation_rounded,
                                        size: 18,
                                        color: Color(0xFF6A7AF4),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Apri Maps",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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

                  const SizedBox(height: 16),

                  // Bottoni
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A7AF4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Prendi in Carico",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF4D5A),
                        side: const BorderSide(
                          color: Color(0xFFFF4D5A),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Rifiuta",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            Row(
              children: [
                Text(
                  "Traffico Live",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF374151),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _trafficCard(
              isDark: isDark,
              cardColor: cardColor,
              iconBg: const Color(0xFFFF4D5A),
              icon: Icons.car_crash_rounded,
              title: "Incidente in tangenziale Est a Milano, cod...",
              source: "News Traffico",
              time: "18:20",
            ),
            const SizedBox(height: 12),
            _trafficCard(
              isDark: isDark,
              cardColor: cardColor,
              iconBg: const Color(0xFFFF4D5A),
              icon: Icons.car_crash_rounded,
              title: "Incidente Al adesso: 4 km di coda verso ...",
              source: "News Traffico",
              time: "08:39",
            ),
            const SizedBox(height: 12),
            _trafficCard(
              isDark: isDark,
              cardColor: cardColor,
              iconBg: const Color(0xFFFFC24A),
              icon: Icons.traffic_rounded,
              title: "Tir si ribalta sull’Autosole, oltre 6 chilome...",
              source: "News Traffico",
              time: "08:00",
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _zoomBox(bool isDark) {
    return Container(
      width: 52,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
            ),
        ],
      ),
      child: Column(
        children: [
          IconButton(
            onPressed: () => _setZoom(_zoom + 1),
            icon: Icon(
              Icons.add_rounded,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
          IconButton(
            onPressed: () => _setZoom(_zoom - 1),
            icon: Icon(
              Icons.remove_rounded,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tooltipBubble(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xE62C2C2C) : const Color(0xF7FFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 18,
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Veicolo Fermo",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "${widget.args.lat.toStringAsFixed(4)}, ${widget.args.lng.toStringAsFixed(4)}",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Icon(
            Icons.close_rounded,
            size: 18,
            color: isDark ? Colors.white : Colors.black54,
          ),
        ],
      ),
    );
  }

  Widget _trafficCard({
    required bool isDark,
    required Color cardColor,
    required Color iconBg,
    required IconData icon,
    required String title,
    required String source,
    required String time,
  }) {
    return _card(
      isDark: isDark,
      color: cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: iconBg,
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  source,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
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
