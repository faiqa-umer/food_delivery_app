# ============================================================
# FILE: backend/controllers/notification_controller.py
# PURPOSE: Contains ALL business logic for notification operations.
#          Routes call these functions. This keeps routes thin
#          and controllers fat — a clean architecture principle.
#
# FUNCTIONS IN THIS FILE:
#   get_user_notifications() → GET  /api/notifications
#   create_notification()    → POST /api/notifications
#   mark_as_read()           → PUT  /api/notifications/<notification_id>/read
# ============================================================

from flask import request, jsonify
from bson import ObjectId
from datetime import datetime

# ── Database and models ──────────────────────────────────────
from config.database import notifications_collection
from models.notification_model import create_notification_document

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
# 1. GET USER NOTIFICATIONS
#    URL: GET /api/notifications
# ─────────────────────────────────────────────────────────────
def get_user_notifications():
    """
    Fetches user's notifications with pagination.

    Query Parameters:
        page: int (default: 1)
        limit: int (default: 20)
        unread_only: bool (default: false)

    Returns:
        JSON with notifications list and pagination
    """
    try:
        user_id = request.user_id
        page, limit, skip = get_pagination_params(request.args)

        # Build filter
        query_filter = {"user_id": user_id}
        unread_only = request.args.get("unread_only", "false").lower() == "true"
        if unread_only:
            query_filter["is_read"] = False

        # Get notifications
        cursor = (
            notifications_collection
            .find(query_filter)
            .sort("created_at", -1)
            .skip(skip)
            .limit(limit)
        )

        notifications = serialize_list(list(cursor))
        total_count = notifications_collection.count_documents(query_filter)
        total_pages = (total_count + limit - 1) // limit

        return jsonify(success_response(
            data={
                "notifications": notifications,
                "pagination": {
                    "current_page": page,
                    "total_pages": total_pages,
                    "total_count": total_count,
                    "limit": limit,
                    "has_next": page < total_pages,
                    "has_prev": page > 1,
                }
            },
            message=f"Retrieved {len(notifications)} notification(s)"
        ))

    except Exception as e:
        return jsonify(error_response(
            message="Failed to fetch notifications",
            status_code=500,
            errors=[str(e)]
        ))


# ─────────────────────────────────────────────────────────────
# 2. CREATE NOTIFICATION
#    URL: POST /api/notifications
# ─────────────────────────────────────────────────────────────
def create_notification():
    """
    Creates a new notification for a user.

    Request Body:
        user_id: string (required)
        type: string (required)
        title: string (required)
        message: string (required)
        order_id: string (optional)

    Returns:
        JSON with created notification
    """
    try:
        data = request.get_json()

        # Validate required fields
        required_fields = ["user_id", "type", "title", "message"]
        validation_error = validate_required_fields(data, required_fields)
        if validation_error:
            return jsonify(validation_error[0]), validation_error[1]

        user_id = data["user_id"]
        type_ = data["type"]
        title = data["title"]
        message = data["message"]
        order_id = data.get("order_id")

        # Validate notification type
        valid_types = ["order_status", "payment", "delivery", "promotion", "system"]
        if type_ not in valid_types:
            return jsonify(error_response(
                message=f"Invalid notification type. Must be one of: {', '.join(valid_types)}",
                status_code=400
            ))

        # Create notification
        notification = create_notification_document(
            user_id=user_id,
            type=type_,
            title=title,
            message=message,
            order_id=order_id
        )

        result = notifications_collection.insert_one(notification)
        notification["_id"] = result.inserted_id

        notification_data = serialize_document(notification)
        return jsonify(success_response(
            data={"notification": notification_data},
            message="Notification created successfully"
        ))

    except Exception as e:
        return jsonify(error_response(
            message="Failed to create notification",
            status_code=500,
            errors=[str(e)]
        ))


# ─────────────────────────────────────────────────────────────
# 3. MARK NOTIFICATION AS READ
#    URL: PUT /api/notifications/<notification_id>/read
# ─────────────────────────────────────────────────────────────
def mark_as_read(notification_id: str):
    """
    Marks a notification as read.

    Args:
        notification_id: The notification ID

    Returns:
        JSON confirmation
    """
    try:
        user_id = request.user_id

        # Validate notification ID
        object_id, err = validate_object_id(notification_id)
        if err:
            return jsonify(err[0]), err[1]

        # Update notification
        result = notifications_collection.update_one(
            {
                "_id": object_id,
                "user_id": user_id  # Ensure user owns the notification
            },
            {
                "$set": {
                    "is_read": True,
                    "updated_at": datetime.utcnow()
                }
            }
        )

        if result.matched_count == 0:
            return jsonify(error_response(
                message="Notification not found",
                status_code=404
            ))

        return jsonify(success_response(
            data={"marked_read": True},
            message="Notification marked as read"
        ))

    except Exception as e:
        return jsonify(error_response(
            message="Failed to mark notification as read",
            status_code=500,
            errors=[str(e)]
        ))