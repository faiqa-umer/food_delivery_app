# ============================================================
# FILE: backend/controllers/payment_controller.py
# PURPOSE: Contains ALL business logic for payment operations.
#          Routes call these functions. This keeps routes thin
#          and controllers fat — a clean architecture principle.
#
# FUNCTIONS IN THIS FILE:
#   process_payment()       → POST /api/payments
#   get_payment_status()    → GET  /api/payments/<payment_id>
#   update_payment()        → PUT  /api/payments/<payment_id>
#   get_order_payment()     → GET  /api/payments/orders/<order_id>
# ============================================================

from flask import request, jsonify
from bson import ObjectId
from datetime import datetime
import uuid

# ── Database and models ──────────────────────────────────────
from config.database import payments_collection, orders_collection, deliveries_collection
from models.payment_model import create_payment_document
from models.delivery_model import create_delivery_document

# ── Services ────────────────────────────────────────────────
from services.payment_service import process_payment_with_gateway

# ── Helpers ─────────────────────────────────────────────────
from utils.helpers import (
    success_response,
    error_response,
    serialize_document,
    validate_object_id,
    validate_required_fields,
)


# ─────────────────────────────────────────────────────────────
# 1. PROCESS PAYMENT
#    URL: POST /api/payments
# ─────────────────────────────────────────────────────────────
def process_payment():
    """
    Processes payment for an order.

    Request Body:
        order_id: string (required)
        method: string (required) - cash, card, jazzcash, easypaisa
        amount: float (optional, will use order total if not provided)

    Returns:
        JSON with payment details
    """
    try:
        user_id = request.user_id
        data = request.get_json()

        # Validate required fields
        required_fields = ["order_id", "method"]
        is_valid, validation_error = validate_required_fields(data, required_fields)
        if not is_valid:
            return validation_error

        order_id = data["order_id"]
        method = data["method"]
        amount = data.get("amount")

        # Validate payment method
        valid_methods = ["cash", "card", "jazzcash", "easypaisa"]
        if method not in valid_methods:
            return error_response(
                message=f"Invalid payment method. Must be one of: {', '.join(valid_methods)}",
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

        # Check if payment already exists
        existing_payment = payments_collection.find_one({"order_id": order_id})
        if existing_payment:
            return error_response(
                message="Payment already exists for this order",
                status_code=400
            )

        # Use order total if amount not provided
        if amount is None:
            amount = order["total_amount"]

        # Create payment document
        payment = create_payment_document(
            order_id=order_id,
            user_id=user_id,
            amount=amount,
            method=method,
            status="pending",
            transaction_id=str(uuid.uuid4())
        )

        # Process payment with gateway (mock for now)
        gateway_result = process_payment_with_gateway(payment, method)

        if gateway_result["success"]:
            payment["status"] = "completed"
            payment["transaction_id"] = gateway_result.get("transaction_id", payment["transaction_id"])
        else:
            payment["status"] = "failed"

        payment["updated_at"] = datetime.utcnow()

        # Save payment
        result = payments_collection.insert_one(payment)
        payment["_id"] = result.inserted_id
        payment_id = str(result.inserted_id)

        # Update order with payment ID and confirmed status
        orders_collection.update_one(
            {"_id": order_object_id},
            {"$set": {"payment_id": payment_id, "status": "confirmed"}}
        )

        # Create an initial delivery record and attach it to the order
        delivery = create_delivery_document(
            order_id=order_id,
            status="assigned",
            rider_id=None,
            current_location={"lat": 0.0, "lng": 0.0}
        )
        delivery_result = deliveries_collection.insert_one(delivery)
        delivery_id = str(delivery_result.inserted_id)

        orders_collection.update_one(
            {"_id": order_object_id},
            {"$set": {"delivery_id": delivery_id}}
        )

        payment_data = serialize_document(payment)
        return success_response(
            data={"payment": payment_data},
            message="Payment processed successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to process payment",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 2. GET PAYMENT STATUS
#    URL: GET /api/payments/<payment_id>
# ─────────────────────────────────────────────────────────────
def get_payment_status(payment_id: str):
    """
    Fetches payment details by payment ID.

    Args:
        payment_id: The payment ID

    Returns:
        JSON with payment details
    """
    try:
        user_id = request.user_id

        # Validate payment ID
        object_id, err = validate_object_id(payment_id)
        if err:
            return jsonify(err[0]), err[1]

        # Get payment
        payment = payments_collection.find_one({
            "_id": object_id,
            "user_id": user_id  # Ensure user owns the payment
        })

        if not payment:
            return error_response(
                message="Payment not found",
                status_code=404
            )

        payment_data = serialize_document(payment)
        return success_response(
            data={"payment": payment_data},
            message="Payment retrieved successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to fetch payment",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 3. UPDATE PAYMENT (WEBHOOK)
#    URL: PUT /api/payments/<payment_id>
# ─────────────────────────────────────────────────────────────
def update_payment(payment_id: str):
    """
    Updates payment status (typically called by payment gateway webhook).

    Args:
        payment_id: The payment ID

    Request Body:
        status: string (required)
        transaction_id: string (optional)

    Returns:
        JSON with updated payment
    """
    try:
        data = request.get_json()

        status = data.get("status")
        transaction_id = data.get("transaction_id")

        if not status:
            return error_response(
                message="Status is required",
                status_code=400
            )

        valid_statuses = ["pending", "completed", "failed", "refunded"]
        if status not in valid_statuses:
            return error_response(
                message=f"Invalid status. Must be one of: {', '.join(valid_statuses)}",
                status_code=400
            )

        # Validate payment ID
        object_id, err = validate_object_id(payment_id)
        if err:
            return jsonify(err[0]), err[1]

        # Update payment
        update_data = {
            "status": status,
            "updated_at": datetime.utcnow()
        }

        if transaction_id:
            update_data["transaction_id"] = transaction_id

        result = payments_collection.update_one(
            {"_id": object_id},
            {"$set": update_data}
        )

        if result.matched_count == 0:
            return error_response(
                message="Payment not found",
                status_code=404
            )

        # Get updated payment
        payment = payments_collection.find_one({"_id": object_id})
        payment_data = serialize_document(payment)

        return success_response(
            data={"payment": payment_data},
            message="Payment updated successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to update payment",
            status_code=500,
            errors=[str(e)]
        )


# ─────────────────────────────────────────────────────────────
# 4. GET PAYMENT FOR ORDER
#    URL: GET /api/payments/orders/<order_id>
# ─────────────────────────────────────────────────────────────
def get_order_payment(order_id: str):
    """
    Fetches payment details for a specific order.

    Args:
        order_id: The order ID

    Returns:
        JSON with payment details
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

        if not order.get("payment_id"):
            return error_response(
                message="No payment found for this order",
                status_code=404
            )

        # Get payment
        payment = payments_collection.find_one({
            "_id": ObjectId(order["payment_id"])
        })

        if not payment:
            return error_response(
                message="Payment record not found",
                status_code=404
            )

        payment_data = serialize_document(payment)
        return success_response(
            data={"payment": payment_data},
            message="Payment retrieved successfully"
        )

    except Exception as e:
        return error_response(
            message="Failed to fetch order payment",
            status_code=500,
            errors=[str(e)]
        )