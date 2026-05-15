# ============================================================
# FILE: backend/services/payment_service.py
# PURPOSE: Handles payment gateway integrations and processing.
#          Contains functions for different payment methods.
# ============================================================

import time
import random


def process_payment_with_gateway(payment_data, method):
    """
    Processes payment through the appropriate gateway.

    Args:
        payment_data: Payment document dictionary
        method: Payment method (cash, card, jazzcash, easypaisa)

    Returns:
        dict: {
            "success": bool,
            "transaction_id": str,
            "message": str
        }
    """
    try:
        if method == "cash":
            return process_cash_payment(payment_data)
        elif method == "card":
            return process_card_payment(payment_data)
        elif method == "jazzcash":
            return process_jazzcash_payment(payment_data)
        elif method == "easypaisa":
            return process_easypaisa_payment(payment_data)
        else:
            return {
                "success": False,
                "message": f"Unsupported payment method: {method}"
            }

    except Exception as e:
        return {
            "success": False,
            "message": f"Payment processing error: {str(e)}"
        }


def process_cash_payment(payment_data):
    """
    Process cash payment (always succeeds for demo).

    Args:
        payment_data: Payment document

    Returns:
        dict: Gateway response
    """
    # Simulate processing time
    time.sleep(0.5)

    return {
        "success": True,
        "transaction_id": f"CASH_{payment_data['order_id']}_{int(time.time())}",
        "message": "Cash payment processed successfully"
    }


def process_card_payment(payment_data):
    """
    Process card payment with mock validation.

    Args:
        payment_data: Payment document

    Returns:
        dict: Gateway response
    """
    # Simulate processing time
    time.sleep(1)

    # Mock success/failure (90% success rate)
    success = random.random() < 0.9

    if success:
        return {
            "success": True,
            "transaction_id": f"CARD_{payment_data['order_id']}_{int(time.time())}",
            "message": "Card payment processed successfully"
        }
    else:
        return {
            "success": False,
            "message": "Card payment declined - insufficient funds"
        }


def process_jazzcash_payment(payment_data):
    """
    Process JazzCash payment.

    Args:
        payment_data: Payment document

    Returns:
        dict: Gateway response
    """
    # Simulate processing time
    time.sleep(1.5)

    # Mock success/failure (85% success rate)
    success = random.random() < 0.85

    if success:
        return {
            "success": True,
            "transaction_id": f"JAZZ_{payment_data['order_id']}_{int(time.time())}",
            "message": "JazzCash payment processed successfully"
        }
    else:
        return {
            "success": False,
            "message": "JazzCash payment failed - invalid credentials"
        }


def process_easypaisa_payment(payment_data):
    """
    Process Easypaisa payment.

    Args:
        payment_data: Payment document

    Returns:
        dict: Gateway response
    """
    # Simulate processing time
    time.sleep(1.2)

    # Mock success/failure (88% success rate)
    success = random.random() < 0.88

    if success:
        return {
            "success": True,
            "transaction_id": f"EASY_{payment_data['order_id']}_{int(time.time())}",
            "message": "Easypaisa payment processed successfully"
        }
    else:
        return {
            "success": False,
            "message": "Easypaisa payment failed - account not found"
        }


def refund_payment(transaction_id, amount):
    """
    Process refund for a payment.

    Args:
        transaction_id: Original transaction ID
        amount: Refund amount

    Returns:
        dict: Refund response
    """
    try:
        # Simulate processing time
        time.sleep(2)

        # Mock refund success
        success = random.random() < 0.95  # 95% success rate

        if success:
            return {
                "success": True,
                "refund_id": f"REF_{transaction_id}_{int(time.time())}",
                "message": f"Refund of {amount} processed successfully"
            }
        else:
            return {
                "success": False,
                "message": "Refund failed - transaction not eligible"
            }

    except Exception as e:
        return {
            "success": False,
            "message": f"Refund processing error: {str(e)}"
        }


def validate_payment_method(method):
    """
    Validates if a payment method is supported.

    Args:
        method: Payment method string

    Returns:
        bool: True if valid
    """
    valid_methods = ["cash", "card", "jazzcash", "easypaisa"]
    return method in valid_methods


def get_payment_method_fees(method):
    """
    Returns processing fees for different payment methods.

    Args:
        method: Payment method

    Returns:
        float: Processing fee percentage
    """
    fees = {
        "cash": 0.0,
        "card": 0.025,  # 2.5%
        "jazzcash": 0.015,  # 1.5%
        "easypaisa": 0.015  # 1.5%
    }

    return fees.get(method, 0.0)