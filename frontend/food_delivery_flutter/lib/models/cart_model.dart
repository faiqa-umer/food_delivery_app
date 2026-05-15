// ============================================================
// FILE: lib/models/cart_model.dart
// PURPOSE: Dart data class for cart operations.
//          Mirrors the cart JSON from the Flask backend.
//
// USAGE:
//   final cart = CartModel.fromJson(jsonMap);
//   print(cart.totalAmount);
// ============================================================

class CartModel {
  final String? id;
  final String userId;
  final String? restaurantId;
  final List<CartItemModel> items;
  final double totalAmount;
  final String createdAt;
  final String updatedAt;

  const CartModel({
    this.id,
    required this.userId,
    this.restaurantId,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── JSON Serialization ─────────────────────────────────────
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      restaurantId: json['restaurant_id'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) =>
                  CartItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (json['total_amount'] as num).toDouble(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // ── Dummy Data for Phase 3 Testing ─────────────────────────
  static CartModel getDummyCart() {
    return CartModel(
      id: 'cart123',
      userId: 'user123',
      restaurantId: 'rest456',
      items: [
        CartItemModel.getDummyItem(),
        CartItemModel.getDummyItem2(),
      ],
      totalAmount: 31.48,
      createdAt: '2024-01-15T10:30:00Z',
      updatedAt: '2024-01-15T10:35:00Z',
    );
  }

  static List<CartModel> getDummyList() {
    return [getDummyCart()];
  }
}

// ── Cart Item Sub-model ──────────────────────────────────────
class CartItemModel {
  final String? id;
  final String menuItemId;
  final int quantity;
  final double price;
  final String specialInstructions;

  const CartItemModel({
    this.id,
    required this.menuItemId,
    required this.quantity,
    required this.price,
    required this.specialInstructions,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String?,
      menuItemId: json['menu_item_id'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      specialInstructions: json['special_instructions'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_item_id': menuItemId,
      'quantity': quantity,
      'price': price,
      'special_instructions': specialInstructions,
    };
  }

  static CartItemModel getDummyItem() {
    return CartItemModel(
      id: 'item001',
      menuItemId: 'menu789',
      quantity: 2,
      price: 15.99,
      specialInstructions: 'Extra spicy',
    );
  }

  static CartItemModel getDummyItem2() {
    return CartItemModel(
      id: 'item002',
      menuItemId: 'menu790',
      quantity: 1,
      price: 8.50,
      specialInstructions: '',
    );
  }
}
