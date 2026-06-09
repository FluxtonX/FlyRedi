import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  static Future<String> getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('ApiService auth: current user uid = null');
      print('ApiService auth: token exists = false');
      throw Exception('Authentication required. Please sign in again.');
    }

    final token = await user.getIdToken(true);
    print('ApiService auth: current user uid = ${user.uid}');
    print(
      'ApiService auth: token exists = ${token != null && token.isNotEmpty}',
    );

    if (token == null || token.isEmpty) {
      throw Exception('Authentication required. Firebase ID token is missing.');
    }

    return token;
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await getHeaders(),
    );

    _logResponse(endpoint, response.statusCode);
    return response;
  }

  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await getHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );

    _logResponse(endpoint, response.statusCode);
    return response;
  }

  static Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: await getHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );

    _logResponse(endpoint, response.statusCode);
    return response;
  }

  static Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await getHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );

    _logResponse(endpoint, response.statusCode);
    return response;
  }

  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await getHeaders(),
    );

    _logResponse(endpoint, response.statusCode);
    return response;
  }

  static void _logResponse(String endpoint, int statusCode) {
    print('ApiService request: $endpoint -> $statusCode');
  }
}
