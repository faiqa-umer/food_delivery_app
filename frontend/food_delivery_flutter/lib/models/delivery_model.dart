// ============================================================
// FILE: lib/models/delivery_model.dart
// PURPOSE: Dart data class for delivery operations.
//          Mirrors the delivery JSON from the Flask backend.
//
// USAGE:
//   final delivery = DeliveryModel.fromJson(jsonMap);
//   print(delivery.status);
// ============================================================

import 'order_model.dart'; // For DeliveryAddress

class DeliveryModel {
  final String id;
  final String orderId;
  final String? riderId;
  final String status;
  final DeliveryLocation currentLocation;
  final String? estimatedDeliveryTime;
  final String? actualDeliveryTime;
  final String? pickupTime;
  final String? deliveryTime;
  final DeliveryAddress? deliveryAddress;
  final String? customerPhone;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  // Additional fields for customer rating
  final double? customerRating;
  final String? customerFeedback;

  const DeliveryModel({
    required this.id,
    required this.orderId,
    this.riderId,
    required this.status,
    required this.currentLocation,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    this.pickupTime,
    this.deliveryTime,
    this.deliveryAddress,
    this.customerPhone,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.customerRating,
    this.customerFeedback,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      riderId: json['rider_id'] as String?,
      status: json['status'] as String,
      currentLocation: DeliveryLocation.fromJson(
          json['current_location'] as Map<String, dynamic>),
      estimatedDeliveryTime: json['estimated_delivery_time'] as String?,
      actualDeliveryTime: json['actual_delivery_time'] as String?,
      pickupTime: json['pickup_time'] as String?,
      deliveryTime: json['delivery_time'] as String?,
      deliveryAddress: json['delivery_address'] != null
          ? DeliveryAddress.fromJson(
              json['delivery_address'] as Map<String, dynamic>)
          : null,
      customerPhone: json['customer_phone'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      customerRating: json['customer_rating'] != null
          ? (json['customer_rating'] as num).toDouble()
          : null,
      customerFeedback: json['customer_feedback'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'rider_id': riderId,
      'status': status,
      'current_location': currentLocation.toJson(),
      'estimated_delivery_time': estimatedDeliveryTime,
      'actual_delivery_time': actualDeliveryTime,
      'pickup_time': pickupTime,
      'delivery_time': deliveryTime,
      'delivery_address': deliveryAddress?.toJson(),
      'customer_phone': customerPhone,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'customer_rating': customerRating,
      'customer_feedback': customerFeedback,
    };
  }

  static DeliveryModel getDummyDelivery() {
    return DeliveryModel(
      id: 'del001',
      orderId: 'order001',
      riderId: 'rider123',
      status: 'assigned',
      currentLocation: DeliveryLocation.getDummyLocation(),
      estimatedDeliveryTime: '2024-01-15T13:00:00Z',
      actualDeliveryTime: null,
      pickupTime: null,
      deliveryTime: null,
      deliveryAddress: DeliveryAddress.getDummyAddress(),
      customerPhone: '+92-300-1234567',
      notes: 'Ring the doorbell twice',
      createdAt: '2024-01-15T12:05:00Z',
      updatedAt: '2024-01-15T12:10:00Z',
    );
  }

  static List<DeliveryModel> getDummyList() {
    return [
      getDummyDelivery(),
      DeliveryModel(
        id: 'del002',
        orderId: 'order002',
        riderId: 'rider456',
        status: 'out_for_delivery',
        currentLocation: DeliveryLocation.getDummyLocation2(),
        estimatedDeliveryTime: '2024-01-15T14:00:00Z',
        actualDeliveryTime: null,
        pickupTime: '2024-01-15T13:15:00Z',
        deliveryTime: null,
        deliveryAddress: DeliveryAddress.getDummyAddress2(),
        customerPhone: '+92-301-9876543',
        notes: 'Apartment 5B, call when arrived',
        createdAt: '2024-01-15T13:05:00Z',
        updatedAt: '2024-01-15T13:35:00Z',
      ),
      DeliveryModel(
        id: 'del003',
        orderId: 'order003',
        riderId: 'rider123',
        status: 'picked_up',
        currentLocation: DeliveryLocation.getDummyLocation(),
        estimatedDeliveryTime: '2024-01-15T15:00:00Z',
        actualDeliveryTime: null,
        pickupTime: '2024-01-15T14:20:00Z',
        deliveryTime: null,
        deliveryAddress: DeliveryAddress.getDummyAddress(),
        customerPhone: '+92-302-5556666',
        notes: null,
        createdAt: '2024-01-15T14:05:00Z',
        updatedAt: '2024-01-15T14:25:00Z',
      ),
    ];
  }

  static List<DeliveryModel> getDummyDeliveries() {
    return getDummyList();
  }

  // ── Helper Methods ─────────────────────────────────────────
  bool get isAssigned => status == 'assigned';
  bool get isPickedUp => status == 'picked_up';
  bool get isOutForDelivery => status == 'out_for_delivery';
  bool get isDelivered => status == 'delivered';

  String get statusDisplayText {
    switch (status) {
      case 'assigned':
        return 'Rider Assigned';
      case 'picked_up':
        return 'Order Picked Up';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  Duration? get estimatedDuration {
    if (estimatedDeliveryTime == null) return null;
    final estimated = DateTime.parse(estimatedDeliveryTime!);
    final now = DateTime.now();
    return estimated.difference(now);
  }

  bool get isDelayed {
    final duration = estimatedDuration;
    return duration != null && duration.isNegative;
  }
}

// ── Delivery Location Sub-model ─────────────────────────────
class DeliveryLocation {
  final double lat;
  final double lng;

  const DeliveryLocation({
    required this.lat,
    required this.lng,
  });

  factory DeliveryLocation.fromJson(Map<String, dynamic> json) {
    return DeliveryLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  static DeliveryLocation getDummyLocation() {
    return DeliveryLocation(
      lat: 33.6844,
      lng: 73.0479,
    );
  }

  static DeliveryLocation getDummyLocation2() {
    return DeliveryLocation(
      lat: 33.7294,
      lng: 73.0931,
    );
  }
}
