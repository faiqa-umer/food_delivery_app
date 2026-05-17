// ============================================================
// FILE: lib/models/user_model.dart
// PURPOSE: User data model for authentication and user profile
// ============================================================

class User {
  final String userId;
  final String email;
  final String name;
  final String? phone;
  final String? address;
  final String? city;
  final String? role; // 'customer', 'restaurant_owner', 'delivery_agent'
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? totalOrders;

  User({
    required this.userId,
    required this.email,
    required this.name,
    this.phone,
    this.address,
    this.city,
    this.role = 'customer',
    required this.createdAt,
    required this.updatedAt,
    this.totalOrders = 0,
  });

  /// Convert User object to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'total_orders': totalOrders,
    };
  }

  /// Create User object from JSON (API responses)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      role: json['role'] ?? 'customer',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      totalOrders: json['total_orders'] ?? 0,
    );
  }

  /// Create a copy of User with updated fields
  User copyWith({
    String? userId,
    String? email,
    String? name,
    String? phone,
    String? address,
    String? city,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalOrders,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalOrders: totalOrders ?? this.totalOrders,
    );
  }

  /// Check if user profile is complete
  bool isProfileComplete() {
    return phone != null &&
        address != null &&
        city != null;
  }

  /// Get user's full address
  String getFullAddress() {
    List<String> parts = [];
    if (address != null) parts.add(address!);
    if (city != null) parts.add(city!);
    return parts.join(', ');
  }

  /// Check if user is a customer
  bool isCustomer() => role == 'customer';

  /// Check if user is a restaurant owner
  bool isRestaurantOwner() => role == 'restaurant_owner';

  /// Check if user is a delivery agent
  bool isDeliveryAgent() => role == 'delivery_agent';

  @override
  String toString() {
    return 'User(userId: $userId, email: $email, name: $name, role: $role)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          email == other.email;

  @override
  int get hashCode => userId.hashCode ^ email.hashCode;
}


// ============================================================
// USER REGISTRATION MODEL (for signup)
// ============================================================

class UserRegistration {
  final String email;
  final String password;
  final String name;
  final String? phone;

  UserRegistration({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
    };
  }
}


// ============================================================
// USER LOGIN MODEL (for signin)
// ============================================================

class UserLogin {
  final String email;
  final String password;

  UserLogin({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}


// ============================================================
// LOGIN RESPONSE MODEL
// ============================================================

class LoginResponse {
  final String status;
  final String message;
  final String? token;
  final String? userId;
  final String? email;
  final String? name;
  final User? user;

  LoginResponse({
    required this.status,
    required this.message,
    this.token,
    this.userId,
    this.email,
    this.name,
    this.user,
  });

  bool get isSuccess => status.toLowerCase() == 'success';

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      token: json['token'],
      userId: json['user_id'],
      email: json['email'],
      name: json['name'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'token': token,
      'user_id': userId,
      'email': email,
      'name': name,
      'user': user?.toJson(),
    };
  }
}


// ============================================================
// AUTH STATE (for Provider/Riverpod state management)
// ============================================================

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  /// Check if user has valid token
  bool get isLoggedIn => isAuthenticated && token != null && user != null;

  /// Create a copy with updated fields
  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}


// ============================================================
// PROFILE UPDATE MODEL
// ============================================================

class ProfileUpdate {
  final String? name;
  final String? phone;
  final String? address;
  final String? city;

  ProfileUpdate({
    this.name,
    this.phone,
    this.address,
    this.city,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
    };
  }
}