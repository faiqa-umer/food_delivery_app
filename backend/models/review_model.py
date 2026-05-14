# ============================================================
# FILE: backend/models/review_model.py
# PURPOSE: Defines the data structure for a Customer Review.
#          A review is linked to both a RESTAURANT and a USER.
#          When added, the restaurant's average rating is
#          recalculated in the controller.
# ============================================================

from datetime import datetime


def create_review_document(
    restaurant_id: str,
    user_id: str,
    user_name: str,
    rating: float,
    comment: str,
    food_rating: float = 0.0,
    service_rating: float = 0.0,
    delivery_rating: float = 0.0,
    images: list = None,
) -> dict:
    """
    Creates a review document ready for MongoDB insertion.

    Parameters:
        restaurant_id   : ID of the restaurant being reviewed
        user_id         : ID of the user writing the review
        user_name       : Display name of the reviewer
        rating          : Overall rating (1.0 - 5.0)
        comment         : Review text written by the customer
        food_rating     : Sub-rating for food quality (1.0 - 5.0)
        service_rating  : Sub-rating for service (1.0 - 5.0)
        delivery_rating : Sub-rating for delivery (1.0 - 5.0)
        images          : List of image URLs attached to the review

    Returns:
        dict: MongoDB-ready document
    """

    # ── Validate rating range ──────────────────────────────────
    # Ratings must be between 1 and 5.
    # We clamp instead of raising an error to be user-friendly.
    def clamp_rating(r):
        return max(1.0, min(5.0, float(r)))

    return {
        # ── Relationships ──────────────────────────────────────
        "restaurant_id":    restaurant_id,   # Which restaurant
        "user_id":          user_id,         # Who wrote the review

        # ── Reviewer Display Info ──────────────────────────────
        "user_name":        user_name,

        # ── Ratings ────────────────────────────────────────────
        # Overall rating shown as stars on the UI
        "rating":           clamp_rating(rating),

        # Sub-ratings for detailed feedback breakdown
        "food_rating":      clamp_rating(food_rating) if food_rating else 0.0,
        "service_rating":   clamp_rating(service_rating) if service_rating else 0.0,
        "delivery_rating":  clamp_rating(delivery_rating) if delivery_rating else 0.0,

        # ── Review Content ─────────────────────────────────────
        "comment":          comment,

        # ── Optional Media ─────────────────────────────────────
        "images":           images if images is not None else [],

        # ── Status (moderation support) ────────────────────────
        # "active"   = visible to all users
        # "pending"  = awaiting moderation
        # "rejected" = hidden by admin
        "status":           "active",

        # ── Helpful votes (like Reddit upvotes) ────────────────
        "helpful_votes":    0,

        # ── Timestamps ─────────────────────────────────────────
        "created_at":       datetime.utcnow(),
        "updated_at":       datetime.utcnow(),
    }


