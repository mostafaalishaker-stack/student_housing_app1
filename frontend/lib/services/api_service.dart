import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // For production: change to your deployed backend URL
  static const String productionUrl = 'https://sknkm.onrender.com/api';
  static const String emulatorUrl = 'http://10.0.2.2:3000/api';
  static const String webUrl = 'http://localhost:3000/api';

  static String get _baseUrl {
    if (Platform.isAndroid) {
      // Use production when built as release APK
      return productionUrl;
    }
    if (Platform.isWindows || Platform.isLinux) return webUrl;
    return productionUrl;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> getFileHeaders() async {
    final token = await getToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final headers = await getHeaders();
    return http.get(Uri.parse('$_baseUrl$endpoint'), headers: headers);
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await getHeaders();
    return http.post(Uri.parse('$_baseUrl$endpoint'), headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await getHeaders();
    return http.put(Uri.parse('$_baseUrl$endpoint'), headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await getHeaders();
    return http.delete(Uri.parse('$_baseUrl$endpoint'), headers: headers);
  }

  static Future<http.Response> uploadFiles(String endpoint, List<File> files, String fieldName) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);
    final token = await getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    for (final file in files) {
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    }
    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }
}
