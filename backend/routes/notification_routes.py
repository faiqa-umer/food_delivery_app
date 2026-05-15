# ============================================================
# FILE: backend/routes/notification_routes.py
# PURPOSE: Defines all notification-related API endpoints.
#          Registers routes with Flask Blueprint.
# ============================================================

from flask import Blueprint
from controllers.notification_controller import (
    get_user_notifications,
    create_notification,
    mark_as_read
)
from middleware.auth_middleware import jwt_required

# Create blueprint for notification routes
notification_bp = Blueprint('notification', __name__)

# ─────────────────────────────────────────────────────────────
# NOTIFICATION ROUTES
# ─────────────────────────────────────────────────────────────

# GET /api/notifications and /api/notifications/ - Get user's notifications
@notification_bp.route('', methods=['GET'])
@notification_bp.route('/', methods=['GET'])
@jwt_required
def get_notifications():
    return get_user_notifications()

# POST /api/notifications/ - Create notification
@notification_bp.route('/', methods=['POST'])
@jwt_required
def create_new_notification():
    return create_notification()

# PUT /api/notifications/<notification_id>/read - Mark as read
@notification_bp.route('/<notification_id>/read', methods=['PUT'])
@jwt_required
def mark_notification_read(notification_id):
    return mark_as_read(notification_id)