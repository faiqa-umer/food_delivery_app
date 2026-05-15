# ============================================================
# FILE: backend/controllers/restaurant_controller.py
# PURPOSE: Contains ALL business logic for restaurant operations.
#          Routes call these functions. This keeps routes thin
#          and controllers fat — a clean architecture principle.
#
# FUNCTIONS IN THIS FILE:
#   get_all_restaurants()     → GET  /api/restaurants
#   get_restaurant_by_id()    → GET  /api/restaurants/<id>
#   create_restaurant()       → POST /api/restaurants
#   update_restaurant()       → PUT  /api/restaurants/<id>
#   delete_restaurant()       → DELETE /api/restaurants/<id>
#   search_restaurants()      → GET  /api/restaurants/search
# ============================================================

from flask import request, jsonify
from datetime import datetime

# ── Phase 1 imports ───────────────────────────────────────────
from config.db import restaurants_collection
from models.restaurant_model import create_restaurant_document

# ── Phase 2 helpers ───────────────────────────────────────────
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
# 1. GET ALL RESTAURANTS
#    Returns a paginated list of all restaurants.
#    Supports filtering by cuisine_type and is_open status.
#
#    URL: GET /api/restaurants?page=1&limit=10&cuisine=Fast Food&is_open=true
# ─────────────────────────────────────────────────────────────
def get_all_restaurants():
    """
    Fetches all restaurants from MongoDB with optional filters.

    Query Parameters (all optional):
        page        : Page number for pagination (default: 1)
        limit       : Results per page (default: 10, max: 100)
        cuisine     : Filter by cuisine type e.g. "Fast Food"
        is_open     : Filter by open status "true" or "false"
        sort_by     : Sort field e.g. "rating", "delivery_fee"
        order       : "asc" or "desc" (default: "desc")

    Returns:
        JSON with list of restaurants + pagination metadata
    """
    try:
        # ── Extract pagination params from query string ─────────
        page, limit, skip = get_pagination_params(request.args)

        # ── Build MongoDB filter query ──────────────────────────
        # Start with an empty filter (match everything)
        query_filter = {}

        # Optional: filter by cuisine type
        cuisine = request.args.get("cuisine")
        if cuisine:
            # 'i' flag = case-insensitive match
            # So "fast food" matches "Fast Food"
            query_filter["cuisine_type"] = {"$regex": cuisine, "$options": "i"}

        # Optional: filter by open/closed status
        is_open_param = request.args.get("is_open")
        if is_open_param is not None:
            query_filter["is_open"] = (is_open_param.lower() == "true")

        # ── Build sort order ────────────────────────────────────
        sort_by = request.args.get("sort_by", "created_at")
        order   = request.args.get("order", "desc")
        sort_direction = -1 if order == "desc" else 1  # MongoDB: -1=desc, 1=asc

        # ── Execute MongoDB query ───────────────────────────────
        # .find()  → returns cursor matching the filter
        # .sort()  → sorts the results
        # .skip()  → skips documents for pagination
        # .limit() → limits the number of results returned
        cursor = (
            restaurants_collection
            .find(query_filter)
            .sort(sort_by, sort_direction)
            .skip(skip)
            .limit(limit)
        )

        # Convert cursor to list and serialize for JSON
        restaurants = serialize_list(list(cursor))

        # ── Get total count for pagination metadata ─────────────
        total_count = restaurants_collection.count_documents(query_filter)
        total_pages = (total_count + limit - 1) // limit  # ceiling division

        # ── Build response ──────────────────────────────────────
        return jsonify(success_response(
            data={
                "restaurants": restaurants,
                "pagination": {
                    "current_page": page,
                    "total_pages":  total_pages,
                    "total_count":  total_count,
                    "limit":        limit,
                    "has_next":     page < total_pages,
                    "has_prev":     page > 1,
                }
            },
            message=f"Retrieved {len(restaurants)} restaurant(s)"
        ))

    except Exception as e:
        # Always catch unexpected errors and return a clean message
        return jsonify(error_response(
            message="Failed to fetch restaurants",
            status_code=500,
            errors=[str(e)]
        ))


