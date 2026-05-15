// ============================================================
// FILE: lib/widgets/review_card.dart
// PURPOSE: Card widget for a single customer review.
//          Displays avatar, name, date, stars, comment,
//          and sub-rating breakdown (food/service/delivery).
// ============================================================

import 'package:flutter/material.dart';
import '../models/review_model.dart';
import 'star_rating_widget.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: Avatar + Name + Date + Stars ────────────
          _buildHeader(),
          const SizedBox(height: 12),

          // ── Review comment text ──────────────────────────────
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // ── Sub-ratings breakdown ────────────────────────────
          // Only show if at least one sub-rating is non-zero
          if (review.foodRating > 0 ||
              review.serviceRating > 0 ||
              review.deliveryRating > 0)
            _buildSubRatings(),

          // ── Helpful votes footer ─────────────────────────────
          if (review.helpfulVotes > 0) ...[
            const SizedBox(height: 10),
            _buildHelpfulRow(),
          ],
        ],
      ),
    );
  }

  // ── Header: Avatar, name, date, overall star rating ────────
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar circle with first letter of name
        CircleAvatar(
          radius: 22,
          backgroundColor: _avatarColor(review.userName),
          child: Text(
            review.userName.isNotEmpty
                ? review.userName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Name + Date column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                review.formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),

        // Overall star rating (top-right)
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StarRatingWidget(
              rating: review.rating,
              starSize: 14,
              showNumber: true,
            ),
          ],
        ),
      ],
    );
  }

  // ── Sub-ratings: Food | Service | Delivery ─────────────────
  Widget _buildSubRatings() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          _subRatingItem('Food',     review.foodRating),
          _subRatingDivider(),
          _subRatingItem('Service',  review.serviceRating),
          _subRatingDivider(),
          _subRatingItem('Delivery', review.deliveryRating),
        ],
      ),
    );
  }

  Widget _subRatingItem(String label, double value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          // Mini star row (no number text — too small)
          StarRatingWidget(
            rating: value,
            starSize: 11,
            showNumber: false,
          ),
          const SizedBox(height: 2),
          Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subRatingDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey[200],
    );
  }

  // ── Helpful votes row ──────────────────────────────────────
  Widget _buildHelpfulRow() {
    return Row(
      children: [
        Icon(Icons.thumb_up_outlined, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          '${review.helpfulVotes} people found this helpful',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }

  // ── Generate consistent colour from username ───────────────
  // Same username always gets the same colour — looks intentional.
  Color _avatarColor(String name) {
    final colors = [
      Colors.deepOrange,
      Colors.blue[700]!,
      Colors.green[700]!,
      Colors.purple[700]!,
      Colors.teal[700]!,
      Colors.red[700]!,
      Colors.indigo[700]!,
    ];
    final index = name.isEmpty ? 0 : name.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}