"""
    Creates documents for the 'notifications' collection in MongoDB.

    Notification structure:
    - User notifications for orders, payments, deliveries
    - Push notifications, emails, SMS
"""

from datetime import datetime


def create_notification_document(
    user_id: str,
    type: str,
    title: str,
    message: str,
    order_id: str = None,
) -> dict:
    """
    Creates a notification document.

    Parameters:
        user_id   : User to notify
        type      : Notification type (order_status, payment, delivery)
        title     : Notification title
        message   : Notification message
        order_id  : Related order ID

    Returns:
        dict: MongoDB-ready notification document
    """
    return {
        "user_id": user_id,
        "type": type,
        "title": title,
        "message": message,
        "order_id": order_id,
        "is_read": False,
        "created_at": datetime.utcnow(),
    }