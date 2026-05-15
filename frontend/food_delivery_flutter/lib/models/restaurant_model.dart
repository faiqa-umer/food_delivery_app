// ============================================================
// FILE: lib/models/restaurant_model.dart
// PURPOSE: Dart data class that mirrors the restaurant JSON
//          returned by the Flask backend.
//
//          Every field name here MUST match the JSON key from
//          the backend's serialize_document() helper exactly.
//
// USAGE:
//   final restaurant = RestaurantModel.fromJson(jsonMap);
//   print(restaurant.name);
// ============================================================

class RestaurantModel {
  // ── Core Info ──────────────────────────────────────────────
  final String id;           // MongoDB _id (serialized as "id")
  final String name;
  final String description;
  final String cuisineType;  // maps to "cuisine_type"

  // ── Contact & Location ────────────────────────────────────
  final RestaurantAddress address;
  final String phone;
  final String email;

  // ── Media ─────────────────────────────────────────────────
  final String imageUrl;     // maps to "image_url"

  // ── Ratings ───────────────────────────────────────────────
  final double rating;
  final int totalReviews;    // maps to "total_reviews"

  // ── Operational ───────────────────────────────────────────
  final bool isOpen;                // maps to "is_open"
  final int deliveryTimeMin;        // maps to "delivery_time_min"
  final double deliveryFee;         // maps to "delivery_fee"
  final double minimumOrder;        // maps to "minimum_order"

  // ── Tags ──────────────────────────────────────────────────
  final List<String> tags;

  // ── Timestamps ────────────────────────────────────────────
  final String createdAt;           // maps to "created_at"
  final String updatedAt;           // maps to "updated_at"

  // ── Constructor ───────────────────────────────────────────
  // 'required' means the caller MUST provide this value.
  // This catches missing data at compile time, not runtime.
  const RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.cuisineType,
    required this.address,
    required this.phone,
    required this.email,
    required this.imageUrl,
    required this.rating,
    required this.totalReviews,
    required this.isOpen,
    required this.deliveryTimeMin,
    required this.deliveryFee,
    required this.minimumOrder,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── fromJson: JSON Map → RestaurantModel ──────────────────
  // Called when we receive data from the Flask API.
  // json['key'] ?? 'default' means: use the value if it exists,
  // otherwise use the default. Prevents null crashes.
  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id:              json['id']           ?? '',
      name:            json['name']         ?? '',
      description:     json['description']  ?? '',
      cuisineType:     json['cuisine_type'] ?? '',
      address: RestaurantAddress.fromJson(
        json['address'] as Map<String, dynamic>? ?? {},
      ),
      phone:           json['phone']        ?? '',
      email:           json['email']        ?? '',
      imageUrl:        json['image_url']    ?? '',
      rating:          (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews:    (json['total_reviews'] as num?)?.toInt() ?? 0,
      isOpen:          json['is_open']      ?? true,
      deliveryTimeMin: (json['delivery_time_min'] as num?)?.toInt() ?? 30,
      deliveryFee:     (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      minimumOrder:    (json['minimum_order'] as num?)?.toDouble() ?? 0.0,
      tags:            List<String>.from(json['tags'] ?? []),
      createdAt:       json['created_at']   ?? '',
      updatedAt:       json['updated_at']   ?? '',
    );
  }

  // ── toJson: RestaurantModel → JSON Map ────────────────────
  // Used when sending data TO the backend (e.g. create/update).
  Map<String, dynamic> toJson() {
    return {
      'id':               id,
      'name':             name,
      'description':      description,
      'cuisine_type':     cuisineType,
      'address':          address.toJson(),
      'phone':            phone,
      'email':            email,
      'image_url':        imageUrl,
      'rating':           rating,
      'total_reviews':    totalReviews,
      'is_open':          isOpen,
      'delivery_time_min': deliveryTimeMin,
      'delivery_fee':     deliveryFee,
      'minimum_order':    minimumOrder,
      'tags':             tags,
      'created_at':       createdAt,
      'updated_at':       updatedAt,
    };
  }

