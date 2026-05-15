// ============================================================
// FILE: lib/widgets/star_rating_widget.dart
// PURPOSE: Reusable star rating display widget.
//          Used on restaurant cards, details screen, and review cards.
//          Shows filled/half/empty stars based on a double rating value.
// ============================================================

import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  // ── Parameters ─────────────────────────────────────────────
  final double rating;     // e.g. 4.3
  final double starSize;   // size of each star icon
  final bool showNumber;   // whether to show "4.3" next to stars
  final int reviewCount;   // if > 0, shows "(128)" next to number
  final MainAxisAlignment alignment;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.starSize = 16.0,
    this.showNumber = true,
    this.reviewCount = 0,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        // ── Draw 5 stars ──────────────────────────────────────
        ...List.generate(5, (index) {
          final starValue = index + 1;

          // Determine star type based on rating value
          IconData icon;
          if (rating >= starValue) {
            icon = Icons.star_rounded;              // Full star
          } else if (rating >= starValue - 0.5) {
            icon = Icons.star_half_rounded;         // Half star
          } else {
            icon = Icons.star_outline_rounded;      // Empty star
          }

          return Icon(
            icon,
            size: starSize,
            color: const Color(0xFFFFC107), // Amber/gold colour
          );
        }),

        // ── Show numeric rating if requested ──────────────────
        if (showNumber) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),  // e.g. "4.3"
            style: TextStyle(
              fontSize: starSize * 0.85,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          // Show review count in parentheses if provided
          if (reviewCount > 0) ...[
            const SizedBox(width: 2),
            Text(
              '($reviewCount)',
              style: TextStyle(
                fontSize: starSize * 0.75,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ],
    );
  }
}