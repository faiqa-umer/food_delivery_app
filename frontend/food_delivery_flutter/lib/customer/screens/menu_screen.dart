// ============================================================
// FILE: lib/customer/screens/menu_screen.dart
// PURPOSE: Displays a restaurant's full menu, grouped by category.
//          Features:
//            - Horizontal scrollable category tab bar
//            - Filtered list of menu items per category
//            - Dietary badges (Veg / Vegan / Spicy)
//            - Discount price display
//            - Out-of-stock item handling
//
// RECEIVES: restaurantId (String) from RestaurantDetailsScreen
// PHASE 3:  Uses MenuItemModel.getDummyList()
// PHASE 4:  Replace with ApiService.getMenuByRestaurant(id)
// ============================================================

import 'package:flutter/material.dart';
import '../../models/menu_item_model.dart';
import '../../services/api_service.dart';
import '../../widgets/menu_item_card.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  final String restaurantId;

  const MenuScreen({super.key, required this.restaurantId});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with AutomaticKeepAliveClientMixin {
  // AutomaticKeepAliveClientMixin: keeps this tab's state alive
  // when switching between tabs. Without it, the menu reloads
  // every time the user switches to another tab and back.
  @override
  bool get wantKeepAlive => true;

  // ── State ──────────────────────────────────────────────────
  List<MenuItemModel> _allItems = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  // ── Load Menu Data ─────────────────────────────────────────
  Future<void> _loadMenu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService.getMenuByRestaurant(widget.restaurantId);
      final itemsJson = data['menu_items'] as List<dynamic>;
      final items = itemsJson
          .map((item) => MenuItemModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Extract unique categories from items
      final categories = items.map((i) => i.category).toSet().toList();
      categories.sort(); // Alphabetical order

      setState(() {
        _allItems = items;
        _categories = ['All', ...categories];
        _selectedCategory = 'All';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to load menu from backend. Showing local demo menu.';
        _isLoading = false;
      });

      // Fallback to demo data so the app remains usable.
      final items = MenuItemModel.getDummyList(widget.restaurantId);
      final categories = items.map((i) => i.category).toSet().toList();
      categories.sort();
      setState(() {
        _allItems = items;
        _categories = ['All', ...categories];
        _selectedCategory = 'All';
      });
    }
  }

  // ── Get items for the currently selected category ──────────
  List<MenuItemModel> get _filteredItems {
    if (_selectedCategory == 'All') return _allItems;
    return _allItems.where((i) => i.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_isLoading) return _buildLoadingState();
    if (_errorMessage != null) return _buildErrorState();

    return Column(
      children: [
        // ── Category Tab Strip ───────────────────────────────
        _buildCategoryStrip(),

        // ── Menu Item List ───────────────────────────────────
        Expanded(
          child: _filteredItems.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadMenu,
                  color: Colors.deepOrange,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return MenuItemCard(
                        item: item,
                        // Phase 3: show a snackbar as placeholder
                        // Phase 4: wire to CartService.addItem(item)
                        onAddToCart:
                            item.isAvailable ? () => _onAddToCart(item) : null,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // ── Category Strip (horizontal scrollable) ─────────────────
  Widget _buildCategoryStrip() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = category == _selectedCategory;

            // Count items in this category for the badge number
            final count = category == 'All'
                ? _allItems.length
                : _allItems.where((i) => i.category == category).length;

            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.deepOrange : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.deepOrange : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Item count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.3)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Add to Cart (Phase 3: just show a snackbar) ────────────
  Future<void> _onAddToCart(MenuItemModel item) async {
    try {
      await ApiService.addToCart(menuItemId: item.id, quantity: 1);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.name} added to cart!',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.deepOrange,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item to cart: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  // ── Loading State ──────────────────────────────────────────
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.deepOrange),
          SizedBox(height: 16),
          Text(
            'Loading menu...',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Error State ────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadMenu,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            'No items in this category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _selectedCategory = 'All'),
            child: const Text(
              'Show All Items',
              style: TextStyle(color: Colors.deepOrange),
            ),
          ),
        ],
      ),
    );
  }
}
