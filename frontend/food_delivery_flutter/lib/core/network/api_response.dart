// ============================================================
// FILE: lib/core/network/api_response.dart
// PURPOSE: Generic wrapper that mirrors the Flask API response shape.
//
// Every Flask endpoint returns:
//   {
//     "status":  "success" | "error",
//     "message": "...",
//     "data":    { ... }   ← the actual payload
//   }
//
// This class wraps both successful data AND errors into one
// clean type that every service function returns.
//
// USAGE in a service:
//   final result = await restaurantService.getAll();
//   if (result.isSuccess) {
//     final restaurants = result.data!;
//   } else {
//     showError(result.message);
//   }
// ============================================================

// T = the type of data we expect back (e.g. List<RestaurantModel>)
class ApiResponse<T> {
  final bool isSuccess;   // true = "status": "success"
  final String message;  // Human-readable message from Flask
  final T? data;         // The actual payload (null on error)
  final int statusCode;  // HTTP status code (200, 201, 404, 500...)
  final List<dynamic> errors; // Field-level errors from Flask

  // Private constructor — use factory constructors below
  const ApiResponse._({
    required this.isSuccess,
    required this.message,
    required this.statusCode,
    this.data,
    this.errors = const [],
  });

  // ── Success factory ─────────────────────────────────────────
  // Called when Flask returns status: "success"
  factory ApiResponse.success({
    required T data,
    required String message,
    int statusCode = 200,
  }) {
    return ApiResponse._(
      isSuccess:  true,
      message:    message,
      data:       data,
      statusCode: statusCode,
    );
  }

  // ── Error factory ───────────────────────────────────────────
  // Called when Flask returns status: "error" OR network fails
  factory ApiResponse.error({
    required String message,
    int statusCode = 400,
    List<dynamic> errors = const [],
  }) {
    return ApiResponse._(
      isSuccess:  false,
      message:    message,
      data:       null,
      statusCode: statusCode,
      errors:     errors,
    );
  }

  // ── Convenience getter ──────────────────────────────────────
  bool get isError => !isSuccess;

  @override
  String toString() =>
      'ApiResponse(isSuccess: $isSuccess, message: $message, statusCode: $statusCode)';
}