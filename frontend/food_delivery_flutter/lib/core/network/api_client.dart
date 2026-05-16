// ============================================================
// FILE: lib/core/network/api_client.dart
// PURPOSE: The central HTTP engine for the entire Flutter app.
//          All network requests go through this class.
//
// WHAT IT HANDLES:
//   ✅ GET, POST, PUT, DELETE requests
//   ✅ Setting Content-Type headers
//   ✅ Timeout handling (slow connections)
//   ✅ Network errors (no internet)
//   ✅ HTTP errors (404, 500)
//   ✅ JSON parsing
//   ✅ Decoding the Flask {status, message, data} envelope
//
// SERVICES USE IT LIKE:
//   final json = await _client.get('/api/restaurants/');
// ============================================================

import 'dart:convert';           // jsonDecode, jsonEncode
import 'dart:io';                // SocketException (no internet)
import 'package:http/http.dart' as http;
import 'api_response.dart';
import '../constants/api_constants.dart';

class ApiClient {
  // ── Singleton pattern ──────────────────────────────────────
  // Singleton means only ONE instance of ApiClient exists.
  // Every service imports the same object — no duplication.
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // ── Standard headers sent with every request ───────────────
  // Content-Type: application/json tells Flask we're sending JSON
  // Accept: application/json tells Flask we want JSON back
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept':       'application/json',
  };

  // ── Build a full URI from a path string ────────────────────
  // path = '/api/restaurants/'
  // → Uri.parse('http://10.0.2.2:5000/api/restaurants/')
  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final base = Uri.parse(ApiConstants.baseUrl);
    return Uri(
      scheme:      base.scheme,
      host:        base.host,
      port:        base.port,
      path:        path,
      queryParameters: queryParams,
    );
  }

  // ──────────────────────────────────────────────────────────
  // GET REQUEST
  // Used for: fetching restaurants, menus, reviews, searching
  //
  // Args:
  //   path        : API endpoint path e.g. '/api/restaurants/'
  //   queryParams : Optional query string e.g. {'page': '1', 'limit': '10'}
  // ──────────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = _buildUri(path, queryParams);

      // Make the HTTP GET request with a timeout
      final response = await http
          .get(uri, headers: _headers)
          .timeout(ApiConstants.connectTimeout);

      return _handleResponse(response);

    } on SocketException {
      // No internet connection
      return ApiResponse.error(
        message: 'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } on http.ClientException catch (e) {
      // The server is unreachable (Flask not running)
      return ApiResponse.error(
        message: 'Cannot reach the server. Is Flask running?\n${e.message}',
        statusCode: 0,
      );
    } on Exception catch (e) {
      // Timeout or any unexpected error
      if (e.toString().contains('TimeoutException')) {
        return ApiResponse.error(
          message: 'Request timed out. Check your connection.',
          statusCode: 408,
        );
      }
      return ApiResponse.error(
        message: 'Unexpected error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // ──────────────────────────────────────────────────────────
  // POST REQUEST
  // Used for: creating restaurants, menu items, reviews
  //
  // Args:
  //   path : API endpoint path
  //   body : Dart Map that will be converted to JSON string
  // ──────────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final uri = _buildUri(path);
      final response = await http
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(ApiConstants.connectTimeout);

      return _handleResponse(response);

    } on SocketException {
      return ApiResponse.error(
        message: 'No internet connection.',
        statusCode: 0,
      );
    } on http.ClientException catch (e) {
      return ApiResponse.error(
        message: 'Cannot reach the server: ${e.message}',
        statusCode: 0,
      );
    } on Exception catch (e) {
      return ApiResponse.error(
        message: 'Error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // ──────────────────────────────────────────────────────────
  // PUT REQUEST
  // Used for: updating restaurants, menu items, reviews
  // ──────────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> put(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final uri = _buildUri(path);
      final response = await http
          .put(uri, headers: _headers, body: jsonEncode(body))
          .timeout(ApiConstants.connectTimeout);

      return _handleResponse(response);

    } on SocketException {
      return ApiResponse.error(message: 'No internet connection.', statusCode: 0);
    } on http.ClientException catch (e) {
      return ApiResponse.error(message: 'Cannot reach server: ${e.message}', statusCode: 0);
    } on Exception catch (e) {
      return ApiResponse.error(message: 'Error: ${e.toString()}', statusCode: 0);
    }
  }

  // ──────────────────────────────────────────────────────────
  // DELETE REQUEST
  // Used for: deleting restaurants, menu items, reviews
  // ──────────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> delete(String path) async {
    try {
      final uri = _buildUri(path);
      final response = await http
          .delete(uri, headers: _headers)
          .timeout(ApiConstants.connectTimeout);

      return _handleResponse(response);

    } on SocketException {
      return ApiResponse.error(message: 'No internet connection.', statusCode: 0);
    } on http.ClientException catch (e) {
      return ApiResponse.error(message: 'Cannot reach server: ${e.message}', statusCode: 0);
    } on Exception catch (e) {
      return ApiResponse.error(message: 'Error: ${e.toString()}', statusCode: 0);
    }
  }

  // ──────────────────────────────────────────────────────────
  // RESPONSE HANDLER (PRIVATE)
  // Called by all methods above after receiving an HTTP response.
  // Parses the Flask JSON envelope and returns ApiResponse.
  //
  // Flask envelope shape:
  //   { "status": "success", "message": "...", "data": { ... } }
  // ──────────────────────────────────────────────────────────
  ApiResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    // ── Try to parse JSON body ─────────────────────────────
    Map<String, dynamic> responseBody;
    try {
      responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      // Response wasn't valid JSON (e.g. HTML error page from Flask)
      return ApiResponse.error(
        message: 'Invalid response from server (not JSON). Status: $statusCode',
        statusCode: statusCode,
      );
    }

    final flaskStatus  = responseBody['status']  as String? ?? 'error';
    final flaskMessage = responseBody['message'] as String? ?? 'Unknown error';
    final flaskData    = responseBody['data']    as Map<String, dynamic>?;
    final flaskErrors  = responseBody['errors']  as List<dynamic>? ?? [];

    // ── Success: 2xx status code AND Flask says "success" ───
    if (statusCode >= 200 && statusCode < 300 && flaskStatus == 'success') {
      return ApiResponse.success(
        data:       flaskData ?? {},
        message:    flaskMessage,
        statusCode: statusCode,
      );
    }

    // ── Error: any non-2xx OR Flask says "error" ────────────
    return ApiResponse.error(
      message:    flaskMessage,
      statusCode: statusCode,
      errors:     flaskErrors,
    );
  }
}