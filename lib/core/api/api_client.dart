import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';

class ApiClient {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _timeout = Duration(seconds: 15);

  static String? _token;

  static String get baseUrl => AppConfig.apiBaseUrl;

  // Initialize — loads stored token securely
  static Future<void> initialize() async {
    _token = await _storage.read(key: _tokenKey);
  }

  static Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: _tokenKey);
  }

  static bool get isAuthenticated => _token != null;

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> data;

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      } else {
        data = {'data': decoded};
      }
    } catch (_) {
      throw ApiException(
        message: 'Invalid response from server',
        code: 'PARSE_ERROR',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final errorMessage = (data['error'] is Map)
        ? data['error']['message'] as String? ?? 'Unknown error'
        : data['message'] as String? ?? 'Unknown error';

    throw ApiException(
      message: errorMessage,
      code: (data['error'] is Map)
          ? data['error']['code'] as String? ?? 'UNKNOWN_ERROR'
          : 'UNKNOWN_ERROR',
      statusCode: response.statusCode,
    );
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: _getHeaders())
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection', code: 'NO_INTERNET');
    } on HttpException {
      throw ApiException(message: 'Network error', code: 'NETWORK_ERROR');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString(), code: 'REQUEST_ERROR');
    }
  }

  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(),
            body: jsonEncode(data),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection', code: 'NO_INTERNET');
    } on HttpException {
      throw ApiException(message: 'Network error', code: 'NETWORK_ERROR');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString(), code: 'REQUEST_ERROR');
    }
  }

  static Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(),
            body: jsonEncode(data),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection', code: 'NO_INTERNET');
    } on HttpException {
      throw ApiException(message: 'Network error', code: 'NETWORK_ERROR');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString(), code: 'REQUEST_ERROR');
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: _getHeaders())
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection', code: 'NO_INTERNET');
    } on HttpException {
      throw ApiException(message: 'Network error', code: 'NETWORK_ERROR');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString(), code: 'REQUEST_ERROR');
    }
  }
}

class ApiException implements Exception {
  final String message;
  final String code;
  final int? statusCode;

  const ApiException({
    required this.message,
    required this.code,
    this.statusCode,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isNetworkError => code == 'NO_INTERNET' || code == 'NETWORK_ERROR';

  @override
  String toString() => 'ApiException[$code]: $message (HTTP $statusCode)';
}