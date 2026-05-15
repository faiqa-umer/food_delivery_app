"""
    Creates documents for the 'payments' collection in MongoDB.

    Payment structure:
    - Tracks payment transactions for orders
    - Supports multiple payment methods
    - Links to orders
"""

from datetime import datetime


def create_payment_document(
    order_id: str,
    user_id: str,
    amount: float,
    method: str,
    status: str = "pending",
    transaction_id: str = None,
) -> dict:
    """
    Creates a new payment document.

    Parameters:
        order_id       : Reference to orders collection
        user_id        : User making the payment
        amount         : Payment amount
        method         : Payment method (cash, card, jazzcash, easypaisa)
        status         : Payment status (pending, completed, failed, refunded)
        transaction_id : Gateway transaction ID

    Returns:
        dict: MongoDB-ready payment document
    """
    return {
        "order_id": order_id,
        "user_id": user_id,
        "amount": amount,
        "method": method,
        "status": status,
        "transaction_id": transaction_id,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
    }