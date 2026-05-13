import 'package:http/http.dart' as http;

import '../../app/api_client.dart';
import '../../app/auth_service.dart';

class AnalyticsSummary {
  final int total;
  final int pending;
  final int accepted;
  final int handled;
  final List<int> last7Days;
  final Map<String, int> fleetStatus;
  final int averageHandlingMins;

  const AnalyticsSummary({
    required this.total,
    required this.pending,
    required this.accepted,
    required this.handled,
    required this.last7Days,
    required this.fleetStatus,
    required this.averageHandlingMins,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    final payload = _asMap(json['data']) ?? json;

    return AnalyticsSummary(
      total: _asInt(payload['total']),
      pending: _asInt(payload['pending']),
      accepted: _asInt(payload['accepted']),
      handled: _asInt(payload['handled']),
      last7Days: _asIntList(payload['last7Days']),
      fleetStatus: _asStringIntMap(payload['fleetStatus']),
      averageHandlingMins: _asInt(payload['averageHandlingMins']),
    );
  }
}

class Review {
  final String author;
  final int rating;
  final String comment;
  final DateTime date;

  Review({
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      author: _asString(json['author']) ?? '',
      rating: _asInt(json['rating']),
      comment: _asString(json['comment']) ?? '',
      date: _asDateTime(json['date']) ?? DateTime.now(),
    );
  }
}

class TrafficIncident {
  final String title;
  final String source;
  final DateTime pubDate;
  final String link;

  TrafficIncident({
    required this.title,
    required this.source,
    required this.pubDate,
    required this.link,
  });

  factory TrafficIncident.fromJson(Map<String, dynamic> json) {
    return TrafficIncident(
      title: _asString(json['title']) ?? '',
      source: _asString(json['source']) ?? '',
      pubDate: _asDateTime(json['pubDate']) ?? DateTime.now(),
      link: _asString(json['link']) ?? '',
    );
  }
}

class AnalyticsApiService {
  AnalyticsApiService({http.Client? client})
    : _apiClient = SafeClaimApiClient(client: client);

  final SafeClaimApiClient _apiClient;

  Future<AnalyticsSummary> getAnalyticsSummary() async {
    final totalResponse = await _requestJsonOrEmpty(
      'GET',
      '/analytics/total-requests',
    );
    final pendingResponse = await _requestJsonOrEmpty(
      'GET',
      '/analytics/pending',
    );
    final acceptedResponse = await _requestJsonOrEmpty(
      'GET',
      '/analytics/accepted',
    );
    final handledResponse = await _requestJsonOrEmpty(
      'GET',
      '/analytics/handled',
    );

    final data = {
      'data': {
        'total':
            totalResponse['data'] ??
            totalResponse['count'] ??
            totalResponse['total'] ??
            0,
        'pending':
            pendingResponse['data'] ??
            pendingResponse['count'] ??
            pendingResponse['pending'] ??
            0,
        'accepted':
            acceptedResponse['data'] ??
            acceptedResponse['count'] ??
            acceptedResponse['accepted'] ??
            0,
        'handled':
            handledResponse['data'] ??
            handledResponse['count'] ??
            handledResponse['handled'] ??
            0,
        'last7Days': totalResponse['last7Days'] ?? const [],
        'fleetStatus': totalResponse['fleetStatus'] ?? const {},
        'averageHandlingMins': totalResponse['averageHandlingMins'] ?? 0,
      },
    };

    return AnalyticsSummary.fromJson(data);
  }

  Future<List<Review>> getRecentReviews() async {
    final data = await _requestJsonOrEmpty('GET', '/analytics/reviews');
    final rawItems = data['data'] is List ? data['data'] as List : const [];

    return rawItems
        .whereType<Map>()
        .map((item) => Review.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<TrafficIncident>> getRealTimeTraffic(String city) async {
    final data = await _requestJsonOrEmpty(
      'GET',
      '/analytics/traffic',
      body: {'city': city},
    );
    final rawItems = data['data'] is List ? data['data'] as List : const [];

    return rawItems
        .whereType<Map>()
        .map(
          (item) => TrafficIncident.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<Map<String, dynamic>> _requestJson(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _apiClient.requestJson(method, path, body: body);
  }

  Future<Map<String, dynamic>> _requestJsonOrEmpty(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      return await _requestJson(method, path, body: body);
    } on TokenInvalidException {
      rethrow;
    } catch (_) {
      return const <String, dynamic>{};
    }
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

String? _asString(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  return value.toString();
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

List<int> _asIntList(dynamic value) {
  if (value is List<int>) {
    return value;
  }
  if (value is List) {
    return value.whereType<int>().toList();
  }
  return const [];
}

Map<String, int> _asStringIntMap(dynamic value) {
  if (value is Map<String, int>) {
    return value;
  }
  if (value is Map) {
    final result = <String, int>{};
    for (final entry in value.entries) {
      final key = entry.key.toString();
      final val = entry.value;
      if (val is int) {
        result[key] = val;
      } else if (val is num) {
        result[key] = val.toInt();
      }
    }
    return result;
  }
  return const {};
}

DateTime? _asDateTime(dynamic value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
