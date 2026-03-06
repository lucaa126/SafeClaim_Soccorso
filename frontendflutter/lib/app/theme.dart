import 'package:flutter/material.dart';

const _seed = Color(0xFF6A7AF4);

ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: true,
    debugShowCheckedModeBanner: false,
    brightness: Brightness.light,
    colorSchemeSeed: _seed,
    scaffoldBackgroundColor: const Color(0xFFF1F3F9),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF1F3F9),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87),
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    debugShowCheckedModeBanner: false,
    brightness: Brightness.dark,
    colorSchemeSeed: _seed,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );
}
