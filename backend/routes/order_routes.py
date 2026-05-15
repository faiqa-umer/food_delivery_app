# ============================================================
# FILE: backend/routes/order_routes.py
# PURPOSE: Defines all order-related API endpoints.
#          Registers routes with Flask Blueprint.
# ============================================================

from flask import Blueprint
from controllers.order_controller import (
    create_order,
    get_user_orders,
    get_order_by_id,
    update_order_status,
    get_order_items
)
from middleware.auth_middleware import jwt_required

# Create blueprint for order routes
orders_bp = Blueprint('orders', __name__)

# ─────────────────────────────────────────────────────────────
# ORDER ROUTES
# ─────────────────────────────────────────────────────────────

# POST /api/orders/ - Create order from cart
@orders_bp.route('/', methods=['POST'])
@jwt_required
def create_new_order():
    return create_order()

# GET /api/orders and /api/orders/ - Get user's order history
@orders_bp.route('', methods=['GET'])
@orders_bp.route('/', methods=['GET'])
@jwt_required
def get_orders():
    return get_user_orders()

# GET /api/orders/<order_id> - Get order details
@orders_bp.route('/<order_id>', methods=['GET'])
@jwt_required
def get_order(order_id):
    return get_order_by_id(order_id)

# PUT /api/orders/<order_id> - Update order status
@orders_bp.route('/<order_id>', methods=['PUT'])
@jwt_required
def update_order(order_id):
    return update_order_status(order_id)

# GET /api/orders/<order_id>/items - Get order items
@orders_bp.route('/<order_id>/items', methods=['GET'])
@jwt_required
def get_items(order_id):
    return get_order_items(order_id)