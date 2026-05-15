// ============================================================
// FILE: lib/models/order_model.dart
// PURPOSE: Dart data class for order operations.
//          Mirrors the order JSON from the Flask backend.
//
// USAGE:
//   final order = OrderModel.fromJson(jsonMap);
//   print(order.status);
// ============================================================

class OrderModel {
  final String id;
  final String userId;
  final String restaurantId;
  final List<String> items; // Order item IDs
  final double totalAmount;
  final DeliveryAddress deliveryAddress;
  final String? paymentId;
  final String? deliveryId;
  final String status;
  final String createdAt;
  final String updatedAt;

  // Additional fields for full order details
  final List<OrderItemModel>? itemsDetails;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    this.paymentId,
    this.deliveryId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.itemsDetails,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      restaurantId: json['restaurant_id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      deliveryAddress: DeliveryAddress.fromJson(
          json['delivery_address'] as Map<String, dynamic>),
      paymentId: json['payment_id'] as String?,
      deliveryId: json['delivery_id'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      itemsDetails: json['items_details'] != null
          ? (json['items_details'] as List<dynamic>)
              .map((item) =>
                  OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'items': items,
      'total_amount': totalAmount,
      'delivery_address': deliveryAddress.toJson(),
      'payment_id': paymentId,
      'delivery_id': deliveryId,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'items_details': itemsDetails?.map((item) => item.toJson()).toList(),
    };
  }

  static OrderModel getDummyOrder() {
    return OrderModel(
      id: 'order001',
      userId: 'user123',
      restaurantId: 'rest456',
      items: ['item001', 'item002'],
      totalAmount: 40.48,
      deliveryAddress: DeliveryAddress.getDummyAddress(),
      paymentId: 'pay001',
      deliveryId: 'del001',
      status: 'confirmed',
      createdAt: '2024-01-15T12:00:00Z',
      updatedAt: '2024-01-15T12:05:00Z',
      itemsDetails: [
        OrderItemModel.getDummyItem(),
        OrderItemModel.getDummyItem2(),
      ],
    );
  }

  static List<OrderModel> getDummyList() {
    return [
      getDummyOrder(),
      OrderModel(
        id: 'order002',
        userId: 'user456',
        restaurantId: 'rest789',
        items: ['item003'],
        totalAmount: 38.97,
        deliveryAddress: DeliveryAddress.getDummyAddress2(),
        paymentId: 'pay002',
        deliveryId: 'del002',
        status: 'out_for_delivery',
        createdAt: '2024-01-15T13:00:00Z',
        updatedAt: '2024-01-15T13:30:00Z',
      ),
    ];
  }
}

// ── Order Item Sub-model ─────────────────────────────────────
class OrderItemModel {
  final String id;
  final String orderId;
  final String menuItemId;
  final int quantity;
  final double price;
  final String specialInstructions;
  final String createdAt;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.quantity,
    required this.price,
    required this.specialInstructions,
    required this.createdAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      menuItemId: json['menu_item_id'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      specialInstructions: json['special_instructions'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'menu_item_id': menuItemId,
      'quantity': quantity,
      'price': price,
      'special_instructions': specialInstructions,
      'created_at': createdAt,
    };
  }

  static OrderItemModel getDummyItem() {
    return OrderItemModel(
      id: 'item001',
      orderId: 'order001',
      menuItemId: 'menu789',
      quantity: 2,
      price: 15.99,
      specialInstructions: 'Extra spicy',
      createdAt: '2024-01-15T12:00:00Z',
    );
  }

  static OrderItemModel getDummyItem2() {
    return OrderItemModel(
      id: 'item002',
      orderId: 'order001',
      menuItemId: 'menu790',
      quantity: 1,
      price: 8.50,
      specialInstructions: '',
      createdAt: '2024-01-15T12:00:00Z',
    );
  }
}

// ── Delivery Address Sub-model ──────────────────────────────
class DeliveryAddress {
  final String street;
  final String city;
  final String state;
  final String zip;

  const DeliveryAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zip: json['zip'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zip': zip,
    };
  }

  static DeliveryAddress getDummyAddress() {
    return DeliveryAddress(
      street: '123 Main Street',
      city: 'Rawalpindi',
      state: 'Punjab',
      zip: '46000',
    );
  }

  static DeliveryAddress getDummyAddress2() {
    return DeliveryAddress(
      street: '421 Food Lane',
      city: 'Islamabad',
      state: 'ICT',
      zip: '44000',
    );
  }

  String get fullAddress {
    return '$street, $city, $state $zip';
  }
}
