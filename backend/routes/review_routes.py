# ============================================================
# FILE: backend/routes/review_routes.py
# PURPOSE: URL endpoints for all review operations.
#
# ALL ENDPOINTS (prefix /api/reviews added in app.py):
#
#   GET    /api/reviews/restaurant/<id>   → all reviews for a restaurant
#   GET    /api/reviews/<review_id>       → single review
#   POST   /api/reviews/                  → create review
#   PUT    /api/reviews/<review_id>       → update review
#   DELETE /api/reviews/<review_id>       → delete review
# ============================================================

from flask import Blueprint

from controllers.review_controller import (
    get_reviews_by_restaurant,
    get_review_by_id,
    create_review,
    update_review,
    delete_review,
)

review_bp = Blueprint("review_bp", __name__)


# ── Restaurant-scoped reviews (specific route first) ──────────
@review_bp.route("/restaurant/<string:restaurant_id>", methods=["GET"])
def list_reviews(restaurant_id):
    """
    GET /api/reviews/restaurant/<restaurant_id>
    Returns all reviews for a specific restaurant.
    Includes rating statistics and distribution.
    Optional: ?sort_by=rating&order=desc&page=1&limit=10
    """
    return get_reviews_by_restaurant(restaurant_id)


# ── Individual review routes ──────────────────────────────────
@review_bp.route("/<string:review_id>", methods=["GET"])
def retrieve_review(review_id):
    """
    GET /api/reviews/<review_id>
    Returns a single review by its ID.
    """
    return get_review_by_id(review_id)


@review_bp.route("/", methods=["POST"])
def add_review():
    """
    POST /api/reviews/
    Creates a new review. Also updates the restaurant's average rating.
    Required body: restaurant_id, user_id, user_name, rating, comment
    """
    return create_review()


@review_bp.route("/<string:review_id>", methods=["PUT"])
def edit_review(review_id):
    """
    PUT /api/reviews/<review_id>
    Updates a review's comment, rating, or sub-ratings.
    """
    return update_review(review_id)


@review_bp.route("/<string:review_id>", methods=["DELETE"])
def remove_review(review_id):
    """
    DELETE /api/reviews/<review_id>
    Deletes a review and recalculates the restaurant's rating.
    """
    return delete_review(review_id)