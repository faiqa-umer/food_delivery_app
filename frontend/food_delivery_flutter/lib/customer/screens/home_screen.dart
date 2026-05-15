// ============================================================
// FILE: lib/customer/screens/home_screen.dart
// PURPOSE: The main screen users see after login.
//          Shows a search bar, cuisine filter chips,
//          and a scrollable list of restaurant cards.
//
// PHASE 3: Uses dummy data from RestaurantModel.getDummyList()
// PHASE 4: Replace dummy data with real API calls
// ============================================================

import 'package:flutter/material.dart';
import '../../models/restaurant_model.dart';
import '../../services/api_service.dart';
import '../../widgets/restaurant_card.dart';
import 'restaurant_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── State Variables ────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();

  // Full list loaded from API (dummy in Phase 3)
  List<RestaurantModel> _allRestaurants = [];

  // Filtered list shown to the user
  List<RestaurantModel> _filteredRestaurants = [];

  // Currently selected cuisine filter chip ("All", "Fast Food", etc.)
  String _selectedCuisine = 'All';

  // Available cuisine categories (derived from the restaurant list)
  List<String> _cuisineFilters = ['All'];

  // Loading and error state — used for loading indicators
  bool _isLoading = true;
  String? _errorMessage;

  // ── Cuisine filter chips list ──────────────────────────────
  // In Phase 4, this will be populated dynamically from API data.
  // For now it's hardcoded to match the dummy restaurant data.
  static const List<String> _predefinedFilters = [
    'All',
    'Fast Food',
    'Italian',
    'Pakistani',
    'Chinese',
    'Desi',
  ];

  @override
  void initState() {
    super.initState();
    _loadRestaurants();

    // Listen for search text changes and filter in real time
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ── Load Restaurants (dummy for Phase 3) ──────────────────
  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getRestaurants();
      final restaurantsJson = response['restaurants'] as List<dynamic>;
      final restaurants = restaurantsJson
          .map((item) => RestaurantModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final cuisines = restaurants.map((r) => r.cuisineType).toSet().toList()
        ..sort();

      setState(() {
        _allRestaurants = restaurants;
        _filteredRestaurants = restaurants;
        _cuisineFilters = ['All', ...cuisines];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to load restaurants from backend. Showing local demo restaurants.';
        _isLoading = false;
      });

      final data = RestaurantModel.getDummyList();
      final cuisines = data.map((r) => r.cuisineType).toSet().toList()..sort();
      setState(() {
        _allRestaurants = data;
        _filteredRestaurants = data;
        _cuisineFilters = ['All', ...cuisines];
      });
    }
  }

  // ── Filter Logic ───────────────────────────────────────────
  // Called when search text changes OR a cuisine chip is tapped
  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredRestaurants = _allRestaurants.where((r) {
        // Cuisine filter
        final matchesCuisine = _selectedCuisine == 'All' ||
            r.cuisineType.toLowerCase() == _selectedCuisine.toLowerCase();

        // Search filter: name, description, cuisine, or tags
        final matchesSearch = query.isEmpty ||
            r.name.toLowerCase().contains(query) ||
            r.description.toLowerCase().contains(query) ||
            r.cuisineType.toLowerCase().contains(query) ||
            r.tags.any((t) => t.toLowerCase().contains(query));

        return matchesCuisine && matchesSearch;
      }).toList();
    });
  }

  void _onSearchChanged() => _applyFilters();

  void _onCuisineSelected(String cuisine) {
    setState(() => _selectedCuisine = cuisine);
    _applyFilters();
  }

  // ── Navigate to Restaurant Details ─────────────────────────
  void _navigateToDetails(RestaurantModel restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantDetailsScreen(restaurant: restaurant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: RefreshIndicator(
        // Pull-to-refresh reloads the restaurant list
        onRefresh: _loadRestaurants,
        color: Colors.deepOrange,
        child: CustomScrollView(
          slivers: [
            // ── App Bar ─────────────────────────────────────────
            _buildSliverAppBar(),

            // ── Search Bar ──────────────────────────────────────
            SliverToBoxAdapter(child: _buildSearchBar()),

            // ── Cuisine Filter Chips ─────────────────────────────
            SliverToBoxAdapter(child: _buildCuisineFilters()),

            // ── Section Label ────────────────────────────────────
            SliverToBoxAdapter(child: _buildSectionHeader()),

            // ── Main Content ─────────────────────────────────────
            _isLoading
                ? SliverToBoxAdapter(child: _buildLoadingState())
                : _errorMessage != null
                    ? SliverToBoxAdapter(child: _buildErrorState())
                    : _filteredRestaurants.isEmpty
                        ? SliverToBoxAdapter(child: _buildEmptyState())
                        : _buildRestaurantList(),
          ],
        ),
      ),
    );
  }

  // ── Sliver App Bar (collapses on scroll) ───────────────────
  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.deepOrange,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
        title: const Text(
          'Food Delivery',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE65100), Color(0xFFFF7043)],
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.only(left: 20, top: 55),
            child: Text(
              '🍔  What are you craving today?',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ),
      ),
      actions: [
        // Notification bell — placeholder for future feature
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  // ── Search Bar ─────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search restaurants, cuisines...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepOrange, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── Cuisine Filter Chips ───────────────────────────────────
  Widget _buildCuisineFilters() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _cuisineFilters.length,
        itemBuilder: (context, index) {
          final cuisine = _cuisineFilters[index];
          final isSelected = cuisine == _selectedCuisine;

          return GestureDetector(
            onTap: () => _onCuisineSelected(cuisine),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepOrange : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.deepOrange : Colors.grey[300]!,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  cuisine,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section Header ─────────────────────────────────────────
  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Text(
            _selectedCuisine == 'All'
                ? 'All Restaurants'
                : '$_selectedCuisine Restaurants',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          if (!_isLoading)
            Text(
              '${_filteredRestaurants.length} found',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }

  // ── Restaurant List ────────────────────────────────────────
  SliverList _buildRestaurantList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Add bottom padding after the last card
          if (index == _filteredRestaurants.length) {
            return const SizedBox(height: 24);
          }
          final restaurant = _filteredRestaurants[index];
          return RestaurantCard(
            restaurant: restaurant,
            onTap: () => _navigateToDetails(restaurant),
          );
        },
        childCount: _filteredRestaurants.length + 1, // +1 for bottom padding
      ),
    );
  }

  // ── Loading State ──────────────────────────────────────────
  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: Colors.deepOrange),
            SizedBox(height: 16),
            Text(
              'Finding restaurants near you...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error State ────────────────────────────────────────────
  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: const TextStyle(color: Colors.grey, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRestaurants,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State (no results) ───────────────────────────────
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text(
              'No restaurants found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search or cuisine filter.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                _searchController.clear();
                _onCuisineSelected('All');
              },
              child: const Text(
                'Clear Filters',
                style: TextStyle(color: Colors.deepOrange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
