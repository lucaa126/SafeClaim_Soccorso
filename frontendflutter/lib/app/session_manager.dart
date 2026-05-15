import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'routes.dart';

/// Singleton che espone:
///   * un `navigatorKey` globale da passare a `MaterialApp`;
///   * `forceLogoutToLogin()` invocato dal client HTTP quando il token
///     è scaduto/invalido e il refresh fallisce.
class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  bool _logoutInProgress = false;

  Future<void> forceLogoutToLogin() async {
    // Evita di sparare più redirect concomitanti se molte chiamate
    // ricevono 401 nello stesso istante.
    if (_logoutInProgress) return;
    _logoutInProgress = true;

    try {
      await AuthService.clearSession();

      final navigator = navigatorKey.currentState;
      if (navigator == null || !navigator.mounted) return;

      navigator.pushNamedAndRemoveUntil(
        Routes.login,
        (route) => false,
      );
    } finally {
      _logoutInProgress = false;
    }
  }
}
