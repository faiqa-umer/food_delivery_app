# ============================================================
# FILE: backend/services/notification_service.py
# PURPOSE: Handles sending notifications via different channels.
#          Supports email, SMS, push notifications.
# ============================================================

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os
from datetime import datetime


def send_notification(user_email, notification_data):
    """
    Sends notification to user via available channels.

    Args:
        user_email: User's email address
        notification_data: Notification document

    Returns:
        dict: {
            "success": bool,
            "channels": list of sent channels,
            "errors": list of errors
        }
    """
    channels = []
    errors = []

    # Send email notification
    email_result = send_email_notification(user_email, notification_data)
    if email_result["success"]:
        channels.append("email")
    else:
        errors.append(f"Email: {email_result['error']}")

    # Send SMS notification (mock for now)
    sms_result = send_sms_notification(user_email, notification_data)
    if sms_result["success"]:
        channels.append("sms")
    else:
        errors.append(f"SMS: {sms_result['error']}")

    # Send push notification (mock for now)
    push_result = send_push_notification(notification_data)
    if push_result["success"]:
        channels.append("push")
    else:
        errors.append(f"Push: {push_result['error']}")

    return {
        "success": len(channels) > 0,
        "channels": channels,
        "errors": errors
    }


def send_email_notification(user_email, notification_data):
    """
    Sends notification via email.

    Args:
        user_email: Recipient email
        notification_data: Notification details

    Returns:
        dict: {"success": bool, "error": str}
    """
    try:
        # Email configuration from environment
        smtp_server = os.getenv("SMTP_SERVER", "smtp.gmail.com")
        smtp_port = int(os.getenv("SMTP_PORT", "587"))
        smtp_username = os.getenv("SMTP_USERNAME")
        smtp_password = os.getenv("SMTP_PASSWORD")
        from_email = os.getenv("FROM_EMAIL", smtp_username)

        if not smtp_username or not smtp_password:
            return {
                "success": False,
                "error": "Email configuration not found"
            }

        # Create message
        msg = MIMEMultipart()
        msg['From'] = from_email
        msg['To'] = user_email
        msg['Subject'] = notification_data['title']

        # Email body
        body = f"""
        {notification_data['message']}

        Order ID: {notification_data.get('order_id', 'N/A')}
        Time: {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}

        Thank you for using Food Delivery App!
        """

        msg.attach(MIMEText(body, 'plain'))

        # Send email
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()
        server.login(smtp_username, smtp_password)
        text = msg.as_string()
        server.sendmail(from_email, user_email, text)
        server.quit()

        return {"success": True}

    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }


def send_sms_notification(user_phone, notification_data):
    """
    Sends notification via SMS (mock implementation).

    Args:
        user_phone: User's phone number
        notification_data: Notification details

    Returns:
        dict: {"success": bool, "error": str}
    """
    try:
        # Mock SMS sending - in real app, integrate with Twilio, etc.
        print(f"SMS to {user_phone}: {notification_data['title']} - {notification_data['message']}")

        # Simulate 95% success rate
        import random
        success = random.random() < 0.95

        if success:
            return {"success": True}
        else:
            return {
                "success": False,
                "error": "SMS delivery failed"
            }

    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }


def send_push_notification(notification_data):
    """
    Sends push notification (mock implementation).

    Args:
        notification_data: Notification details

    Returns:
        dict: {"success": bool, "error": str}
    """
    try:
        # Mock push notification - in real app, integrate with FCM, etc.
        print(f"Push notification: {notification_data['title']} - {notification_data['message']}")

        # Simulate 98% success rate
        import random
        success = random.random() < 0.98

        if success:
            return {"success": True}
        else:
            return {
                "success": False,
                "error": "Push notification failed"
            }

    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }


def create_order_status_notification(order_id, user_id, user_email, status):
    """
    Creates and sends notification for order status change.

    Args:
        order_id: Order ID
        user_id: User ID
        user_email: User email
        status: New order status

    Returns:
        dict: Notification creation result
    """
    status_messages = {
        "confirmed": "Your order has been confirmed and is being prepared.",
        "preparing": "Your order is being prepared.",
        "ready": "Your order is ready for pickup.",
        "out_for_delivery": "Your order is out for delivery.",
        "delivered": "Your order has been delivered successfully.",
        "cancelled": "Your order has been cancelled."
    }

    title = f"Order {status.title()}"
    message = status_messages.get(status, f"Your order status has been updated to {status}.")

    notification_data = {
        "user_id": user_id,
        "type": "order_status",
        "title": title,
        "message": message,
        "order_id": order_id
    }

    return send_notification(user_email, notification_data)


def create_payment_notification(order_id, user_id, user_email, status, amount):
    """
    Creates and sends notification for payment status.

    Args:
        order_id: Order ID
        user_id: User ID
        user_email: User email
        status: Payment status
        amount: Payment amount

    Returns:
        dict: Notification creation result
    """
    if status == "completed":
        title = "Payment Successful"
        message = f"Your payment of Rs. {amount} has been processed successfully."
    elif status == "failed":
        title = "Payment Failed"
        message = f"Your payment of Rs. {amount} could not be processed. Please try again."
    else:
        title = "Payment Update"
        message = f"Your payment status has been updated to {status}."

    notification_data = {
        "user_id": user_id,
        "type": "payment",
        "title": title,
        "message": message,
        "order_id": order_id
    }

    return send_notification(user_email, notification_data)


def create_delivery_notification(order_id, user_id, user_email, status):
    """
    Creates and sends notification for delivery status.

    Args:
        order_id: Order ID
        user_id: User ID
        user_email: User email
        status: Delivery status

    Returns:
        dict: Notification creation result
    """
    status_messages = {
        "assigned": "A delivery rider has been assigned to your order.",
        "picked_up": "Your order has been picked up and is on the way.",
        "out_for_delivery": "Your order is out for delivery.",
        "delivered": "Your order has been delivered successfully."
    }

    title = "Delivery Update"
    message = status_messages.get(status, f"Your delivery status has been updated to {status}.")

    notification_data = {
        "user_id": user_id,
        "type": "delivery",
        "title": title,
        "message": message,
        "order_id": order_id
    }

    return send_notification(user_email, notification_data)