import 'package:flutter/foundation.dart';

class SafeClaimApiConfig {
  static const String localBaseUrl = 'http://127.0.0.1:5000/api';
  static const String localFallbackBaseUrl = 'http://safeclaim.giobra.com/api';
  static const Duration requestTimeout = Duration(seconds: 5);

  static List<String> get baseUrls {
    const configuredPrimary = String.fromEnvironment('SAFECLAIM_API_BASE_URL');
    const configuredFallback = String.fromEnvironment(
      'SAFECLAIM_API_FALLBACK_BASE_URL',
    );

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
