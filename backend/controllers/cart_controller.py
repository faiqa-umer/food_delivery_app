# ============================================================
# FILE: backend/controllers/cart_controller.py
# PURPOSE: Contains ALL business logic for cart operations.
#          Routes call these functions. This keeps routes thin
#          and controllers fat — a clean architecture principle.
#
# FUNCTIONS IN THIS FILE:
#   get_user_cart()         → GET  /api/cart
#   add_to_cart()           → POST /api/cart
#   update_cart_item()      → PUT  /api/cart/<item_id>
#   remove_from_cart()      → DELETE /api/cart/<item_id>
#   clear_cart()            → DELETE /api/cart
# ============================================================

from flask import request, jsonify
from bson import ObjectId
from datetime import datetime

# ── Database and models ──────────────────────────────────────
from config.database import carts_collection, menu_items_collection
from models.cart_model import create_cart_document, create_cart_item_document

# ── Helpers ─────────────────────────────────────────────────
from utils.helpers import (
    success_response,
    error_response,
    serialize_document,
    validate_object_id,
    validate_required_fields,
)


# ─────────────────────────────────────────────────────────────
# 1. GET USER'S CART
#    URL: GET /api/cart
# ─────────────────────────────────────────────────────────────
def get_user_cart():
    """
    Fetches the current user's cart.

    Headers:
        Authorization: Bearer <jwt_token>

    Returns:
        JSON with cart data including items and total
    """
    try:
        # Get user_id from JWT (middleware handles this)
        user_id = request.user_id

        # Find user's cart
        cart = carts_collection.find_one({"user_id": user_id})

        if not cart:
            # Return empty cart structure
            return success_response(
                data={
                    "cart": {
                        "user_id": user_id,
                        "restaurant_id": None,
                        "items": [],
                        "total_amount": 0.0,
                        "created_at": datetime.utcnow(),
                        "updated_at": datetime.utcnow(),
                    }
                },
                message="Cart is empty"
            )

        # Serialize and return cart
        cart_data = serialize_document(cart)
        return success_response(
            data={"cart": cart_data},
            message="Cart retrieved successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to fetch cart",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 2. ADD ITEM TO CART
#    URL: POST /api/cart
# ─────────────────────────────────────────────────────────────
def add_to_cart():
    """
    Adds an item to the user's cart.

    Request Body:
        menu_item_id: string (required)
        quantity: int (required, min 1)
        special_instructions: string (optional)

    Returns:
        JSON with updated cart
    """
    try:
        user_id = request.user_id
        data = request.get_json()

        # Validate required fields
        required_fields = ["menu_item_id", "quantity"]
        is_valid, validation_error = validate_required_fields(data, required_fields)
        if not is_valid:
            return validation_error

        menu_item_id = data["menu_item_id"]
        quantity = data["quantity"]
        special_instructions = data.get("special_instructions", "")

        # Validate quantity
        if quantity < 1:
            return error_response(
                message="Quantity must be at least 1",
                status_code=400
            )

        # Check if menu item exists
        menu_item = menu_items_collection.find_one({"_id": ObjectId(menu_item_id)})
        if not menu_item:
            return error_response(
                message="Menu item not found",
                status_code=404
            )

        # Get current cart
        cart = carts_collection.find_one({"user_id": user_id})

        if cart:
            # Check if adding from different restaurant
            if cart["restaurant_id"] != menu_item["restaurant_id"]:
                return error_response(
                    message="Cannot add items from different restaurants. Clear cart first.",
                    status_code=400
                )

            # Check if item already in cart
            existing_item = None
            for item in cart["items"]:
                if item["menu_item_id"] == menu_item_id:
                    existing_item = item
                    break

            if existing_item:
                # Update quantity
                existing_item["quantity"] += quantity
            else:
                # Add new item
                new_item = create_cart_item_document(
                    menu_item_id=menu_item_id,
                    quantity=quantity,
                    price=menu_item["price"],
                    special_instructions=special_instructions
                )
                cart["items"].append(new_item)

            # Recalculate total
            cart["total_amount"] = sum(item["quantity"] * item["price"] for item in cart["items"])
            cart["updated_at"] = datetime.utcnow()

            # Update in database
            carts_collection.update_one(
                {"_id": cart["_id"]},
                {"$set": cart}
            )
        else:
            # Create new cart
            new_item = create_cart_item_document(
                menu_item_id=menu_item_id,
                quantity=quantity,
                price=menu_item["price"],
                special_instructions=special_instructions
            )

            cart = create_cart_document(
                user_id=user_id,
                restaurant_id=menu_item["restaurant_id"],
                items=[new_item],
                total_amount=menu_item["price"] * quantity
            )

            carts_collection.insert_one(cart)

        cart_data = serialize_document(cart)
        return success_response(
            data={"cart": cart_data},
            message="Item added to cart successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to add item to cart",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 3. UPDATE CART ITEM
#    URL: PUT /api/cart/<item_id>
# ─────────────────────────────────────────────────────────────
def update_cart_item(item_id: str):
    """
    Updates quantity or instructions of a cart item.

    Args:
        item_id: The cart item ID to update

    Request Body:
        quantity: int (optional)
        special_instructions: string (optional)

    Returns:
        JSON with updated cart
    """
    try:
        user_id = request.user_id
        data = request.get_json()

        # Get cart
        cart = carts_collection.find_one({"user_id": user_id})
        if not cart:
            return error_response(
                message="Cart not found",
                status_code=404
            )

        # Find item in cart
        item_found = False
        for item in cart["items"]:
            if str(item.get("_id", "")) == item_id:
                if "quantity" in data:
                    quantity = data["quantity"]
                    if quantity < 1:
                        return error_response(
                            message="Quantity must be at least 1",
                            status_code=400
                        )
                    item["quantity"] = quantity

                if "special_instructions" in data:
                    item["special_instructions"] = data["special_instructions"]

                item_found = True
                break

        if not item_found:
            return error_response(
                message="Cart item not found",
                status_code=404
            )

        # Recalculate total
        cart["total_amount"] = sum(item["quantity"] * item["price"] for item in cart["items"])
        cart["updated_at"] = datetime.utcnow()

        # Update in database
        carts_collection.update_one(
            {"_id": cart["_id"]},
            {"$set": cart}
        )

        cart_data = serialize_document(cart)
        return success_response(
            data={"cart": cart_data},
            message="Cart item updated successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to update cart item",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 4. REMOVE ITEM FROM CART
#    URL: DELETE /api/cart/<item_id>
# ─────────────────────────────────────────────────────────────
def remove_from_cart(item_id: str):
    """
    Removes an item from the cart.

    Args:
        item_id: The cart item ID to remove

    Returns:
        JSON with updated cart
    """
    try:
        user_id = request.user_id

        # Get cart
        cart = carts_collection.find_one({"user_id": user_id})
        if not cart:
            return error_response(
                message="Cart not found",
                status_code=404
            )

        # Find and remove item
        item_found = False
        for i, item in enumerate(cart["items"]):
            if str(item.get("_id", "")) == item_id:
                cart["items"].pop(i)
                item_found = True
                break

        if not item_found:
            return error_response(
                message="Cart item not found",
                status_code=404
            )

        # Recalculate total
        cart["total_amount"] = sum(item["quantity"] * item["price"] for item in cart["items"])
        cart["updated_at"] = datetime.utcnow()

        # Update in database
        carts_collection.update_one(
            {"_id": cart["_id"]},
            {"$set": cart}
        )

        cart_data = serialize_document(cart)
        return success_response(
            data={"cart": cart_data},
            message="Item removed from cart successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to remove item from cart",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 5. CLEAR ENTIRE CART
#    URL: DELETE /api/cart
# ─────────────────────────────────────────────────────────────
def clear_cart():
    """
    Removes all items from the user's cart.

    Returns:
        JSON confirmation
    """
    try:
        user_id = request.user_id

        # Delete cart
        result = carts_collection.delete_one({"user_id": user_id})

        return success_response(
            data={"deleted": result.deleted_count > 0},
            message="Cart cleared successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to clear cart",
            status_code=500,
            errors=[str(e)]
        )