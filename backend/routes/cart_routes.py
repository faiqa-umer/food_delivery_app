# ============================================================
# FILE: backend/routes/cart_routes.py
# PURPOSE: Defines all cart-related API endpoints.
#          Registers routes with Flask Blueprint.
# ============================================================

from flask import Blueprint
from controllers.cart_controller import (
    get_user_cart,
    add_to_cart,
    update_cart_item,
    remove_from_cart,
    clear_cart
)
from middleware.auth_middleware import jwt_required

# Create blueprint for cart routes
cart_bp = Blueprint('cart', __name__)

# ─────────────────────────────────────────────────────────────
# CART ROUTES
# ─────────────────────────────────────────────────────────────

# GET /api/cart and /api/cart/ - Get user's cart
@cart_bp.route('', methods=['GET'])
@cart_bp.route('/', methods=['GET'])
@jwt_required
def get_cart():
    return get_user_cart()

# POST /api/cart/ - Add item to cart
@cart_bp.route('/', methods=['POST'])
@jwt_required
def add_item():
    return add_to_cart()

# PUT /api/cart/<item_id> - Update cart item
@cart_bp.route('/<item_id>', methods=['PUT'])
@jwt_required
def update_item(item_id):
    return update_cart_item(item_id)

# DELETE /api/cart/<item_id> - Remove item from cart
@cart_bp.route('/<item_id>', methods=['DELETE'])
@jwt_required
def remove_item(item_id):
    return remove_from_cart(item_id)

# DELETE /api/cart/ - Clear entire cart
@cart_bp.route('/', methods=['DELETE'])
@jwt_required
def clear_entire_cart():
    return clear_cart()