// ============================================================
// FILE: lib/models/review_model.dart
// PURPOSE: Dart class mirroring the review JSON from Flask.
// ============================================================

class ReviewModel {
  // ── Identifiers ────────────────────────────────────────────
  final String id;
  final String restaurantId;   // maps to "restaurant_id"
  final String userId;         // maps to "user_id"

  // ── Reviewer Info ──────────────────────────────────────────
  final String userName;       // maps to "user_name"

  // ── Ratings ────────────────────────────────────────────────
  final double rating;          // Overall rating 1.0 – 5.0
  final double foodRating;      // maps to "food_rating"
  final double serviceRating;   // maps to "service_rating"
  final double deliveryRating;  // maps to "delivery_rating"

  // ── Content ────────────────────────────────────────────────
  final String comment;
  final List<String> images;

  // ── Meta ───────────────────────────────────────────────────
  final String status;          // "active", "pending", "rejected"
  final int helpfulVotes;       // maps to "helpful_votes"

  // ── Timestamps ─────────────────────────────────────────────
  final String createdAt;
  final String updatedAt;

  const ReviewModel({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.foodRating,
    required this.serviceRating,
    required this.deliveryRating,
    required this.comment,
    required this.images,
    required this.status,
    required this.helpfulVotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id:              json['id']               ?? '',
      restaurantId:    json['restaurant_id']    ?? '',
      userId:          json['user_id']          ?? '',
      userName:        json['user_name']        ?? 'Anonymous',
      rating:          (json['rating'] as num?)?.toDouble() ?? 0.0,
      foodRating:      (json['food_rating'] as num?)?.toDouble() ?? 0.0,
      serviceRating:   (json['service_rating'] as num?)?.toDouble() ?? 0.0,
      deliveryRating:  (json['delivery_rating'] as num?)?.toDouble() ?? 0.0,
      comment:         json['comment']          ?? '',
      images:          List<String>.from(json['images'] ?? []),
      status:          json['status']           ?? 'active',
      helpfulVotes:    (json['helpful_votes'] as num?)?.toInt() ?? 0,
      createdAt:       json['created_at']       ?? '',
      updatedAt:       json['updated_at']       ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id':               id,
    'restaurant_id':    restaurantId,
    'user_id':          userId,
    'user_name':        userName,
    'rating':           rating,
    'food_rating':      foodRating,
    'service_rating':   serviceRating,
    'delivery_rating':  deliveryRating,
    'comment':          comment,
    'images':           images,
    'status':           status,
    'helpful_votes':    helpfulVotes,
    'created_at':       createdAt,
    'updated_at':       updatedAt,
  };

  // ── Convenience getter ─────────────────────────────────────
  // Formats "2024-01-15T10:30:00" → "Jan 15, 2024"
  String get formattedDate {
    try {
      final dt = DateTime.parse(createdAt);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  // ── Dummy data for Phase 3 UI testing ─────────────────────
  static List<ReviewModel> getDummyList(String restaurantId) {
    return [
      ReviewModel(
        id: 'rev_001', restaurantId: restaurantId,
        userId: 'u1', userName: 'Ahmed Khan',
        rating: 5.0, foodRating: 5.0, serviceRating: 4.5, deliveryRating: 5.0,
        comment: 'Absolutely amazing burgers! The cheese was perfectly melted and fries were super crispy. Will definitely order again!',
        images: [], status: 'active', helpfulVotes: 12,
        createdAt: '2024-03-15T14:30:00', updatedAt: '2024-03-15T14:30:00',
      ),
      ReviewModel(
        id: 'rev_002', restaurantId: restaurantId,
        userId: 'u2', userName: 'Sara Ali',
        rating: 4.0, foodRating: 4.5, serviceRating: 4.0, deliveryRating: 3.5,
        comment: 'Good food but delivery took a bit longer than expected. The burger was still warm though.',
        images: [], status: 'active', helpfulVotes: 5,
        createdAt: '2024-03-10T09:15:00', updatedAt: '2024-03-10T09:15:00',
      ),
      ReviewModel(
        id: 'rev_003', restaurantId: restaurantId,
        userId: 'u3', userName: 'Usman Tariq',
        rating: 4.5, foodRating: 5.0, serviceRating: 4.0, deliveryRating: 4.5,
        comment: 'Best burger place in Rawalpindi! The spicy crispy burger is a must-try.',
        images: [], status: 'active', helpfulVotes: 8,
        createdAt: '2024-03-05T18:45:00', updatedAt: '2024-03-05T18:45:00',
      ),
      ReviewModel(
        id: 'rev_004', restaurantId: restaurantId,
        userId: 'u4', userName: 'Ayesha Malik',
        rating: 3.5, foodRating: 3.5, serviceRating: 3.0, deliveryRating: 4.0,
        comment: 'Average experience. Food was okay but nothing exceptional. Expected more for the price.',
        images: [], status: 'active', helpfulVotes: 2,
        createdAt: '2024-02-28T12:00:00', updatedAt: '2024-02-28T12:00:00',
      ),
    ];
  }
}