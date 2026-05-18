// ============================================================
// FILE: lib/widgets/restaurant_card.dart
// PURPOSE: The card UI shown for each restaurant in the list.
//          Tapping it navigates to RestaurantDetailsScreen.
//          Used by HomeScreen in its ListView/GridView.
// ============================================================

import 'package:flutter/material.dart';
import '../models/restaurant_model.dart';
import 'star_rating_widget.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;

  // onTap is a callback — the parent screen handles navigation.
  // This keeps the widget reusable and not tied to one screen.
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.08 * 255).round()), // alpha ≈ 20
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Restaurant Cover Image ─────────────────────────
            _buildCoverImage(),

            // ── Restaurant Info ────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameAndStatus(),
                  const SizedBox(height: 4),
                  _buildCuisineAndRating(),
                  const SizedBox(height: 8),
                  _buildDeliveryInfo(),
                  const SizedBox(height: 8),
                  _buildTagChips(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Cover Image with Closed Overlay ────────────────────────
  Widget _buildCoverImage() {
    return Stack(
      children: [
        // Image container
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: restaurant.imageUrl.isNotEmpty
              ? Image.network(
                  restaurant.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Show grey box while image loads
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  // Show placeholder if image fails
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Icon(Icons.restaurant,
                        size: 60, color: Colors.grey),
                  ),
                )
              : Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Icon(Icons.restaurant,
                      size: 60, color: Colors.grey),
                ),
        ),

        // "CLOSED" overlay when restaurant is not open
        if (!restaurant.isOpen)
          Positioned.fill(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                color:
                    Colors.black.withAlpha((0.55 * 255).round()), // alpha ≈ 140
                alignment: Alignment.center,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'CLOSED',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Delivery time badge (top-right corner)
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withAlpha((0.15 * 255).round()), // alpha ≈ 38
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, size: 12, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  '${restaurant.deliveryTimeMin} min',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Name Row with Open/Closed Dot ──────────────────────────
  Widget _buildNameAndStatus() {
    return Row(
      children: [
        Expanded(
          child: Text(
            restaurant.name,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        // Green dot = open, Red dot = closed
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: restaurant.isOpen ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  // ── Cuisine Type and Star Rating ───────────────────────────
  Widget _buildCuisineAndRating() {
    return Row(
      children: [
        // Cuisine type
        Text(
          restaurant.cuisineType,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        // Star rating widget (from our shared widget)
        StarRatingWidget(
          rating: restaurant.rating,
          starSize: 14,
          showNumber: true,
          reviewCount: restaurant.totalReviews,
        ),
      ],
    );
  }

  // ── Delivery Fee + Minimum Order Row ───────────────────────
  Widget _buildDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Delivery fee
          Icon(Icons.delivery_dining, size: 14, color: Colors.orange[700]),
          const SizedBox(width: 4),
          Text(
            restaurant.deliveryFee == 0
                ? 'Free Delivery'
                : 'PKR ${restaurant.deliveryFee.toStringAsFixed(0)} delivery',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          // Minimum order
          Icon(Icons.shopping_bag_outlined,
              size: 14, color: Colors.orange[700]),
          const SizedBox(width: 4),
          Text(
            'Min: PKR ${restaurant.minimumOrder.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tag Chips (halal, fast food, etc.) ─────────────────────
  Widget _buildTagChips() {
    if (restaurant.tags.isEmpty) return const SizedBox.shrink();

    // Show only first 3 tags to keep the card compact
    final visibleTags = restaurant.tags.take(3).toList();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: visibleTags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
        );
      }).toList(),
    );
  }
}
