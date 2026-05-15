// ============================================================
// FILE: lib/widgets/menu_item_card.dart
// PURPOSE: The card UI shown for each menu item in the menu list.
//          Displays item details, price, dietary badges, and
//          add-to-cart button.
//          Used by MenuScreen in its ListView.
// ============================================================

import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback? onAddToCart;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        item.discountedPrice > 0 && item.discountedPrice < item.price;
    final displayPrice = hasDiscount ? item.discountedPrice : item.price;
    final originalPrice = item.price;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Container with Discount Badge ──────────
            Stack(
              children: [
                // Item image or placeholder
                _buildItemImage(),

                // Discount badge (if applicable)
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.discountPercent.toStringAsFixed(0)}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Availability overlay (if not available)
                if (!item.isAvailable)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Item Details ────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Dietary badges
                  _buildDietaryBadges(),

                  const SizedBox(height: 8),

                  // Price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rs. ${displayPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.deepOrange[700],
                            ),
                          ),
                          if (hasDiscount)
                            Text(
                              'Rs. ${originalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),

                      // Add to cart button
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: item.isAvailable ? onAddToCart : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            disabledBackgroundColor: Colors.grey[300],
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Icon(
                            Icons.add_shopping_cart,
                            color:
                                item.isAvailable ? Colors.white : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Prep time
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.preparationTimeMin} mins',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build Item Image ───────────────────────────────────────
  Widget _buildItemImage() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey[200],
      child: item.imageUrl.isNotEmpty
          ? Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.restaurant,
                  size: 60,
                  color: Colors.grey,
                );
              },
            )
          : const Icon(
              Icons.restaurant,
              size: 60,
              color: Colors.grey,
            ),
    );
  }

  // ── Build Dietary Badges (Veg/Vegan/Spicy) ─────────────────
  Widget _buildDietaryBadges() {
    final badges = <Widget>[];

    if (item.isVegetarian) {
      badges.add(_buildBadge('🥕 Veg', Colors.green[100]!, Colors.green[700]!));
    }

    if (item.isVegan) {
      badges.add(_buildBadge('🌱 Vegan', Colors.teal[100]!, Colors.teal[700]!));
    }

    if (item.isSpicy) {
      badges.add(_buildBadge('🌶️ Spicy', Colors.red[100]!, Colors.red[700]!));
    }

    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < badges.length; i++) ...[
            badges[i],
            if (i < badges.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }

  // ── Helper: Build Single Badge ─────────────────────────────
  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
