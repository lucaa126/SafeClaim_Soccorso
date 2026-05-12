import 'package:flutter/foundation.dart';

class SafeClaimApiConfig {
  static const String localBaseUrl = 'https://safeclaim.giobra.com/api';
  static const String localFallbackBaseUrl = 'https://safeclaim.giobra.com/api';
  static const Duration requestTimeout = Duration(seconds: 5);

  // Keycloak configuration
  static const String keycloakBaseUrl = 'https://keycloak.giobra.com';
  static const String keycloakRealm = 'safeClaim';
  static const String keycloakClientId = 'safeclaim-client';

  static List<String> get baseUrls {
    const configuredPrimary = localBaseUrl;
    const configuredFallback = localFallbackBaseUrl;

    final defaults = _defaultBaseUrls;
    final urls = <String>[
      if (configuredPrimary.isNotEmpty) configuredPrimary,
      if (configuredFallback.isNotEmpty) configuredFallback,
      ...defaults,
    ];

    return urls.toSet().toList();
  }

  static List<String> get _defaultBaseUrls {
    if (kIsWeb) {
      return const [localBaseUrl, localFallbackBaseUrl];
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const [localFallbackBaseUrl, localBaseUrl];
    }
    return const [localBaseUrl, localFallbackBaseUrl];
  }
}
