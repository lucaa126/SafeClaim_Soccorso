import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../widgets/app_drawer.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  final String currentRoute;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: currentRoute == Routes.dashboard
            ? const AppDrawer(currentRoute: Routes.dashboard)
            : AppDrawer(currentRoute: currentRoute),
      ),
      body: Center(
        child: Text(
          "$title (TODO)",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
      ),
    );
  }
}
