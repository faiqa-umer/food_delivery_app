// ============================================================
// FILE: lib/customer/screens/review_screen.dart
// PURPOSE: Shows all reviews for a restaurant.
//          Features:
//            - Overall rating summary with score + star bar
//            - Rating distribution bars (5★ to 1★)
//            - Scrollable list of review cards
//            - Sort options (Newest / Highest / Lowest)
//
// RECEIVES: restaurantId, restaurantName from RestaurantDetailsScreen
// PHASE 3:  Uses ReviewModel.getDummyList()
// PHASE 4:  Replace with ApiService.getReviews(restaurantId)
// ============================================================

import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../../widgets/review_card.dart';
import '../../widgets/star_rating_widget.dart';

class ReviewScreen extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const ReviewScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // ── State ──────────────────────────────────────────────────
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Sort options: "newest", "highest", "lowest"
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  // ── Load Reviews ───────────────────────────────────────────
  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Phase 3: Dummy data
      // Phase 4: → ApiService.getReviewsByRestaurant(widget.restaurantId)
      await Future.delayed(const Duration(milliseconds: 700));
      final data = ReviewModel.getDummyList(widget.restaurantId);

      setState(() {
        _reviews = data;
        _isLoading = false;
        _applySorting();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load reviews. Please try again.';
        _isLoading = false;
      });
    }
  }

  // ── Sort Reviews ───────────────────────────────────────────
  void _applySorting() {
    setState(() {
      switch (_sortBy) {
        case 'newest':
          _reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'highest':
          _reviews.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'lowest':
          _reviews.sort((a, b) => a.rating.compareTo(b.rating));
          break;
      }
    });
  }

  // ── Computed Stats ─────────────────────────────────────────
  // Average rating across all loaded reviews
  double get _averageRating {
    if (_reviews.isEmpty) return 0.0;
    final sum = _reviews.fold(0.0, (acc, r) => acc + r.rating);
    return double.parse((sum / _reviews.length).toStringAsFixed(1));
  }

  // Count reviews for each star value (5 down to 1)
  Map<int, int> get _ratingDistribution {
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _reviews) {
      final star = r.rating.round().clamp(1, 5);
      dist[star] = (dist[star] ?? 0) + 1;
    }
    return dist;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) return _buildLoadingState();
    if (_errorMessage != null) return _buildErrorState();

    return RefreshIndicator(
      onRefresh: _loadReviews,
      color: Colors.deepOrange,
      child: CustomScrollView(
        slivers: [
          // ── Rating Summary Card ────────────────────────────
          SliverToBoxAdapter(child: _buildRatingSummary()),

          // ── Sort Options ───────────────────────────────────
          SliverToBoxAdapter(child: _buildSortRow()),

          // ── Reviews List or Empty State ────────────────────
          _reviews.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == _reviews.length) {
                        return const SizedBox(height: 24);
                      }
                      return ReviewCard(review: _reviews[index]);
                    },
                    childCount: _reviews.length + 1,
                  ),
                ),
        ],
      ),
    );
  }

  // ── Rating Summary Card ────────────────────────────────────
  Widget _buildRatingSummary() {
    final dist = _ratingDistribution;
    final total = _reviews.length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Left: Big score number ──────────────────────────
          Column(
            children: [
              Text(
                _averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              StarRatingWidget(
                rating: _averageRating,
                starSize: 16,
                showNumber: false,
              ),
              const SizedBox(height: 6),
              Text(
                '$total review${total == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(width: 24),
          const VerticalDivider(thickness: 1, width: 1),
          const SizedBox(width: 24),

          // ── Right: Distribution bars (5★ to 1★) ───────────
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = dist[star] ?? 0;
                final fraction = total > 0 ? count / total : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      // Star count label
                      Text(
                        '$star',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, size: 12, color: Color(0xFFFFC107)),
                      const SizedBox(width: 6),
                      // Progress bar
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fraction,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              // Colour the bar based on star count
                              star >= 4
                                  ? Colors.green
                                  : star == 3
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                            minHeight: 7,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Count label
                      SizedBox(
                        width: 20,
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sort Options Row ───────────────────────────────────────
  Widget _buildSortRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          _sortChip('Newest',  'newest'),
          const SizedBox(width: 6),
          _sortChip('Highest', 'highest'),
          const SizedBox(width: 6),
          _sortChip('Lowest',  'lowest'),
        ],
      ),
    );
  }

  Widget _sortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() => _sortBy = value);
        _applySorting();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.deepOrange : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  // ── Loading State ──────────────────────────────────────────
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.deepOrange),
          SizedBox(height: 16),
          Text('Loading reviews...', style: TextStyle(color: Colors.grey)),
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
          const Icon(Icons.star_border, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadReviews,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────
  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Text('⭐', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to leave a review!',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}