  // ── copyWith: returns a new model with some fields changed ─
  // Used in state management when you want to update one field
  // without reconstructing the entire object.
  RestaurantModel copyWith({
    String? id,
    String? name,
    String? description,
    String? cuisineType,
    RestaurantAddress? address,
    String? phone,
    String? email,
    String? imageUrl,
    double? rating,
    int? totalReviews,
    bool? isOpen,
    int? deliveryTimeMin,
    double? deliveryFee,
    double? minimumOrder,
    List<String>? tags,
    String? createdAt,
    String? updatedAt,
  }) {
    return RestaurantModel(
      id:              id             ?? this.id,
      name:            name           ?? this.name,
      description:     description    ?? this.description,
      cuisineType:     cuisineType    ?? this.cuisineType,
      address:         address        ?? this.address,
      phone:           phone          ?? this.phone,
      email:           email          ?? this.email,
      imageUrl:        imageUrl       ?? this.imageUrl,
      rating:          rating         ?? this.rating,
      totalReviews:    totalReviews   ?? this.totalReviews,
      isOpen:          isOpen         ?? this.isOpen,
      deliveryTimeMin: deliveryTimeMin ?? this.deliveryTimeMin,
      deliveryFee:     deliveryFee    ?? this.deliveryFee,
      minimumOrder:    minimumOrder   ?? this.minimumOrder,
      tags:            tags           ?? this.tags,
      createdAt:       createdAt      ?? this.createdAt,
      updatedAt:       updatedAt      ?? this.updatedAt,
    );
  }

  // ── Dummy data for UI testing (used in Phase 3 before APIs) ─
  static List<RestaurantModel> getDummyList() {
    return [
      RestaurantModel(
        id: 'dummy_001',
        name: 'Burger Palace',
        description: 'Best smash burgers in Rawalpindi, made fresh daily.',
        cuisineType: 'Fast Food',
        address: RestaurantAddress(
          street: '123 Murree Road', city: 'Rawalpindi',
          state: 'Punjab', zip: '46000',
        ),
        phone: '+92-51-1234567',
        email: 'burgerpalace@example.com',
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800',
        rating: 4.5,
        totalReviews: 128,
        isOpen: true,
        deliveryTimeMin: 25,
        deliveryFee: 50.0,
        minimumOrder: 300.0,
        tags: ['burgers', 'fast food', 'halal'],
        createdAt: '2024-01-01T00:00:00',
        updatedAt: '2024-01-01T00:00:00',
      ),
      RestaurantModel(
        id: 'dummy_002',
        name: 'Pizza Casa',
        description: 'Authentic Italian wood-fired pizzas.',
        cuisineType: 'Italian',
        address: RestaurantAddress(
          street: '45 Jinnah Avenue', city: 'Rawalpindi',
          state: 'Punjab', zip: '46000',
        ),
        phone: '+92-51-9876543',
        email: 'pizzacasa@example.com',
        imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800',
        rating: 4.2,
        totalReviews: 89,
        isOpen: true,
        deliveryTimeMin: 35,
        deliveryFee: 80.0,
        minimumOrder: 500.0,
        tags: ['pizza', 'italian', 'halal'],
        createdAt: '2024-01-01T00:00:00',
        updatedAt: '2024-01-01T00:00:00',
      ),
      RestaurantModel(
        id: 'dummy_003',
        name: 'Desi Darbar',
        description: 'Traditional Pakistani cuisine cooked with love.',
        cuisineType: 'Pakistani',
        address: RestaurantAddress(
          street: '78 Raja Bazar', city: 'Rawalpindi',
          state: 'Punjab', zip: '46000',
        ),
        phone: '+92-51-5551234',
        email: 'desidarbar@example.com',
        imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800',
        rating: 4.7,
        totalReviews: 203,
        isOpen: false,
        deliveryTimeMin: 45,
        deliveryFee: 60.0,
        minimumOrder: 400.0,
        tags: ['desi', 'biryani', 'karahi', 'halal'],
        createdAt: '2024-01-01T00:00:00',
        updatedAt: '2024-01-01T00:00:00',
      ),
    ];
  }
}

// ── Nested Address Model ───────────────────────────────────────
// Stored as a sub-document inside the restaurant document.
class RestaurantAddress {
  final String street;
  final String city;
  final String state;
  final String zip;

  const RestaurantAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
  });

  factory RestaurantAddress.fromJson(Map<String, dynamic> json) {
    return RestaurantAddress(
      street: json['street'] ?? '',
      city:   json['city']   ?? '',
      state:  json['state']  ?? '',
      zip:    json['zip']    ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'street': street,
    'city':   city,
    'state':  state,
    'zip':    zip,
  };

  // Convenience getter: "123 Murree Road, Rawalpindi"
  String get fullAddress => '$street, $city';
}