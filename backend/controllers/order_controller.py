# ============================================================
# FILE: backend/controllers/order_controller.py
# PURPOSE: Contains ALL business logic for order operations.
#          Routes call these functions. This keeps routes thin
#          and controllers fat — a clean architecture principle.
#
# FUNCTIONS IN THIS FILE:
#   create_order()          → POST /api/orders
#   get_user_orders()       → GET  /api/orders
#   get_order_by_id()       → GET  /api/orders/<order_id>
#   update_order_status()   → PUT  /api/orders/<order_id>
#   get_order_items()       → GET  /api/orders/<order_id>/items
# ============================================================

from flask import request, jsonify
from bson import ObjectId
from datetime import datetime


# ── Database and models ──────────────────────────────────────
from config.database import (
    orders_collection,
    order_items_collection,
    carts_collection,
    payments_collection,
    deliveries_collection,
    restaurants_collection
)
from models.order_model import create_order_document, create_order_item_document

# ── Helpers ─────────────────────────────────────────────────
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
# 1. CREATE ORDER FROM CART
#    URL: POST /api/orders
# ─────────────────────────────────────────────────────────────
def create_order():
    """
    Creates a new order from the user's cart.

    Request Body:
        delivery_address: object (required)
            street: string
            city: string
            state: string
            zip: string

    Returns:
        JSON with created order
    """
    try:
        user_id = request.user_id
        data = request.get_json()

        # Validate delivery address
        delivery_address = data.get("delivery_address")
        if not delivery_address:
            return error_response(
                message="Delivery address is required",
                status_code=400
            )

        required_address_fields = ["street", "city", "state", "zip"]
        is_valid, validation_error = validate_required_fields(delivery_address, required_address_fields)
        if not is_valid:
            return validation_error

        # Get user's cart
        cart = carts_collection.find_one({"user_id": user_id})
        if not cart or not cart["items"]:
            return error_response(
                message="Cart is empty",
                status_code=400
            )

        # Check restaurant exists
        restaurant = restaurants_collection.find_one({"_id": ObjectId(cart["restaurant_id"])})
        if not restaurant:
            return error_response(
                message="Restaurant not found",
                status_code=404
            )

        # Create order items
        order_item_ids = []
        for cart_item in cart["items"]:
            order_item = create_order_item_document(
                order_id="",  # Will update after order creation
                menu_item_id=cart_item["menu_item_id"],
                quantity=cart_item["quantity"],
                price=cart_item["price"],
                special_instructions=cart_item.get("special_instructions", "")
            )
            result = order_items_collection.insert_one(order_item)
            order_item["_id"] = result.inserted_id
            order_item_ids.append(str(result.inserted_id))

        # Create order
        order = create_order_document(
            user_id=user_id,
            restaurant_id=cart["restaurant_id"],
            items=order_item_ids,
            total_amount=cart["total_amount"],
            delivery_address=delivery_address,
            status="pending"
        )

        result = orders_collection.insert_one(order)
        order["_id"] = result.inserted_id
        order_id = str(result.inserted_id)

        # Update order_id in order items
        order_items_collection.update_many(
            {"_id": {"$in": [ObjectId(oid) for oid in order_item_ids]}},
            {"$set": {"order_id": order_id}}
        )

        # Clear cart after successful order
        carts_collection.delete_one({"user_id": user_id})

        order_data = serialize_document(order)
        return success_response(
            data={"order": order_data},
            message="Order created successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to create order",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 2. GET USER'S ORDERS
#    URL: GET /api/orders
# ─────────────────────────────────────────────────────────────
def get_user_orders():
    """
    Fetches user's order history with pagination.

    Query Parameters:
        page: int (default: 1)
        limit: int (default: 10)
        status: string (optional filter)

    Returns:
        JSON with orders list and pagination
    """
    try:
        user_id = request.user_id
        page, limit, skip = get_pagination_params(request.args)

        # Build filter
        query_filter = {"user_id": user_id}
        status = request.args.get("status")
        if status:
            query_filter["status"] = status

        # Get orders
        cursor = (
            orders_collection
            .find(query_filter)
            .sort("created_at", -1)
            .skip(skip)
            .limit(limit)
        )

        orders = serialize_list(list(cursor))
        total_count = orders_collection.count_documents(query_filter)
        total_pages = (total_count + limit - 1) // limit

        return success_response(
            data={
                "orders": orders,
                "pagination": {
                    "current_page": page,
                    "total_pages": total_pages,
                    "total_count": total_count,
                    "limit": limit,
                    "has_next": page < total_pages,
                    "has_prev": page > 1,
                }
            },
            message=f"Retrieved {len(orders)} order(s)"
        )

    except Exception as e:
        return error_response(
            message="Failed to fetch orders",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 3. GET ORDER BY ID
#    URL: GET /api/orders/<order_id>
# ─────────────────────────────────────────────────────────────
def get_order_by_id(order_id: str):
    """
    Fetches a specific order with full details.

    Args:
        order_id: The order ID

    Returns:
        JSON with order details
    """
    try:
        user_id = request.user_id

        # Validate order ID
        object_id, err = validate_object_id(order_id)
        if err:
            return jsonify(err[0]), err[1]

        # Get order
        order = orders_collection.find_one({
            "_id": object_id,
            "user_id": user_id  # Ensure user owns the order
        })

        if not order:
            return error_response(
                message="Order not found",
                status_code=404
            )

        # Get order items
        order_items = list(order_items_collection.find({
            "order_id": order_id
        }))
        order["items_details"] = serialize_list(order_items)

        order_data = serialize_document(order)
        return success_response(
            data={"order": order_data},
            message="Order retrieved successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to fetch order",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 4. UPDATE ORDER STATUS
#    URL: PUT /api/orders/<order_id>
# ─────────────────────────────────────────────────────────────
def update_order_status(order_id: str):
    """
    Updates the status of an order.

    Args:
        order_id: The order ID

    Request Body:
        status: string (required)

    Returns:
        JSON with updated order
    """
    try:
        data = request.get_json()
        status = data.get("status")

        if not status:
            return error_response(
                message="Status is required",
                status_code=400
            )

        valid_statuses = ["pending", "confirmed", "preparing", "ready", "out_for_delivery", "delivered", "cancelled"]
        if status not in valid_statuses:
            return error_response(
                message=f"Invalid status. Must be one of: {', '.join(valid_statuses)}",
                status_code=400
            )

        # Validate order ID
        object_id, err = validate_object_id(order_id)
        if err:
            return jsonify(err[0]), err[1]

        # Update order
        result = orders_collection.update_one(
            {"_id": object_id},
            {
                "$set": {
                    "status": status,
                    "updated_at": datetime.utcnow()
                }
            }
        )

        if result.matched_count == 0:
            return error_response(
                message="Order not found",
                status_code=404
            )

        # Get updated order
        order = orders_collection.find_one({"_id": object_id})
        order_data = serialize_document(order)

        return success_response(
            data={"order": order_data},
            message="Order status updated successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to update order status",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 5. GET ORDER ITEMS
#    URL: GET /api/orders/<order_id>/items
# ─────────────────────────────────────────────────────────────
def get_order_items(order_id: str):
    """
    Fetches all items for a specific order.

    Args:
        order_id: The order ID

    Returns:
        JSON with order items
    """
    try:
        user_id = request.user_id

        # Validate order ID
        object_id, err = validate_object_id(order_id)
        if err:
            return jsonify(err[0]), err[1]

        # Verify order ownership
        order = orders_collection.find_one({
            "_id": object_id,
            "user_id": user_id
        })

        if not order:
            return error_response(
                message="Order not found",
                status_code=404
            )

        # Get order items
        order_items = list(order_items_collection.find({
            "order_id": order_id
        }))

        items_data = serialize_list(order_items)
        return success_response(
            data={"items": items_data},
            message=f"Retrieved {len(items_data)} item(s)"
        )

    except Exception as e:
        return error_response(
            message="Failed to fetch order items",
            status_code=500,
            errors=[str(e)]
        )