// ============================================================
// FILE: lib/widgets/menu_item_card.dart
// PURPOSE: Card widget for each menu item on the menu screen.
//          Shows item image, name, description, price, badges.
//          Greys out unavailable items automatically.
// ============================================================

import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback? onAddToCart; // nullable — Phase 4 wires this up

  const MenuItemCard({
    super.key,
    required this.item,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      // Grey out the whole card if item is not available
      opacity: item.isAvailable ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.06 * 255).round()), // alpha ≈ 15
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: Item Image ─────────────────────────────────
            _buildItemImage(),

            // ── Right: Item Details ──────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBadgeRow(),
                    const SizedBox(height: 4),
                    _buildName(),
                    const SizedBox(height: 4),
                    _buildDescription(),
                    const SizedBox(height: 8),
                    _buildPriceAndButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Item Image (square, left side) ─────────────────────────
  Widget _buildItemImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius:
              const BorderRadius.horizontal(left: Radius.circular(12)),
          child: item.imageUrl.isNotEmpty
              ? Image.network(
                  item.imageUrl,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  loadingBuilder: (_, child, progress) =>
                      progress == null ? child : _imagePlaceholder(),
                )
              : _imagePlaceholder(),
        ),
        // "OUT OF STOCK" label on image when unavailable
        if (!item.isAvailable)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: const Text(
                'OUT OF STOCK',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 110,
      height: 110,
      color: Colors.grey[100],
      child: const Icon(Icons.fastfood, size: 36, color: Colors.grey),
    );
  }

  // ── Dietary Badge Row (Veg / Vegan / Spicy) ────────────────
  Widget _buildBadgeRow() {
    final badges = <Widget>[];

    if (item.isVegan) {
      badges.add(_badge('Vegan', Colors.green[700]!));
    } else if (item.isVegetarian) {
      badges.add(_badge('Veg', Colors.green));
    }

    if (item.isSpicy) {
      badges.add(_badge('🌶 Spicy', Colors.red[600]!));
    }

    if (item.hasDiscount) {
      badges.add(_badge('${item.discountPercent.toInt()}% OFF', Colors.orange));
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: badges,
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha((0.12 * 255).round()), // alpha ≈ 31
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: color.withAlpha((0.4 * 255).round())), // alpha ≈ 102
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Item Name ──────────────────────────────────────────────
  Widget _buildName() {
    return Text(
      item.name,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A1A),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // ── Short Description ──────────────────────────────────────
  Widget _buildDescription() {
    return Text(
      item.description,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // ── Price + Add to Cart Button Row ─────────────────────────
  Widget _buildPriceAndButton(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Price column (shows discounted + original) ─────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current/discounted price (always shown)
            Text(
              'PKR ${item.discountedPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100), // Deep orange
              ),
            ),
            // Original price with strikethrough (only if discounted)
            if (item.hasDiscount)
              Text(
                'PKR ${item.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  decoration: TextDecoration.lineThrough,
                ),
              ),
          ],
        ),
        const Spacer(),
        // ── Add to Cart button ─────────────────────────────────
        // Disabled and greyed out if not available
        GestureDetector(
          onTap: item.isAvailable ? onAddToCart : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color:
                  item.isAvailable ? const Color(0xFFE65100) : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  size: 16,
                  color: item.isAvailable ? Colors.white : Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  'Add',
                  style: TextStyle(
                    color: item.isAvailable ? Colors.white : Colors.grey[500],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
