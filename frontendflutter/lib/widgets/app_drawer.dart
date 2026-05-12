import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../app/theme.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showDettaglio = currentRoute == Routes.dettaglio;

    return Drawer(
      backgroundColor: isDark ? SafeClaimColors.darkSurface : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              decoration: BoxDecoration(
                color: isDark
                    ? SafeClaimColors.darkCard
                    : SafeClaimColors.primary,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : SafeClaimColors.primaryDark,
                  ),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    "SOCCORSO",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.close, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
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
            Divider(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : SafeClaimColors.primaryLight.withValues(alpha: 0.45),
            ),
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
            ? (isDark
                  ? SafeClaimColors.primary.withValues(alpha: 0.18)
                  : SafeClaimColors.primaryLightest)
            : Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 32,
              child: Icon(
                icon,
                color: isSelected
                    ? SafeClaimColors.primary
                    : (isDark ? Colors.white60 : SafeClaimColors.textMuted),
                size: 28,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                color: isSelected
                    ? SafeClaimColors.primary
                    : (isDark ? Colors.white70 : SafeClaimColors.foreground),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
