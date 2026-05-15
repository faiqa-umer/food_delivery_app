// ============================================================
// FILE: lib/models/menu_item_model.dart
// PURPOSE: Dart class mirroring the menu_item JSON from Flask.
//          Field names match backend serialize_document() output.
// ============================================================

class MenuItemModel {
  // ── Identifiers ────────────────────────────────────────────
  final String id;
  final String restaurantId;    // maps to "restaurant_id"

  // ── Core Info ──────────────────────────────────────────────
  final String name;
  final String description;
  final double price;
  final double discountedPrice;  // maps to "discounted_price"
  final double discountPercent;  // maps to "discount_percent"

  // ── Categorization ─────────────────────────────────────────
  final String category;

  // ── Media ──────────────────────────────────────────────────
  final String imageUrl;         // maps to "image_url"

  // ── Availability & Dietary ─────────────────────────────────
  final bool isAvailable;        // maps to "is_available"
  final bool isVegetarian;       // maps to "is_vegetarian"
  final bool isVegan;            // maps to "is_vegan"
  final bool isSpicy;            // maps to "is_spicy"

  // ── Details ────────────────────────────────────────────────
  final int calories;
  final int preparationTimeMin;  // maps to "preparation_time_min"

  // ── Timestamps ─────────────────────────────────────────────
  final String createdAt;
  final String updatedAt;

  const MenuItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.discountedPrice,
    required this.discountPercent,
    required this.category,
    required this.imageUrl,
    required this.isAvailable,
    required this.isVegetarian,
    required this.isVegan,
    required this.isSpicy,
    required this.calories,
    required this.preparationTimeMin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id:                  json['id']                ?? '',
      restaurantId:        json['restaurant_id']     ?? '',
      name:                json['name']              ?? '',
      description:         json['description']       ?? '',
      price:               (json['price'] as num?)?.toDouble() ?? 0.0,
      discountedPrice:     (json['discounted_price'] as num?)?.toDouble() ?? 0.0,
      discountPercent:     (json['discount_percent'] as num?)?.toDouble() ?? 0.0,
      category:            json['category']          ?? '',
      imageUrl:            json['image_url']         ?? '',
      isAvailable:         json['is_available']      ?? true,
      isVegetarian:        json['is_vegetarian']     ?? false,
      isVegan:             json['is_vegan']          ?? false,
      isSpicy:             json['is_spicy']          ?? false,
      calories:            (json['calories'] as num?)?.toInt() ?? 0,
      preparationTimeMin:  (json['preparation_time_min'] as num?)?.toInt() ?? 15,
      createdAt:           json['created_at']        ?? '',
      updatedAt:           json['updated_at']        ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id':                  id,
    'restaurant_id':       restaurantId,
    'name':                name,
    'description':         description,
    'price':               price,
    'discounted_price':    discountedPrice,
    'discount_percent':    discountPercent,
    'category':            category,
    'image_url':           imageUrl,
    'is_available':        isAvailable,
    'is_vegetarian':       isVegetarian,
    'is_vegan':            isVegan,
    'is_spicy':            isSpicy,
    'calories':            calories,
    'preparation_time_min': preparationTimeMin,
    'created_at':          createdAt,
    'updated_at':          updatedAt,
  };

  // ── Convenience getter ─────────────────────────────────────
  // Returns true if item has any discount applied
  bool get hasDiscount => discountPercent > 0;

  // ── Dummy data for Phase 3 UI testing ─────────────────────
  static List<MenuItemModel> getDummyList(String restaurantId) {
    return [
      MenuItemModel(
        id: 'menu_001', restaurantId: restaurantId,
        name: 'Classic Cheese Burger',
        description: 'Juicy beef patty with cheddar, lettuce, tomato & special sauce',
        price: 550.0, discountedPrice: 495.0, discountPercent: 10.0,
        category: 'Burgers',
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
        isAvailable: true, isVegetarian: false, isVegan: false, isSpicy: false,
        calories: 680, preparationTimeMin: 12,
        createdAt: '', updatedAt: '',
      ),
      MenuItemModel(
        id: 'menu_002', restaurantId: restaurantId,
        name: 'Spicy Crispy Burger',
        description: 'Crispy fried chicken with jalapeños and sriracha mayo',
        price: 620.0, discountedPrice: 620.0, discountPercent: 0.0,
        category: 'Burgers',
        imageUrl: 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=400',
        isAvailable: true, isVegetarian: false, isVegan: false, isSpicy: true,
        calories: 720, preparationTimeMin: 15,
        createdAt: '', updatedAt: '',
      ),
      MenuItemModel(
        id: 'menu_003', restaurantId: restaurantId,
        name: 'Loaded Fries',
        description: 'Crispy fries with cheese sauce and jalapenos',
        price: 320.0, discountedPrice: 320.0, discountPercent: 0.0,
        category: 'Sides',
        imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=400',
        isAvailable: true, isVegetarian: true, isVegan: false, isSpicy: true,
        calories: 410, preparationTimeMin: 8,
        createdAt: '', updatedAt: '',
      ),
      MenuItemModel(
        id: 'menu_004', restaurantId: restaurantId,
        name: 'Cola Drink',
        description: 'Ice-cold cola 500ml',
        price: 120.0, discountedPrice: 120.0, discountPercent: 0.0,
        category: 'Drinks',
        imageUrl: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400',
        isAvailable: true, isVegetarian: true, isVegan: true, isSpicy: false,
        calories: 150, preparationTimeMin: 2,
        createdAt: '', updatedAt: '',
      ),
      MenuItemModel(
        id: 'menu_005', restaurantId: restaurantId,
        name: 'Chocolate Shake',
        description: 'Rich thick chocolate milkshake with whipped cream',
        price: 280.0, discountedPrice: 252.0, discountPercent: 10.0,
        category: 'Drinks',
        imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=400',
        isAvailable: true, isVegetarian: true, isVegan: false, isSpicy: false,
        calories: 480, preparationTimeMin: 5,
        createdAt: '', updatedAt: '',
      ),
      MenuItemModel(
        id: 'menu_006', restaurantId: restaurantId,
        name: 'Brownie Sundae',
        description: 'Warm brownie with vanilla ice cream and chocolate drizzle',
        price: 350.0, discountedPrice: 350.0, discountPercent: 0.0,
        category: 'Desserts',
        imageUrl: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400',
        isAvailable: false, isVegetarian: true, isVegan: false, isSpicy: false,
        calories: 560, preparationTimeMin: 10,
        createdAt: '', updatedAt: '',
      ),
    ];
  }
}