import 'package:flutter/material.dart';

import '../app/routes.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showDettaglio = currentRoute == Routes.dettaglio;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    "SOCCORSO",
                    style: TextStyle(
                      color: Color(0xFFE57373),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _fullScreenSidebarItem(
              context,
              Icons.grid_view_rounded,
              "Dashboard",
              isDark,
              Routes.dashboard,
            ),
            if (showDettaglio)
              _fullScreenSidebarItem(
                context,
                Icons.location_on_outlined,
                "Dettaglio Intervento",
                isDark,
                Routes.dettaglio,
              ),
            _fullScreenSidebarItem(
              context,
              Icons.campaign_outlined,
              "Richieste",
              isDark,
              Routes.richieste,
            ),
            _fullScreenSidebarItem(
              context,
              Icons.local_shipping_outlined,
              "Flotta",
              isDark,
              Routes.flotta,
            ),
            _fullScreenSidebarItem(
              context,
              Icons.analytics_outlined,
              "Analytics",
              isDark,
              Routes.analytics,
            ),
            _fullScreenSidebarItem(
              context,
              Icons.settings,
              "Impostazioni",
              isDark,
              Routes.impostazioni,
            ),
            const Spacer(),
            const Divider(),
            _fullScreenSidebarItem(
              context,
              Icons.logout,
              "Logout",
              isDark,
              Routes.logout,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _fullScreenSidebarItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isDark,
    String route,
  ) {
    bool isSelected = currentRoute == route;

    return InkWell(
      onTap: () {
        Navigator.pop(context); // Chiude il drawer
        if (!isSelected) {
          if (route == Routes.dashboard) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.dashboard,
              (route) => false,
            );
          } else {
            Navigator.pushReplacementNamed(context, route);
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        color: isSelected
            ? Colors.blue.withValues(alpha: 0.1)
            : Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 32,
              child: Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey,
                size: 28,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                color: isSelected
                    ? Colors.blue
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
