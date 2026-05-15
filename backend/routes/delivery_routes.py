# ============================================================
# FILE: backend/routes/delivery_routes.py
# PURPOSE: Defines all delivery-related API endpoints.
#          Registers routes with Flask Blueprint.
# ============================================================

from flask import Blueprint
from controllers.delivery_controller import (
    get_delivery_status,
    update_delivery_status,
    update_location,
    rate_delivery
)
from middleware.auth_middleware import jwt_required

# Create blueprint for delivery routes
delivery_bp = Blueprint('delivery', __name__)

# ─────────────────────────────────────────────────────────────
# DELIVERY ROUTES
# ─────────────────────────────────────────────────────────────

# GET /api/deliveries/<order_id> - Get delivery status
@delivery_bp.route('/<order_id>', methods=['GET'])
@jwt_required
def get_delivery(order_id):
    return get_delivery_status(order_id)

# PUT /api/deliveries/<order_id> - Update delivery status
@delivery_bp.route('/<order_id>', methods=['PUT'])
@jwt_required
def update_delivery(order_id):
    return update_delivery_status(order_id)

# PUT /api/deliveries/<order_id>/location - Update location
@delivery_bp.route('/<order_id>/location', methods=['PUT'])
@jwt_required
def update_delivery_location(order_id):
    return update_location(order_id)

# POST /api/deliveries/<order_id>/rating - Rate delivery
@delivery_bp.route('/<order_id>/rating', methods=['POST'])
@jwt_required
def rate_delivery_service(order_id):
    return rate_delivery(order_id)