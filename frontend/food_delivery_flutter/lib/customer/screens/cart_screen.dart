// ignore_for_file: unused_import, unused_element
// ============================================================
// FILE: lib/customer/screens/cart_screen.dart
// PURPOSE: Shows the user's shopping cart with items, quantities,
//          prices, and checkout button.
//
// PHASE 3: Uses dummy data from CartModel.getDummyCart()
// PHASE 4: Replace dummy data with real API calls to /api/cart
// ============================================================

import 'package:flutter/material.dart';
import '../../models/cart_model.dart';
import '../../models/menu_item_model.dart';
import '../../services/api_service.dart';
import '../../widgets/cart_item_card.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // ── State Variables ────────────────────────────────────────
  CartModel? _cart;
  bool _isLoading = true;
  String? _errorMessage;

  // For updating quantities
  final Map<String, int> _quantityUpdates = {};

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // ── Load Cart Data ──────────────────────────────────────────
  // PHASE 3: Load dummy data
  // PHASE 4: Replace with API call to GET /api/cart
  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService.getCart();
      final cartJson = data['cart'] as Map<String, dynamic>;
      final cart = CartModel.fromJson(cartJson);
      setState(() {
        _cart = cart;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load cart from backend. Showing local cart.';
        _isLoading = false;
      });

      // Fallback to local demo cart for an operational UI.
      final cart = CartModel.getDummyCart();
      setState(() {
        _cart = cart;
      });
    }
  }

  // ── Update Item Quantity ────────────────────────────────────
  // PHASE 4: Replace with API call to PUT /api/cart/<item_id>
  Future<void> _updateItemQuantity(String itemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await _removeItem(itemId);
      return;
    }

    try {
      await ApiService.updateCartItem(
          cartItemId: itemId, quantity: newQuantity);
      await _loadCart();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quantity: $e')),
      );
    }
  }

  // ── Remove Item from Cart ───────────────────────────────────
  // PHASE 4: Replace with API call to DELETE /api/cart/<item_id>
  Future<void> _removeItem(String itemId) async {
    try {
      await ApiService.removeFromCart(itemId);
      await _loadCart();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removed from cart')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove item: $e')),
      );
    }
  }

  // ── Clear Entire Cart ───────────────────────────────────────
  // PHASE 4: Replace with API call to DELETE /api/cart
  Future<void> _clearCart() async {
    try {
      await ApiService.clearCart();
      await _loadCart();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart cleared')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear cart: $e')),
      );
    }
  }

  // ── Recalculate Total (Phase 3 helper) ─────────────────────
  void _recalculateTotal() {
    if (_cart == null) return;

    double total = 0.0;
    for (var item in _cart!.items) {
      final quantity = _quantityUpdates[item.id] ?? item.quantity;
      total += quantity * item.price;
    }

    _cart = CartModel(
      id: _cart!.id,
      userId: _cart!.userId,
      restaurantId: _cart!.restaurantId,
      items: _cart!.items,
      totalAmount: total,
      createdAt: _cart!.createdAt,
      updatedAt: _cart!.updatedAt,
    );
  }

  // ── Proceed to Checkout ─────────────────────────────────────
  void _proceedToCheckout() {
    if (_cart == null || _cart!.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(cart: _cart!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (_cart != null && _cart!.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearCart,
              tooltip: 'Clear Cart',
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar:
          _cart != null && _cart!.items.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCart,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_cart == null || _cart!.items.isEmpty) {
      return _buildEmptyCart();
    }

    return _buildCartList();
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add some delicious food to get started!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cart!.items.length,
      itemBuilder: (context, index) {
        final item = _cart!.items[index];
        final currentQuantity = _quantityUpdates[item.id] ?? item.quantity;

        return CartItemCard(
          item: item,
          quantity: currentQuantity,
          onQuantityChanged: (newQuantity) {
            _updateItemQuantity(item.id!, newQuantity);
          },
          onRemove: () => _removeItem(item.id!),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rs. ${_cart!.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _proceedToCheckout,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
