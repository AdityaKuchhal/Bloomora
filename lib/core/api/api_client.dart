import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // Replace with your actual Railway URL
  static const String baseUrl = 'https://bloomora-api.up.railway.app/api/v1';

  static String? _token;

  // Initialize with token from storage
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Set authentication token
  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear authentication token
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get headers with authentication
  static Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // Handle API responses
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        message: data['error']?['message'] ?? 'Unknown error',
        code: data['error']?['code'] ?? 'UNKNOWN_ERROR',
        statusCode: response.statusCode,
      );
    }
  }

  // GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
          message: 'No internet connection', code: 'NO_INTERNET');
    } catch (e) {
      throw ApiException(message: e.toString(), code: 'REQUEST_ERROR');
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
          message: 'No internet connection', code: 'NO_INTERNET');
    } catch (e) {
      throw ApiException(message: e.toString(), code: 'REQUEST_ERROR');
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
          message: 'No internet connection', code: 'NO_INTERNET');
    } catch (e) {
      throw ApiException(message: e.toString(), code: 'REQUEST_ERROR');
    }
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
          message: 'No internet connection', code: 'NO_INTERNET');
    } catch (e) {
      throw ApiException(message: e.toString(), code: 'REQUEST_ERROR');
    }
  }
}

// Custom exception class
class ApiException implements Exception {
  final String message;
  final String code;
  final int? statusCode;

  ApiException({
    required this.message,
    required this.code,
    this.statusCode,
  });

  @override
  String toString() => 'ApiException: $message (Code: $code)';
}
