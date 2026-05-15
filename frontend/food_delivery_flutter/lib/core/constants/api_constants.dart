// ============================================================
// FILE: lib/core/constants/api_constants.dart
// PURPOSE: Single source of truth for ALL API URLs.
//          Change baseUrl here and every service updates automatically.
//
// HOW TO FIND YOUR BASE URL:
//   • Running Flask locally on your PC:
//       Android Emulator → use 10.0.2.2 (maps to your PC's localhost)
//       iOS Simulator    → use 127.0.0.1
//       Physical Device  → use your PC's WiFi IP (run: ipconfig on Windows)
//
//   • Production server:
//       Replace with your deployed server URL
//       e.g. "https://fooddelivery-api.yourserver.com"
// ============================================================

class ApiConstants {
  // ── Base URL ───────────────────────────────────────────────
  // IMPORTANT: Change this IP when running on a physical device.
  // Android emulator uses 10.0.2.2 to reach the host PC's localhost.
  // Do NOT use 'localhost' — it would point to the phone itself.
  static const String baseUrl = 'http://10.0.2.2:5000';

  // ── Timeout Durations ──────────────────────────────────────
  // How long to wait before giving up on a slow network request.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ── Restaurant Endpoints ───────────────────────────────────
  static const String restaurants      = '/api/restaurants/';
  static const String restaurantSearch = '/api/restaurants/search';

  // Returns the URL for a single restaurant: /api/restaurants/<id>
  static String restaurantById(String id) => '/api/restaurants/$id';

  // ── Menu Endpoints ─────────────────────────────────────────
  // Returns menu items for a restaurant: /api/menu/restaurant/<id>
  static String menuByRestaurant(String restaurantId) =>
      '/api/menu/restaurant/$restaurantId';

  // Returns category list: /api/menu/restaurant/<id>/categories
  static String menuCategories(String restaurantId) =>
      '/api/menu/restaurant/$restaurantId/categories';

  // Returns a single menu item: /api/menu/<id>
  static String menuItemById(String itemId) => '/api/menu/$itemId';

  // Create/list menu items: /api/menu/
  static const String menuItems = '/api/menu/';

  // ── Review Endpoints ───────────────────────────────────────
  // Returns reviews for a restaurant: /api/reviews/restaurant/<id>
  static String reviewsByRestaurant(String restaurantId) =>
      '/api/reviews/restaurant/$restaurantId';

  // Returns a single review: /api/reviews/<id>
  static String reviewById(String reviewId) => '/api/reviews/$reviewId';

  // Create/list reviews: /api/reviews/
  static const String reviews = '/api/reviews/';

  // ── Health Check ───────────────────────────────────────────
  static const String health = '/api/health';
}