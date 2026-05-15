// ============================================================
// FILE: lib/customer/screens/restaurant_details_screen.dart
// PURPOSE: Full detail view for a selected restaurant.
//          Contains:
//            - Hero image with back button
//            - Restaurant info (name, rating, address, hours)
//            - Tab bar: [Menu] [Reviews] [Info]
//            - Each tab loads its own screen widget
//
// RECEIVES: RestaurantModel from HomeScreen via constructor
// ============================================================

import 'package:flutter/material.dart';
import '../../models/restaurant_model.dart';
import '../../widgets/star_rating_widget.dart';
import 'menu_screen.dart';
import 'review_screen.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  // The restaurant data passed from the home screen card tap
  final RestaurantModel restaurant;

  const RestaurantDetailsScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen>
    with SingleTickerProviderStateMixin {
  // TabController manages the Menu / Reviews / Info tabs
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 3 tabs: Menu, Reviews, Info
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Convenience getter — avoids typing widget.restaurant everywhere
  RestaurantModel get _r => widget.restaurant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: NestedScrollView(
        // NestedScrollView lets the header scroll away while
        // the tab content stays scrollable independently.
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── Collapsing Hero Image App Bar ──────────────────
          _buildSliverAppBar(),

          // ── Restaurant Info Card (pinned below app bar) ────
          SliverToBoxAdapter(child: _buildInfoCard()),

          // ── Tab Bar ────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,   // Tab bar stays visible when scrolling
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Colors.deepOrange,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.deepOrange,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: '🍽  Menu'),
                  Tab(text: '⭐ Reviews'),
                  Tab(text: 'ℹ  Info'),
                ],
              ),
            ),
          ),
        ],

        // ── Tab Content ────────────────────────────────────────
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Menu Screen
            MenuScreen(restaurantId: _r.id),

            // Tab 2: Reviews Screen
            ReviewScreen(
              restaurantId: _r.id,
              restaurantName: _r.name,
            ),

            // Tab 3: Restaurant Info
            _buildInfoTab(),
          ],
        ),
      ),
    );
  }

  // ── Sliver App Bar with Hero Image ─────────────────────────
  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Colors.deepOrange,
      // Back button
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black38,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        // Share button (placeholder)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black38,
            child: IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Restaurant cover image
            _r.imageUrl.isNotEmpty
                ? Image.network(
                    _r.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, size: 80, color: Colors.grey),
                    ),
                  )
                : Container(color: Colors.grey[300]),

            // Gradient overlay — makes text readable over image
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),

            // Restaurant name over image (bottom-left)
            Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Text(
                _r.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Restaurant Info Card (below image) ─────────────────────
  Widget _buildInfoCard() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Cuisine + Open/Closed Status ─────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Text(
                  _r.cuisineType,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _r.isOpen ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: _r.isOpen ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _r.isOpen ? 'Open Now' : 'Closed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _r.isOpen ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Row 2: Star Rating ───────────────────────────────
          StarRatingWidget(
            rating: _r.rating,
            starSize: 18,
            showNumber: true,
            reviewCount: _r.totalReviews,
          ),
          const SizedBox(height: 12),

          // ── Row 3: Delivery stats chips ──────────────────────
          Row(
            children: [
              _statChip(
                Icons.access_time_outlined,
                '${_r.deliveryTimeMin} min',
                'Delivery',
              ),
              const SizedBox(width: 8),
              _statChip(
                Icons.delivery_dining,
                _r.deliveryFee == 0
                    ? 'Free'
                    : 'PKR ${_r.deliveryFee.toStringAsFixed(0)}',
                'Delivery Fee',
              ),
              const SizedBox(width: 8),
              _statChip(
                Icons.shopping_bag_outlined,
                'PKR ${_r.minimumOrder.toStringAsFixed(0)}',
                'Min. Order',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: Colors.deepOrange),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info Tab Content ───────────────────────────────────────
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoSection('About', _r.description),
          const SizedBox(height: 16),
          _infoSection('Address', _r.address.fullAddress),
          const SizedBox(height: 16),
          _infoSection('Phone', _r.phone),
          const SizedBox(height: 16),
          _infoSection('Email', _r.email),
          const SizedBox(height: 16),
          _buildTagSection(),
        ],
      ),
    );
  }

  Widget _infoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey[200]),
      ],
    );
  }

  Widget _buildTagSection() {
    if (_r.tags.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _r.tags.map((tag) => Chip(
            label: Text(tag),
            backgroundColor: Colors.orange[50],
            labelStyle: TextStyle(color: Colors.orange[800], fontSize: 12),
          )).toList(),
        ),
      ],
    );
  }
}

// ── Custom Persistent Header Delegate for TabBar ───────────────
// This is required to pin the TabBar using SliverPersistentHeader.
// Without this, the tab bar would scroll away with the content.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}