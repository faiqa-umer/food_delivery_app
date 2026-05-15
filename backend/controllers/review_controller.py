# ============================================================
# FILE: backend/controllers/review_controller.py
# PURPOSE: Business logic for review operations.
#
#          KEY FEATURE: When a review is added or deleted,
#          we automatically RECALCULATE the restaurant's
#          average rating and update the restaurant document.
#          This keeps data consistent across collections.
#
# FUNCTIONS:
#   get_reviews_by_restaurant() → GET    /api/reviews/restaurant/<id>
#   get_review_by_id()          → GET    /api/reviews/<id>
#   create_review()             → POST   /api/reviews
#   update_review()             → PUT    /api/reviews/<id>
#   delete_review()             → DELETE /api/reviews/<id>
# ============================================================

from flask import request, jsonify
from datetime import datetime
from bson import ObjectId

from config.database import reviews_collection, restaurants_collection
from models.review_model import create_review_document
from utils.helpers import (
    success_response,
    error_response,
    serialize_document,
    serialize_list,
    validate_object_id,
    validate_required_fields,
    get_pagination_params,
)


# ─────────────────────────────────────────────────────────────
# INTERNAL HELPER: Recalculate Restaurant Rating
#
# This is a PRIVATE function (not exposed as an API endpoint).
# It is called automatically after every review create/delete.
# ─────────────────────────────────────────────────────────────
def _recalculate_restaurant_rating(restaurant_id: str):
    """
    Recalculates the average rating for a restaurant based on
    all existing active reviews, then updates the restaurant document.

    Why we do this:
        Storing a pre-computed 'rating' on the restaurant document
        means Flutter can display it WITHOUT fetching all reviews.
        This is called a 'denormalized' field — common in MongoDB.

    Args:
        restaurant_id : String ID of the restaurant to update
    """
    # ── Fetch all active reviews for this restaurant ─────────
    all_reviews = list(reviews_collection.find({
        "restaurant_id": restaurant_id,
        "status": "active"
    }))

    total = len(all_reviews)

    if total == 0:
        avg_rating = 0.0
    else:
        # Sum all ratings and divide by count
        avg_rating = sum(r.get("rating", 0) for r in all_reviews) / total
        avg_rating = round(avg_rating, 1)  # e.g. 4.27 → 4.3

    # ── Update the restaurant's rating and total_reviews count ─
    object_id, _ = validate_object_id(restaurant_id)
    if object_id:
        restaurants_collection.update_one(
            {"_id": object_id},
            {"$set": {
                "rating":        avg_rating,
                "total_reviews": total,
                "updated_at":    datetime.utcnow(),
            }}
        )


# ─────────────────────────────────────────────────────────────
# 1. GET ALL REVIEWS FOR A RESTAURANT
#    URL: GET /api/reviews/restaurant/<restaurant_id>
# ─────────────────────────────────────────────────────────────
def get_reviews_by_restaurant(restaurant_id: str):
    """
    Returns paginated list of all active reviews for a restaurant.

    Query Parameters:
        page, limit : Pagination
        sort_by     : "rating" or "created_at" (default: "created_at")
        order       : "asc" or "desc" (default: "desc" = newest first)

    Returns:
        JSON with reviews list + rating summary statistics
    """
    try:
        # ── Validate restaurant exists ───────────────────────────
        object_id, err = validate_object_id(restaurant_id)
        if err:
            return jsonify(err[0]), err[1]

        restaurant = restaurants_collection.find_one({"_id": object_id})
        if not restaurant:
            return jsonify(error_response(
                message=f"Restaurant '{restaurant_id}' not found.",
                status_code=404
            ))

        # ── Pagination & sorting ─────────────────────────────────
        page, limit, skip = get_pagination_params(request.args)
        sort_by   = request.args.get("sort_by", "created_at")
        order     = request.args.get("order", "desc")
        direction = -1 if order == "desc" else 1

        # ── Query only active reviews ────────────────────────────
        query_filter = {
            "restaurant_id": restaurant_id,
            "status": "active"
        }

        cursor = (
            reviews_collection
            .find(query_filter)
            .sort(sort_by, direction)
            .skip(skip)
            .limit(limit)
        )

        reviews     = serialize_list(list(cursor))
        total_count = reviews_collection.count_documents(query_filter)

        # ── Build rating distribution (for star breakdown UI) ────
        # e.g. how many 5-star, 4-star, 3-star reviews exist
        rating_distribution = {}
        for star in [5, 4, 3, 2, 1]:
            count = reviews_collection.count_documents({
                "restaurant_id": restaurant_id,
                "status": "active",
                "rating": {"$gte": float(star) - 0.5, "$lt": float(star) + 0.5}
            })
            rating_distribution[str(star)] = count

        return jsonify(success_response(
            data={
                "restaurant_id":       restaurant_id,
                "restaurant_name":     restaurant.get("name", ""),
                "average_rating":      restaurant.get("rating", 0.0),
                "total_reviews":       total_count,
                "rating_distribution": rating_distribution,
                "reviews":             reviews,
                "pagination": {
                    "current_page": page,
                    "limit":        limit,
                    "total_pages":  (total_count + limit - 1) // limit,
                }
            },
            message=f"Retrieved {len(reviews)} review(s)"
        ))

    except Exception as e:
        return jsonify(error_response(
            message="Failed to fetch reviews",
            status_code=500,
            errors=[str(e)]
        ))


