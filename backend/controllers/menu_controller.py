# ============================================================
# FILE: backend/controllers/menu_controller.py
# PURPOSE: Business logic for all menu item operations.
#          Menu items always belong to a restaurant, so most
#          queries filter by restaurant_id.
#
# FUNCTIONS:
#   get_menu_by_restaurant()  → GET  /api/menu/restaurant/<id>
#   get_menu_item_by_id()     → GET  /api/menu/<id>
#   create_menu_item()        → POST /api/menu
#   update_menu_item()        → PUT  /api/menu/<id>
#   delete_menu_item()        → DELETE /api/menu/<id>
#   get_menu_categories()     → GET  /api/menu/restaurant/<id>/categories
# ============================================================

from flask import request, jsonify
from datetime import datetime
from bson import ObjectId

from config.database import menu_items_collection, restaurants_collection
from models.menu_item_model import create_menu_item_document
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
# 1. GET ALL MENU ITEMS FOR A RESTAURANT
#    URL: GET /api/menu/restaurant/<restaurant_id>
#         GET /api/menu/restaurant/<id>?category=Burgers
# ─────────────────────────────────────────────────────────────
def get_menu_by_restaurant(restaurant_id: str):
    """
    Returns all menu items belonging to a specific restaurant.
    Can be filtered by category (e.g., Burgers, Drinks).

    Args:
        restaurant_id : The restaurant whose menu we want

    Query Parameters (optional):
        category    : Filter by menu category
        available   : "true" / "false" — filter by availability
        page, limit : Pagination
    """
    try:
        # ── Convert the restaurant ID to ObjectId if possible ───
        try:
            object_id = ObjectId(restaurant_id)
        except Exception:
            return error_response(
                message=f"Invalid restaurant ID format: '{restaurant_id}'.",
                status_code=400
            )

        # ── Confirm the restaurant actually exists ───────────────
        restaurant = restaurants_collection.find_one({"_id": object_id})
        if not restaurant:
            return error_response(
                message=f"Restaurant with ID '{restaurant_id}' not found.",
                status_code=404
            )

        # ── Build the query filter ───────────────────────────────
        # Match menu items stored with either the plain string ID
        # or the BSON ObjectId value.
        query_filter = {
            "restaurant_id": {"$in": [restaurant_id, object_id]}
        }

        # Optional: filter by category
        category = request.args.get("category")
        if category:
            query_filter["category"] = {"$regex": category, "$options": "i"}

        # Optional: filter by availability
        available_param = request.args.get("available")
        if available_param is not None:
            query_filter["is_available"] = (available_param.lower() == "true")

        # ── Pagination ───────────────────────────────────────────
        page, limit, skip = get_pagination_params(request.args)

        # ── Fetch menu items ─────────────────────────────────────
        cursor = (
            menu_items_collection
            .find(query_filter)
            .sort("category", 1)   # Sort alphabetically by category
            .skip(skip)
            .limit(limit)
        )

        items = serialize_list(list(cursor))
        total_count = menu_items_collection.count_documents(query_filter)

        # ── Group items by category for easy Flutter rendering ───
        # Flutter menu screen can use this to render category sections
        grouped = {}
        for item in items:
            cat = item.get("category", "Other")
            grouped.setdefault(cat, []).append(item)

        return success_response(
            data={
                "restaurant_id":   restaurant_id,
                "restaurant_name": restaurant.get("name", ""),
                "menu_items":      items,         # flat list
                "grouped_by_category": grouped,   # grouped dict for UI sections
                "total_count":     total_count,
                "pagination": {
                    "current_page": page,
                    "limit":        limit,
                }
            },
            message=f"Retrieved {len(items)} menu item(s)"
        )

    except Exception as e:
        return error_response(
            message="Failed to fetch menu",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 2. GET SINGLE MENU ITEM BY ID
#    URL: GET /api/menu/<menu_item_id>
# ─────────────────────────────────────────────────────────────
def get_all_menu_items():
    """
    Returns all menu items in the system.

    Query Parameters:
        category  : filter by category
        available : true/false
        page      : page number
        limit     : results per page
    """
    try:
        page, limit, skip = get_pagination_params(request.args)

        query_filter = {}
        category = request.args.get("category")
        if category:
            query_filter["category"] = {"$regex": category, "$options": "i"}

        available_param = request.args.get("available")
        if available_param is not None:
            query_filter["is_available"] = available_param.lower() == "true"

        cursor = (
            menu_items_collection
            .find(query_filter)
            .sort("created_at", -1)
            .skip(skip)
            .limit(limit)
        )

        items = serialize_list(list(cursor))
        total_count = menu_items_collection.count_documents(query_filter)
        total_pages = (total_count + limit - 1) // limit

        return success_response(
            data={
                "menu_items": items,
                "pagination": {
                    "current_page": page,
                    "limit": limit,
                    "total_pages": total_pages,
                    "total_count": total_count,
                    "has_next": page < total_pages,
                    "has_prev": page > 1,
                }
            },
            message=f"Retrieved {len(items)} menu item(s)"
        )

    except Exception as e:
        return error_response(
            message="Failed to fetch menu items",
            status_code=500,
            errors=[str(e)]
        )


def get_menu_item_by_id(menu_item_id: str):
    """
    Fetches a single menu item by its MongoDB _id.

    Args:
        menu_item_id : The 24-character hex ID from the URL
    """
    try:
        object_id, err = validate_object_id(menu_item_id)
        if err:
            return jsonify(err[0]), err[1]

        item = menu_items_collection.find_one({"_id": object_id})

        if not item:
            return error_response(
                message=f"Menu item with ID '{menu_item_id}' not found.",
                status_code=404
            )

        return success_response(
            data={"menu_item": serialize_document(item)},
            message="Menu item retrieved successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to fetch menu item",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 3. CREATE MENU ITEM
#    URL: POST /api/menu
#    Body: JSON with all menu item fields
# ─────────────────────────────────────────────────────────────
def create_menu_item():
    """
    Creates a new menu item linked to an existing restaurant.

    Request Body (JSON):
        Required: restaurant_id, name, description, price, category
        Optional: image_url, is_available, is_vegetarian, is_vegan,
                  is_spicy, calories, preparation_time_min, discount_percent

    Returns:
        JSON with the newly created menu item
    """
    try:
        body = request.get_json()
        if not body:
            return error_response("Request body missing or invalid JSON.", 400)

        # ── Validate required fields ─────────────────────────────
        required = ["restaurant_id", "name", "description", "price", "category"]
        is_valid, err = validate_required_fields(body, required)
        if not is_valid:
            return jsonify(err[0]), err[1]

        # ── Confirm the parent restaurant exists ─────────────────
        object_id, err = validate_object_id(body["restaurant_id"])
        if err:
            return jsonify(err[0]), err[1]

        restaurant = restaurants_collection.find_one({"_id": object_id})
        if not restaurant:
            return error_response(
                message=f"Cannot add menu item — restaurant ID '{body['restaurant_id']}' not found.",
                status_code=404
            )

        # ── Validate price is a positive number ─────────────────
        try:
            price = float(body["price"])
            if price < 0:
                raise ValueError()
        except (ValueError, TypeError):
            return error_response(
                message="'price' must be a positive number.",
                status_code=422
            )

        # ── Build and insert the document ─────────────────────────
        new_item = create_menu_item_document(
            restaurant_id        = body["restaurant_id"],
            name                 = body["name"],
            description          = body["description"],
            price                = price,
            category             = body["category"],
            image_url            = body.get("image_url", ""),
            is_available         = bool(body.get("is_available", True)),
            is_vegetarian        = bool(body.get("is_vegetarian", False)),
            is_vegan             = bool(body.get("is_vegan", False)),
            is_spicy             = bool(body.get("is_spicy", False)),
            calories             = int(body.get("calories", 0)),
            preparation_time_min = int(body.get("preparation_time_min", 15)),
            discount_percent     = float(body.get("discount_percent", 0.0)),
        )

        result  = menu_items_collection.insert_one(new_item)
        created = menu_items_collection.find_one({"_id": result.inserted_id})

        return success_response(
            data={"menu_item": serialize_document(created)},
            message="Menu item created successfully",
            status_code=201
        )

    except Exception as e:
        return error_response(
            message="Failed to create menu item",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 4. UPDATE MENU ITEM
#    URL: PUT /api/menu/<menu_item_id>
# ─────────────────────────────────────────────────────────────
def update_menu_item(menu_item_id: str):
    """
    Updates specific fields of a menu item.

    Common use case: toggling is_available when a dish runs out.
    e.g., PUT /api/menu/<id>  Body: { "is_available": false }
    """
    try:
        object_id, err = validate_object_id(menu_item_id)
        if err:
            return jsonify(err[0]), err[1]

        body = request.get_json()
        if not body:
            return error_response("Request body is empty.", 400)

        # ── Protect system-managed fields ────────────────────────
        protected = ["_id", "restaurant_id", "created_at"]
        for field in protected:
            body.pop(field, None)

        # ── Recalculate discounted price if price or discount changed ──
        if "price" in body or "discount_percent" in body:
            # Fetch current values to fill missing ones
            current = menu_items_collection.find_one({"_id": object_id})
            if current:
                price            = float(body.get("price", current.get("price", 0)))
                discount_percent = float(body.get("discount_percent", current.get("discount_percent", 0)))
                body["discounted_price"] = round(price - (price * discount_percent / 100), 2)

        body["updated_at"] = datetime.utcnow()

        result = menu_items_collection.update_one(
            {"_id": object_id},
            {"$set": body}
        )

        if result.matched_count == 0:
            return error_response(
                message=f"Menu item with ID '{menu_item_id}' not found.",
                status_code=404
            )

        updated = menu_items_collection.find_one({"_id": object_id})
        return success_response(
            data={"menu_item": serialize_document(updated)},
            message="Menu item updated successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to update menu item",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 5. DELETE MENU ITEM
#    URL: DELETE /api/menu/<menu_item_id>
# ─────────────────────────────────────────────────────────────
def delete_menu_item(menu_item_id: str):
    """Permanently removes a menu item from MongoDB."""
    try:
        object_id, err = validate_object_id(menu_item_id)
        if err:
            return jsonify(err[0]), err[1]

        result = menu_items_collection.delete_one({"_id": object_id})

        if result.deleted_count == 0:
            return error_response(
                message=f"Menu item with ID '{menu_item_id}' not found.",
                status_code=404
            )

        return success_response(
            data={"deleted_id": menu_item_id},
            message="Menu item deleted successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to delete menu item",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 6. GET MENU CATEGORIES FOR A RESTAURANT
#    URL: GET /api/menu/restaurant/<restaurant_id>/categories
#    Returns a list of distinct category names.
#    Used by Flutter to render the category tab bar.
# ─────────────────────────────────────────────────────────────
def get_menu_categories(restaurant_id: str):
    """
    Returns all unique menu categories for a restaurant.

    Example response:
        { "categories": ["Burgers", "Drinks", "Desserts", "Sides"] }

    Flutter uses this to build the horizontal tab bar on the menu screen.
    """
    try:
        object_id, err = validate_object_id(restaurant_id)
        if err:
            return jsonify(err[0]), err[1]

        # Support both string and ObjectId storage formats for restaurant_id
        categories = menu_items_collection.distinct(
            "category",
            {"restaurant_id": {"$in": [restaurant_id, object_id]}}
        )

        return success_response(
            data={"categories": sorted(categories)},  # sort alphabetically
            message=f"Found {len(categories)} category/categories"
        )

    except Exception as e:
        return error_response(
            message="Failed to fetch categories",
            status_code=500,
            errors=[str(e)]
        )