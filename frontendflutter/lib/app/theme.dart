import 'package:flutter/material.dart';

class SafeClaimColors {
  const SafeClaimColors._();

  static const primaryDark = Color(0xFF09637E);
  static const primary = Color(0xFF088395);
  static const primaryLight = Color(0xFF7AB2B2);
  static const primaryLightest = Color(0xFFEBF4F6);
  static const foreground = Color(0xFF061E29);
  static const textStrong = Color(0xFF10546D);
  static const textMuted = Color(0xFF5F9598);
  static const neutral = Color(0xFFF3F4F4);
  static const background = Color(0xFFF4F4F4);
  static const card = Color(0xFFFFFFFF);
  static const danger = Color(0xFFB42318);
  static const dangerSoft = Color(0xFFFFEBEE);
  static const warning = Color(0xFFE65100);
  static const warningSoft = Color(0xFFFFF3E0);

  static const darkBackground = Color(0xFF061E29);
  static const darkSurface = Color(0xFF0D2B38);
  static const darkCard = Color(0xFF123A49);
}

class SafeClaimStatusStyle {
  const SafeClaimStatusStyle({
    required this.background,
    required this.foreground,
    required this.border,
    required this.label,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final String label;
}

SafeClaimStatusStyle safeClaimStatusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'accepted':
    case 'in_corso':
    case 'in_lavorazione':
    case 'busy':
      return const SafeClaimStatusStyle(
        background: Color(0x337AB2B2),
        foreground: SafeClaimColors.primaryDark,
        border: SafeClaimColors.primaryLight,
        label: 'In corso',
      );
    case 'handled':
    case 'completed':
    case 'completata':
    case 'available':
      return const SafeClaimStatusStyle(
        background: Color(0x1A10546D),
        foreground: SafeClaimColors.textStrong,
        border: SafeClaimColors.textStrong,
        label: 'Completata',
      );
    case 'rejected':
    case 'reject':
    case 'offline':
      return const SafeClaimStatusStyle(
        background: SafeClaimColors.dangerSoft,
        foreground: SafeClaimColors.danger,
        border: SafeClaimColors.danger,
        label: 'Rifiutata',
      );
    case 'maintenance':
      return const SafeClaimStatusStyle(
        background: SafeClaimColors.neutral,
        foreground: SafeClaimColors.textStrong,
        border: SafeClaimColors.primaryLight,
        label: 'Manutenzione',
      );
    case 'pending':
    case 'in_attesa':
    default:
      return const SafeClaimStatusStyle(
        background: SafeClaimColors.primaryLightest,
        foreground: SafeClaimColors.textStrong,
        border: SafeClaimColors.primaryLight,
        label: 'In attesa',
      );
  }
}

ThemeData lightTheme() {
  const colorScheme = ColorScheme.light(
    primary: SafeClaimColors.primary,
    onPrimary: Colors.white,
    secondary: SafeClaimColors.primaryLight,
    onSecondary: SafeClaimColors.foreground,
    surface: SafeClaimColors.card,
    onSurface: SafeClaimColors.foreground,
    error: SafeClaimColors.danger,
    onError: Colors.white,
  );

  return _baseTheme(
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: SafeClaimColors.background,
    cardColor: SafeClaimColors.card,
    mutedTextColor: SafeClaimColors.textMuted,
  );
}

ThemeData darkTheme() {
  const colorScheme = ColorScheme.dark(
    primary: SafeClaimColors.primaryLight,
    onPrimary: SafeClaimColors.foreground,
    secondary: SafeClaimColors.primary,
    onSecondary: Colors.white,
    surface: SafeClaimColors.darkCard,
    onSurface: Colors.white,
    error: Color(0xFFFFB4AB),
    onError: SafeClaimColors.foreground,
  );

  return _baseTheme(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: SafeClaimColors.darkBackground,
    cardColor: SafeClaimColors.darkCard,
    mutedTextColor: const Color(0xFFB6CCD2),
  );
}

ThemeData _baseTheme({
  required Brightness brightness,
  required ColorScheme colorScheme,
  required Color scaffoldBackgroundColor,
  required Color cardColor,
  required Color mutedTextColor,
}) {
  final isDark = brightness == Brightness.dark;
  final borderColor = isDark
      ? Colors.white.withValues(alpha: 0.12)
      : SafeClaimColors.primaryLight;

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    fontFamily: null,
  );

  return base.copyWith(
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor.withValues(alpha: 0.45)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? SafeClaimColors.darkSurface : Colors.white,
      prefixIconColor: mutedTextColor,
      labelStyle: TextStyle(color: mutedTextColor),
      hintStyle: TextStyle(color: mutedTextColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: isDark
            ? Colors.white.withValues(alpha: 0.10)
            : const Color(0xFFE4E7EC),
        disabledForegroundColor: mutedTextColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return isDark ? const Color(0xFFB6CCD2) : SafeClaimColors.textMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return isDark
            ? Colors.white.withValues(alpha: 0.16)
            : SafeClaimColors.neutral;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: BorderSide(color: borderColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark
          ? SafeClaimColors.primaryLight
          : SafeClaimColors.foreground,
      contentTextStyle: TextStyle(
        color: isDark ? SafeClaimColors.foreground : Colors.white,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dataTableTheme: DataTableThemeData(
      headingTextStyle: TextStyle(
        color: isDark ? Colors.white : SafeClaimColors.foreground,
        fontWeight: FontWeight.w900,
      ),
      dataTextStyle: TextStyle(
        color: isDark ? Colors.white70 : SafeClaimColors.foreground,
        fontWeight: FontWeight.w600,
      ),
      dividerThickness: 0.8,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: isDark
          ? Colors.white.withValues(alpha: 0.14)
          : SafeClaimColors.primaryLightest,
    ),
    dividerTheme: DividerThemeData(
      color: isDark
          ? Colors.white.withValues(alpha: 0.12)
          : SafeClaimColors.primaryLight.withValues(alpha: 0.45),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
  );
}