# ─────────────────────────────────────────────────────────────
# 2. GET SINGLE REVIEW BY ID
#    URL: GET /api/reviews/<review_id>
# ─────────────────────────────────────────────────────────────
def get_review_by_id(review_id: str):
    """Fetches a single review by its MongoDB _id."""
    try:
        object_id, err = validate_object_id(review_id)
        if err:
            return jsonify(err[0]), err[1]

        review = reviews_collection.find_one({"_id": object_id})

        if not review:
            return jsonify(error_response(
                message=f"Review with ID '{review_id}' not found.",
                status_code=404
            ))

        return jsonify(success_response(
            data={"review": serialize_document(review)},
            message="Review retrieved successfully"
        ))

    except Exception as e:
        return jsonify(error_response(
            message="Failed to fetch review",
            status_code=500,
            errors=[str(e)]
        ))


# ─────────────────────────────────────────────────────────────
# 3. CREATE REVIEW
#    URL: POST /api/reviews
#    Automatically recalculates restaurant's average rating.
# ─────────────────────────────────────────────────────────────
def create_review():
    """
    Creates a new review and updates the restaurant's rating.

    Request Body (JSON):
        Required: restaurant_id, user_id, user_name, rating, comment
        Optional: food_rating, service_rating, delivery_rating, images

    Returns:
        JSON with the created review + updated restaurant rating
    """
    try:
        body = request.get_json()
        if not body:
            return jsonify(error_response("Request body missing or invalid JSON.", 400))

        # ── Validate required fields ─────────────────────────────
        required = ["restaurant_id", "user_id", "user_name", "rating", "comment"]
        is_valid, err = validate_required_fields(body, required)
        if not is_valid:
            return jsonify(err[0]), err[1]

        # ── Validate restaurant exists ───────────────────────────
        rest_object_id, err = validate_object_id(body["restaurant_id"])
        if err:
            return jsonify(err[0]), err[1]

        restaurant = restaurants_collection.find_one({"_id": rest_object_id})
        if not restaurant:
            return jsonify(error_response(
                message=f"Restaurant ID '{body['restaurant_id']}' not found.",
                status_code=404
            ))

        # ── Validate rating is between 1 and 5 ──────────────────
        try:
            rating = float(body["rating"])
            if not (1.0 <= rating <= 5.0):
                raise ValueError()
        except (ValueError, TypeError):
            return jsonify(error_response(
                message="'rating' must be a number between 1.0 and 5.0",
                status_code=422
            ))

        # ── Build and insert the review document ─────────────────
        new_review = create_review_document(
            restaurant_id   = body["restaurant_id"],
            user_id         = body["user_id"],
            user_name       = body["user_name"],
            rating          = rating,
            comment         = body["comment"],
            food_rating     = float(body.get("food_rating", 0.0)),
            service_rating  = float(body.get("service_rating", 0.0)),
            delivery_rating = float(body.get("delivery_rating", 0.0)),
            images          = body.get("images", []),
        )

        result  = reviews_collection.insert_one(new_review)
        created = reviews_collection.find_one({"_id": result.inserted_id})

        # ── KEY STEP: Recalculate restaurant's average rating ────
        _recalculate_restaurant_rating(body["restaurant_id"])

        # ── Fetch updated restaurant to show new rating ──────────
        updated_restaurant = restaurants_collection.find_one({"_id": rest_object_id})

        return jsonify(success_response(
            data={
                "review": serialize_document(created),
                "restaurant_new_rating":       updated_restaurant.get("rating", 0.0),
                "restaurant_total_reviews":    updated_restaurant.get("total_reviews", 0),
            },
            message="Review submitted successfully",
            status_code=201
        ))

    except Exception as e:
        return jsonify(error_response(
            message="Failed to create review",
            status_code=500,
            errors=[str(e)]
        ))


