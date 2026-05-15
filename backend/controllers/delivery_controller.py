# ============================================================
# FILE: backend/controllers/delivery_controller.py
# PURPOSE: Contains ALL business logic for delivery operations.
#          Routes call these functions. This keeps routes thin
#          and controllers fat — a clean architecture principle.
#
# FUNCTIONS IN THIS FILE:
#   get_delivery_status()   → GET  /api/deliveries/<order_id>
#   update_delivery_status() → PUT  /api/deliveries/<order_id>
#   update_location()       → PUT  /api/deliveries/<order_id>/location
#   rate_delivery()         → POST /api/deliveries/<order_id>/rating
# ============================================================

from flask import request, jsonify
from bson import ObjectId
from datetime import datetime

# ── Database and models ──────────────────────────────────────
from config.database import deliveries_collection, orders_collection
from models.delivery_model import create_delivery_document

# ── Helpers ─────────────────────────────────────────────────
from utils.helpers import (
    success_response,
    error_response,
    serialize_document,
    validate_object_id,
    validate_required_fields,
)


# ─────────────────────────────────────────────────────────────
# 1. GET DELIVERY STATUS
#    URL: GET /api/deliveries/<order_id>
# ─────────────────────────────────────────────────────────────
def get_delivery_status(order_id: str):
    """
    Fetches delivery details for an order.

    Args:
        order_id: The order ID

    Returns:
        JSON with delivery details
    """
    try:
        user_id = request.user_id

        # Validate order ID
        order_object_id, err = validate_object_id(order_id)
        if err:
            return jsonify(err[0]), err[1]

        # Get order
        order = orders_collection.find_one({
            "_id": order_object_id,
            "user_id": user_id
        })

        if not order:
            return error_response(
                message="Order not found",
                status_code=404
            )

        if not order.get("delivery_id"):
            return error_response(
                message="No delivery assigned to this order yet",
                status_code=404
            )

        # Get delivery
        delivery = deliveries_collection.find_one({
            "_id": ObjectId(order["delivery_id"])
        })

        if not delivery:
            return error_response(
                message="Delivery record not found",
                status_code=404
            )

        delivery_data = serialize_document(delivery)
        return success_response(
            data={"delivery": delivery_data},
            message="Delivery status retrieved successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to fetch delivery status",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 2. UPDATE DELIVERY STATUS
#    URL: PUT /api/deliveries/<order_id>
# ─────────────────────────────────────────────────────────────
def update_delivery_status(order_id: str):
    """
    Updates the delivery status for an order.

    Args:
        order_id: The order ID

    Request Body:
        status: string (required)
        rider_id: string (optional, for assignment)
        estimated_delivery_time: datetime (optional)

    Returns:
        JSON with updated delivery
    """
    try:
        data = request.get_json()

        status = data.get("status")
        rider_id = data.get("rider_id")
        estimated_delivery_time = data.get("estimated_delivery_time")

        if not status:
            return error_response(
                message="Status is required",
                status_code=400
            )

        valid_statuses = ["assigned", "picked_up", "out_for_delivery", "delivered"]
        if status not in valid_statuses:
            return error_response(
                message=f"Invalid status. Must be one of: {', '.join(valid_statuses)}",
                status_code=400
            )

        # Validate order ID
        order_object_id, err = validate_object_id(order_id)
        if err:
            return jsonify(err[0]), err[1]

        # Get order
        order = orders_collection.find_one({"_id": order_object_id})
        if not order:
            return error_response(
                message="Order not found",
                status_code=404
            )

        delivery_id = order.get("delivery_id")

        if not delivery_id:
            # Create new delivery if none exists
            delivery = create_delivery_document(
                order_id=order_id,
                rider_id=rider_id,
                status=status,
                estimated_delivery_time=estimated_delivery_time
            )

            result = deliveries_collection.insert_one(delivery)
            delivery["_id"] = result.inserted_id
            delivery_id = str(result.inserted_id)

            # Update order with delivery ID
            orders_collection.update_one(
                {"_id": order_object_id},
                {"$set": {"delivery_id": delivery_id}}
            )
        else:
            # Update existing delivery
            update_data = {
                "status": status,
                "updated_at": datetime.utcnow()
            }

            if rider_id:
                update_data["rider_id"] = rider_id

            if estimated_delivery_time:
                update_data["estimated_delivery_time"] = estimated_delivery_time

            if status == "delivered":
                update_data["actual_delivery_time"] = datetime.utcnow()

            deliveries_collection.update_one(
                {"_id": ObjectId(delivery_id)},
                {"$set": update_data}
            )

            delivery = deliveries_collection.find_one({"_id": ObjectId(delivery_id)})

        delivery_data = serialize_document(delivery)
        return success_response(
            data={"delivery": delivery_data},
            message="Delivery status updated successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to update delivery status",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 3. UPDATE DELIVERY LOCATION
#    URL: PUT /api/deliveries/<order_id>/location
# ─────────────────────────────────────────────────────────────
def update_location(order_id: str):
    """
    Updates the real-time location of a delivery.

    Args:
        order_id: The order ID

    Request Body:
        lat: float (required)
        lng: float (required)

    Returns:
        JSON confirmation
    """
    try:
        data = request.get_json()

        lat = data.get("lat")
        lng = data.get("lng")

        if lat is None or lng is None:
            return error_response(
                message="Both lat and lng coordinates are required",
                status_code=400
            )

        # Validate coordinates
        if not (-90 <= lat <= 90) or not (-180 <= lng <= 180):
            return error_response(
                message="Invalid coordinates",
                status_code=400
            )

        # Validate order ID
        order_object_id, err = validate_object_id(order_id)
        if err:
            return jsonify(err[0]), err[1]

        # Get order
        order = orders_collection.find_one({"_id": order_object_id})
        if not order or not order.get("delivery_id"):
            return error_response(
                message="Delivery not found for this order",
                status_code=404
            )

        # Update location
        deliveries_collection.update_one(
            {"_id": ObjectId(order["delivery_id"])},
            {
                "$set": {
                    "current_location": {"lat": lat, "lng": lng},
                    "updated_at": datetime.utcnow()
                }
            }
        )

        return success_response(
            data={"location": {"lat": lat, "lng": lng}},
            message="Location updated successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to update location",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 4. RATE DELIVERY
#    URL: POST /api/deliveries/<order_id>/rating
# ─────────────────────────────────────────────────────────────
def rate_delivery(order_id: str):
    """
    Allows customer to rate their delivery experience.

    Args:
        order_id: The order ID

    Request Body:
        rating: float (required, 1.0-5.0)
        feedback: string (optional)

    Returns:
        JSON confirmation
    """
    try:
        user_id = request.user_id
        data = request.get_json()

        rating = data.get("rating")
        feedback = data.get("feedback", "")

        if rating is None:
            return error_response(
                message="Rating is required",
                status_code=400
            )

        if not (1.0 <= rating <= 5.0):
            return error_response(
                message="Rating must be between 1.0 and 5.0",
                status_code=400
            )

        # Validate order ID
        order_object_id, err = validate_object_id(order_id)
        if err:
            return jsonify(err[0]), err[1]

        # Get order
        order = orders_collection.find_one({
            "_id": order_object_id,
            "user_id": user_id
        })

        if not order:
            return error_response(
                message="Order not found",
                status_code=404
            )

        if not order.get("delivery_id"):
            return error_response(
                message="No delivery found for this order",
                status_code=404
            )

        # Check if delivery is completed
        delivery = deliveries_collection.find_one({
            "_id": ObjectId(order["delivery_id"])
        })

        if not delivery or delivery["status"] != "delivered":
            return error_response(
                message="Can only rate completed deliveries",
                status_code=400
            )

        # Update delivery with rating
        deliveries_collection.update_one(
            {"_id": ObjectId(order["delivery_id"])},
            {
                "$set": {
                    "customer_rating": rating,
                    "customer_feedback": feedback,
                    "updated_at": datetime.utcnow()
                }
            }
        )

        return success_response(
            data={
                "rating": rating,
                "feedback": feedback
            },
            message="Delivery rated successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to rate delivery",
            status_code=500,
            errors=[str(e)]
        )