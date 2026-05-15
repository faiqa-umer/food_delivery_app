// ============================================================
// FILE: lib/services/api_service.dart
// PURPOSE: Centralized API service for all backend communication.
//          Handles authentication, error handling, and response parsing.
// ============================================================

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ApiService {
  // Use your PC IP address for network testing
  static const String baseUrl = 'http://127.0.0.1:5000/api';
  static const String userId = 'default_user'; // Phase 3: Use default user

  static Future<Map<String, String>> _getHeaders({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (auth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        headers['X-User-Id'] = userId; // optional
      }
    } else {
      headers['X-User-Id'] = userId;
    }

    return headers;
  }

  // ─── LOGIN ───
  static Future<Map<String, dynamic>> login(
      String email, String password, String role) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'role': role}),
      );

      final data = jsonDecode(response.body);

      // ✅ FIXED: Backend returns "status": "success", not "success": true
      if (response.statusCode == 200 && data["status"] == "success") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
      }

      return data;
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ─── REGISTER ───
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String role,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ─── GET PROFILE ───
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final url = Uri.parse('$baseUrl/auth/profile');
      final response =
          await http.get(url, headers: await _getHeaders(auth: true));
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ─── UPDATE PROFILE ───
  static Future<Map<String, dynamic>> updateProfile(
      {required String name, String? phone}) async {
    try {
      final url = Uri.parse('$baseUrl/auth/profile');
      final response = await http.put(
        url,
        headers: await _getHeaders(auth: true),
        body: jsonEncode({"name": name, "phone": phone}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ─── LOGOUT ───
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  // ── MENU ENDPOINTS ─────────────────────────────────────────

  /// Get all menu items for a specific restaurant
  static Future<Map<String, dynamic>> getMenuByRestaurant(
      String restaurantId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/menu/restaurant/$restaurantId'),
            headers: await _getHeaders(auth: true),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load menu: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error loading menu', e);
      rethrow;
    }
  }

  // ── CART ENDPOINTS ─────────────────────────────────────────

  /// Get user's cart
  static Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/cart/'),
            headers: await _getHeaders(auth: true),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? {};
      } else {
        throw Exception('Failed to load cart: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error loading cart', e);
      rethrow;
    }
  }

  /// Add item to cart
  static Future<Map<String, dynamic>> addToCart({
    required String menuItemId,
    required int quantity,
    String specialInstructions = '',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/cart/'),
            headers: await _getHeaders(auth: true),
            body: jsonEncode({
              'menu_item_id': menuItemId,
              'quantity': quantity,
              'special_instructions': specialInstructions,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? {};
      } else {
        throw Exception('Failed to add to cart: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error adding to cart', e);
      rethrow;
    }
  }

  /// Update cart item quantity
  static Future<Map<String, dynamic>> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/cart/$cartItemId'),
            headers: await _getHeaders(auth: true),
            body: jsonEncode({'quantity': quantity}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? {};
      } else {
        throw Exception('Failed to update cart: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error updating cart', e);
      rethrow;
    }
  }

  /// Remove item from cart
  static Future<void> removeFromCart(String cartItemId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/cart/$cartItemId'),
            headers: await _getHeaders(auth: true),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to remove from cart: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error removing from cart', e);
      rethrow;
    }
  }

  /// Clear entire cart
  static Future<void> clearCart() async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/cart/'),
            headers: await _getHeaders(auth: true),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to clear cart: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error clearing cart', e);
      rethrow;
    }
  }

  // ── ORDER ENDPOINTS ────────────────────────────────────────

  /// Create new order from current cart
  static Future<Map<String, dynamic>> createOrder({
    required String restaurantId,
    required Map<String, dynamic> deliveryAddress,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/orders/'),
            headers: await _getHeaders(auth: true),
            body: jsonEncode({
              'delivery_address': deliveryAddress,
              'payment_method': paymentMethod,
              'total_amount': totalAmount,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? {};
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error creating order', e);
      rethrow;
    }
  }

  /// Get user's orders
  static Future<Map<String, dynamic>> getUserOrders() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/orders/'),
            headers: await _getHeaders(auth: true),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error loading orders', e);
      rethrow;
    }
  }

  /// Get restaurants list
  static Future<Map<String, dynamic>> getRestaurants({
    int page = 1,
    int limit = 20,
    String? cuisine,
    bool? isOpen,
  }) async {
    try {
      final queryParameters = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (cuisine != null && cuisine.isNotEmpty) {
        queryParameters['cuisine'] = cuisine;
      }
      if (isOpen != null) {
        queryParameters['is_open'] = isOpen ? 'true' : 'false';
      }

      final uri = Uri.parse('$baseUrl/restaurants/')
          .replace(queryParameters: queryParameters);
      final response = await http
          .get(
            uri,
            headers: await _getHeaders(), // no auth needed for restaurants
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          if (decoded.isNotEmpty &&
              decoded[0] is Map &&
              decoded[0]['data'] is Map &&
              decoded[0]['data']['restaurants'] is List) {
            return {
              'restaurants': decoded[0]['data']['restaurants'] as List<dynamic>
            };
          }
          return {'restaurants': decoded};
        }

        if (decoded is Map<String, dynamic>) {
          if (decoded['data'] is List) {
            return {'restaurants': decoded['data'] as List<dynamic>};
          }
          if (decoded['restaurants'] is List) {
            return {'restaurants': decoded['restaurants'] as List<dynamic>};
          }
          if (decoded['data'] is Map &&
              decoded['data']['restaurants'] is List) {
            return {
              'restaurants': decoded['data']['restaurants'] as List<dynamic>
            };
          }
        }

        throw Exception('Unexpected restaurants response format');
      } else {
        throw Exception('Failed to load restaurants: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error loading restaurants', e);
      rethrow;
    }
  }

  /// Get order by ID
  static Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/orders/$orderId'),
            headers: await _getHeaders(auth: true),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? {};
      } else {
        throw Exception('Failed to load order: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error loading order: $e');
      rethrow;
    }
  }

  /// Get order status
  static Future<Map<String, dynamic>> getOrderStatus(String orderId) async {
    return getOrderById(orderId);
  }

  /// Update order status
  static Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/orders/$orderId'),
            headers: await _getHeaders(auth: true),
            body: jsonEncode({'status': status}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? {};
      } else {
        throw Exception('Failed to update order: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error updating order: $e');
      rethrow;
    }
  }

  // ── PAYMENT ENDPOINTS ──────────────────────────────────────

  /// Process payment
  static Future<Map<String, dynamic>> processPayment({
    required String orderId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/payments/'),
            headers: await _getHeaders(auth: true),
            body: jsonEncode({
              'order_id': orderId,
              'amount': amount,
              'method': paymentMethod,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? {};
      } else {
        throw Exception('Failed to process payment: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error processing payment', e);
      rethrow;
    }
  }

  /// Get payment by order ID
  static Future<Map<String, dynamic>> getOrderPayment(String orderId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/payments/orders/$orderId'),
            headers: await _getHeaders(auth: true),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? {};
      } else {
        throw Exception('Failed to load payment: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error loading payment: $e');
      rethrow;
    }
  }

  // ── DELIVERY ENDPOINTS ─────────────────────────────────────

  /// Get delivery info for an order
  static Future<Map<String, dynamic>> getDeliveryInfo(String orderId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/deliveries/$orderId'),
            headers: await _getHeaders(auth: true),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? {};
      } else {
        throw Exception('Failed to load delivery: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error loading delivery', e);
      rethrow;
    }
  }

  /// Get payment by payment ID
  static Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/payments/$paymentId'),
            headers: await _getHeaders(auth: true),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? {};
      } else {
        throw Exception('Failed to load payment: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error loading payment', e);
      rethrow;
    }
  }

  /// Update delivery status
  static Future<Map<String, dynamic>> updateDeliveryStatus({
    required String deliveryId,
    required String status,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/deliveries/$deliveryId'),
            headers: await _getHeaders(auth: true),
            body: jsonEncode({'status': status}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? {};
      } else {
        throw Exception('Failed to update delivery: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error updating delivery', e);
      rethrow;
    }
  }

  // ── NOTIFICATION ENDPOINTS ────────────────────────────────

  /// Get user notifications
  static Future<List<dynamic>> getNotifications() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/notifications/'),
            headers: await _getHeaders(auth: true),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? [];
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error loading notifications: $e');
      rethrow;
    }
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/notifications/$notificationId/read'),
            headers: await _getHeaders(auth: true),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      logger.e('Error marking notification as read', e);
      rethrow;
    }
  }
}