# ─────────────────────────────────────────────────────────────
# 4. UPDATE REVIEW
#    URL: PUT /api/reviews/<review_id>
# ─────────────────────────────────────────────────────────────
def update_review(review_id: str):
    """
    Updates a review's comment, rating, or sub-ratings.
    Recalculates restaurant average rating if rating changed.
    """
    try:
        object_id, err = validate_object_id(review_id)
        if err:
            return jsonify(err[0]), err[1]

        body = request.get_json()
        if not body:
            return jsonify(error_response("Request body is empty.", 400))

        # ── Protect system fields ────────────────────────────────
        protected = ["_id", "restaurant_id", "user_id", "created_at", "helpful_votes"]
        for field in protected:
            body.pop(field, None)

        # ── Validate rating if being updated ─────────────────────
        if "rating" in body:
            try:
                rating = float(body["rating"])
                if not (1.0 <= rating <= 5.0):
                    raise ValueError()
                body["rating"] = rating
            except (ValueError, TypeError):
                return jsonify(error_response(
                    message="'rating' must be between 1.0 and 5.0",
                    status_code=422
                ))

        body["updated_at"] = datetime.utcnow()

        # ── Fetch current review (to get restaurant_id for recalc) ─
        current_review = reviews_collection.find_one({"_id": object_id})
        if not current_review:
            return jsonify(error_response(
                message=f"Review '{review_id}' not found.",
                status_code=404
            ))

        reviews_collection.update_one({"_id": object_id}, {"$set": body})

        # ── Recalculate restaurant rating if rating changed ───────
        if "rating" in body:
            _recalculate_restaurant_rating(current_review["restaurant_id"])

        updated = reviews_collection.find_one({"_id": object_id})
        return jsonify(success_response(
            data={"review": serialize_document(updated)},
            message="Review updated successfully"
        ))

    except Exception as e:
        return jsonify(error_response(
            message="Failed to update review",
            status_code=500,
            errors=[str(e)]
        ))


# ─────────────────────────────────────────────────────────────
# 5. DELETE REVIEW
#    URL: DELETE /api/reviews/<review_id>
#    Recalculates restaurant rating after deletion.
# ─────────────────────────────────────────────────────────────
def delete_review(review_id: str):
    """
    Deletes a review and recalculates the restaurant's average rating.
    """
    try:
        object_id, err = validate_object_id(review_id)
        if err:
            return jsonify(err[0]), err[1]

        # ── Fetch review BEFORE deleting (need restaurant_id) ────
        review = reviews_collection.find_one({"_id": object_id})
        if not review:
            return jsonify(error_response(
                message=f"Review '{review_id}' not found.",
                status_code=404
            ))

        restaurant_id = review["restaurant_id"]

        reviews_collection.delete_one({"_id": object_id})

        # ── Recalculate rating after deletion ─────────────────────
        _recalculate_restaurant_rating(restaurant_id)

        return jsonify(success_response(
            data={"deleted_id": review_id},
            message="Review deleted and restaurant rating updated"
        ))

    except Exception as e:
        return jsonify(error_response(
            message="Failed to delete review",
            status_code=500,
            errors=[str(e)]
        ))