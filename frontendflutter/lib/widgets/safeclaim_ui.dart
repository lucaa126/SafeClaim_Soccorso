import 'package:flutter/material.dart';

import '../app/app.dart';
import '../app/theme.dart';

Widget buildSharedThemeToggle(BuildContext context, bool isDark) {
  return ToggleButtons(
    isSelected: [!isDark, isDark],
    onPressed: (index) {
      SoccorsoApp.of(context).toggleTheme(index == 1);
    },
    borderRadius: BorderRadius.circular(8),
    constraints: const BoxConstraints(minHeight: 32, minWidth: 36),
    selectedColor: Colors.white,
    color: isDark ? Colors.white70 : SafeClaimColors.primaryLightest,
    fillColor: SafeClaimColors.primaryDark,
    borderColor: Colors.white.withValues(alpha: 0.35),
    selectedBorderColor: Colors.white.withValues(alpha: 0.70),
    children: const [
      Icon(Icons.wb_sunny_outlined, size: 18),
      Icon(Icons.nightlight_round, size: 18),
    ],
  );
}

Color safeClaimCardColor(bool isDark) =>
    isDark ? SafeClaimColors.darkCard : SafeClaimColors.card;

Color safeClaimSubtleTextColor(bool isDark) =>
    isDark ? Colors.white70 : SafeClaimColors.textMuted;

BoxDecoration safeClaimCardDecoration(bool isDark, {Color? color}) {
  return BoxDecoration(
    color: color ?? safeClaimCardColor(isDark),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.10)
          : SafeClaimColors.primaryLight.withValues(alpha: 0.45),
    ),
    boxShadow: [
      if (!isDark)
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
    ],
  );
}

Widget safeClaimStatusBadge(String status, {String? label}) {
  final style = safeClaimStatusStyle(status);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: style.background,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: style.border.withValues(alpha: 0.75)),
    ),
    child: Text(
      label ?? style.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: style.foreground,
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
    ),
  );
}
