# ============================================================
# FILE: backend/routes/payment_routes.py
# PURPOSE: Defines all payment-related API endpoints.
#          Registers routes with Flask Blueprint.
# ============================================================

from flask import Blueprint
from controllers.payment_controller import (
    process_payment,
    get_payment_status,
    update_payment,
    get_order_payment
)
from middleware.auth_middleware import jwt_required

# Create blueprint for payment routes
payment_bp = Blueprint('payment', __name__)

# ─────────────────────────────────────────────────────────────
# PAYMENT ROUTES
# ─────────────────────────────────────────────────────────────

# POST /api/payments - Process payment
@payment_bp.route('/', methods=['POST'])
@jwt_required
def process_new_payment():
    return process_payment()

# GET /api/payments/<payment_id> - Get payment status
@payment_bp.route('/<payment_id>', methods=['GET'])
@jwt_required
def get_payment(payment_id):
    return get_payment_status(payment_id)

# PUT /api/payments/<payment_id> - Update payment (webhook)
@payment_bp.route('/<payment_id>', methods=['PUT'])
@jwt_required
def update_payment_status(payment_id):
    return update_payment(payment_id)

# GET /api/payments/orders/<order_id> - Get payment for order
@payment_bp.route('/orders/<order_id>', methods=['GET'])
@jwt_required
def get_payment_for_order(order_id):
    return get_order_payment(order_id)