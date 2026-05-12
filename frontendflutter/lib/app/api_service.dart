import 'package:http/http.dart' as http;
import '../../app/api_config.dart';
import '../../app/auth_service.dart';

class ApiService {
  static Future<http.Response> get(String endpoint) async {
    final token = await AuthService.getAccessToken();
    final url = '${SafeClaimApiConfig.baseUrls.first}$endpoint';
    
    return http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }
}