# ─────────────────────────────────────────────────────────────
# 2. GET SINGLE RESTAURANT BY ID
#    URL: GET /api/restaurants/<restaurant_id>
# ─────────────────────────────────────────────────────────────
def get_restaurant_by_id(restaurant_id: str):
    """
    Fetches a single restaurant document by its MongoDB _id.

    Args:
        restaurant_id : The 24-character hex string ID from the URL

    Returns:
        JSON with full restaurant document, or 404 if not found
    """
    try:
        # ── Validate the ID format first ────────────────────────
        object_id, err = validate_object_id(restaurant_id)
        if err:
            return jsonify(err[0]), err[1]

        # ── Query MongoDB for this specific document ─────────────
        restaurant = restaurants_collection.find_one({"_id": object_id})

        if not restaurant:
            return jsonify(error_response(
                message=f"Restaurant with ID '{restaurant_id}' not found.",
                status_code=404
            ))

        return jsonify(success_response(
            data={"restaurant": serialize_document(restaurant)},
            message="Restaurant retrieved successfully"
        ))

    except Exception as e:
        return jsonify(error_response(
            message="Failed to fetch restaurant",
            status_code=500,
            errors=[str(e)]
        ))


# ─────────────────────────────────────────────────────────────
# 3. CREATE RESTAURANT
#    URL: POST /api/restaurants
#    Body: JSON with restaurant fields
# ─────────────────────────────────────────────────────────────
def create_restaurant():
    """
    Creates a new restaurant document in MongoDB.

    Request Body (JSON):
        Required: name, description, cuisine_type, address, phone, email
        Optional: image_url, delivery_time_min, delivery_fee,
                  minimum_order, tags

    Returns:
        JSON with the newly created restaurant + its new ID
    """
    try:
        # ── Parse the incoming JSON body ─────────────────────────
        body = request.get_json()

        if not body:
            return jsonify(error_response(
                message="Request body is missing or not valid JSON.",
                status_code=400
            ))

        # ── Validate required fields ─────────────────────────────
        required = ["name", "description", "cuisine_type", "address", "phone", "email"]
        is_valid, err = validate_required_fields(body, required)
        if not is_valid:
            return jsonify(err[0]), err[1]

        # ── Validate address is a dict with required keys ────────
        address = body.get("address", {})
        if not isinstance(address, dict):
            return jsonify(error_response(
                message="'address' must be an object with keys: street, city, state, zip",
                status_code=422
            ))

        # ── Build the document using our Phase 1 model ───────────
        new_restaurant = create_restaurant_document(
            name              = body["name"],
            description       = body["description"],
            cuisine_type      = body["cuisine_type"],
            address           = address,
            phone             = body["phone"],
            email             = body["email"],
            image_url         = body.get("image_url", ""),
            delivery_time_min = body.get("delivery_time_min", 30),
            delivery_fee      = float(body.get("delivery_fee", 0.0)),
            minimum_order     = float(body.get("minimum_order", 0.0)),
            tags              = body.get("tags", []),
        )

        # ── Insert into MongoDB ──────────────────────────────────
        result = restaurants_collection.insert_one(new_restaurant)

        # ── Fetch the newly created document to return it ────────
        # We re-fetch so the response includes the auto-generated _id
        created = restaurants_collection.find_one({"_id": result.inserted_id})

        return jsonify(success_response(
            data={"restaurant": serialize_document(created)},
            message="Restaurant created successfully",
            status_code=201   # 201 = Created
        ))

    except Exception as e:
        return jsonify(error_response(
            message="Failed to create restaurant",
            status_code=500,
            errors=[str(e)]
        ))


# ─────────────────────────────────────────────────────────────
# 4. UPDATE RESTAURANT
#    URL: PUT /api/restaurants/<restaurant_id>
#    Body: JSON with only the fields you want to update
# ─────────────────────────────────────────────────────────────
def update_restaurant(restaurant_id: str):
    """
    Updates specific fields of an existing restaurant.

    Only the fields provided in the request body are updated.
    Fields not mentioned remain unchanged (partial update / PATCH style).

    Args:
        restaurant_id : ID of the restaurant to update
    """
    try:
        # ── Validate ID ──────────────────────────────────────────
        object_id, err = validate_object_id(restaurant_id)
        if err:
            return jsonify(err[0]), err[1]

        # ── Parse body ───────────────────────────────────────────
        body = request.get_json()
        if not body:
            return jsonify(error_response("Request body is empty.", 400))

        # ── Fields that are NOT allowed to be updated directly ───
        # These are managed automatically or by the system
        protected_fields = ["_id", "created_at", "rating", "total_reviews"]
        for field in protected_fields:
            body.pop(field, None)   # Silently remove if present

        # ── Always update the updated_at timestamp ───────────────
        body["updated_at"] = datetime.utcnow()

        # ── Perform the update in MongoDB ────────────────────────
        # $set operator: updates only the specified fields,
        # leaving all other fields untouched
        result = restaurants_collection.update_one(
            {"_id": object_id},
            {"$set": body}
        )

        if result.matched_count == 0:
            return jsonify(error_response(
                message=f"Restaurant with ID '{restaurant_id}' not found.",
                status_code=404
            ))

        # ── Return the updated document ──────────────────────────
        updated = restaurants_collection.find_one({"_id": object_id})
        return jsonify(success_response(
            data={"restaurant": serialize_document(updated)},
            message="Restaurant updated successfully"
        ))

    except Exception as e:
        return jsonify(error_response(
            message="Failed to update restaurant",
            status_code=500,
            errors=[str(e)]
        ))


# ─────────────────────────────────────────────────────────────
# 5. DELETE RESTAURANT
#    URL: DELETE /api/restaurants/<restaurant_id>
# ─────────────────────────────────────────────────────────────
def delete_restaurant(restaurant_id: str):
    """
    Permanently deletes a restaurant document from MongoDB.

    Note: In production, consider "soft delete" (setting
    is_deleted=True) instead of permanent deletion.

    Args:
        restaurant_id : ID of the restaurant to delete
    """
    try:
        object_id, err = validate_object_id(restaurant_id)
        if err:
            return jsonify(err[0]), err[1]

        result = restaurants_collection.delete_one({"_id": object_id})

        if result.deleted_count == 0:
            return jsonify(error_response(
                message=f"Restaurant with ID '{restaurant_id}' not found.",
                status_code=404
            ))

        return jsonify(success_response(
            data={"deleted_id": restaurant_id},
            message="Restaurant deleted successfully"
        ))

    except Exception as e:
        return jsonify(error_response(
            message="Failed to delete restaurant",
            status_code=500,
            errors=[str(e)]
        ))


# ─────────────────────────────────────────────────────────────
# 6. SEARCH RESTAURANTS
#    URL: GET /api/restaurants/search?q=burger
#    Searches name, description, cuisine_type, and tags fields
# ─────────────────────────────────────────────────────────────
def search_restaurants():
    """
    Full-text search across restaurant name, description,
    cuisine_type, and tags fields.

    Query Parameters:
        q       : The search keyword (required)
        page    : Page number
        limit   : Results per page

    Returns:
        JSON with list of matching restaurants
    """
    try:
        # ── Get search keyword ───────────────────────────────────
        keyword = request.args.get("q", "").strip()

        if not keyword:
            return jsonify(error_response(
                message="Search keyword 'q' is required. Example: /search?q=burger",
                status_code=400
            ))

        # ── Pagination ───────────────────────────────────────────
        page, limit, skip = get_pagination_params(request.args)

        # ── Build MongoDB search query ───────────────────────────
        # $or: matches documents where ANY of these conditions is true
        # $regex: pattern match, $options: "i" = case-insensitive
        search_filter = {
            "$or": [
                {"name":         {"$regex": keyword, "$options": "i"}},
                {"description":  {"$regex": keyword, "$options": "i"}},
                {"cuisine_type": {"$regex": keyword, "$options": "i"}},
                {"tags":         {"$regex": keyword, "$options": "i"}},
            ]
        }

        # ── Execute query ────────────────────────────────────────
        cursor = (
            restaurants_collection
            .find(search_filter)
            .sort("rating", -1)   # Sort by highest rated first
            .skip(skip)
            .limit(limit)
        )

        results = serialize_list(list(cursor))
        total_count = restaurants_collection.count_documents(search_filter)

        return jsonify(success_response(
            data={
                "restaurants": results,
                "search_keyword": keyword,
                "total_count": total_count,
            },
            message=f"Found {total_count} restaurant(s) matching '{keyword}'"
        ))

    except Exception as e:
        return jsonify(error_response(
            message="Search failed",
            status_code=500,
            errors=[str(e)]
        ))