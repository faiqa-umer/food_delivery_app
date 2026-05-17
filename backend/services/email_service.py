# ============================================================
# FILE: backend/services/email_service.py
# PURPOSE: Email sending functionality (for future use)
# ============================================================

import smtplib
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import Tuple, List, Optional
from config.settings import Config


class EmailService:
    """Email service for sending emails"""
    
    SMTP_SERVER = Config.SMTP_SERVER
    SMTP_PORT = Config.SMTP_PORT
    SENDER_EMAIL = Config.SMTP_USERNAME
    SENDER_PASSWORD = Config.SMTP_PASSWORD
    FROM_ADDRESS = Config.MAIL_FROM
    
    # Email templates
    TEMPLATES = {
        "welcome": {
            "subject": "Welcome to Food Delivery!",
            "body": """
                <html>
                    <body>
                        <h2>Welcome to Food Delivery!</h2>
                        <p>Hi {name},</p>
                        <p>Thank you for registering with us. Your account has been created successfully.</p>
                        <p>You can now login and start ordering from your favorite restaurants.</p>
                        <p>Best regards,<br>Food Delivery Team</p>
                    </body>
                </html>
            """
        },
        "reset_password": {
            "subject": "Password Reset Request",
            "body": """
                <html>
                    <body>
                        <h2>Password Reset Request</h2>
                        <p>Hi {name},</p>
                        <p>We received a request to reset your password. Click the link below to reset it:</p>
                        <a href="{reset_link}">Reset Password</a>
                        <p>If you didn't request this, please ignore this email.</p>
                        <p>Best regards,<br>Food Delivery Team</p>
                    </body>
                </html>
            """
        },
        "order_confirmation": {
            "subject": "Order Confirmation",
            "body": """
                <html>
                    <body>
                        <h2>Order Confirmed!</h2>
                        <p>Hi {name},</p>
                        <p>Your order #{order_id} has been confirmed.</p>
                        <p>Order Total: {amount}</p>
                        <p>Estimated delivery time: {delivery_time}</p>
                        <p>You'll receive updates as your order progresses.</p>
                        <p>Best regards,<br>Food Delivery Team</p>
                    </body>
                </html>
            """
        },
        "order_delivered": {
            "subject": "Order Delivered",
            "body": """
                <html>
                    <body>
                        <h2>Your Order Has Been Delivered!</h2>
                        <p>Hi {name},</p>
                        <p>Your order #{order_id} has been successfully delivered.</p>
                        <p>Thank you for your order. We hope you enjoy your meal!</p>
                        <p>Please rate your experience to help us improve.</p>
                        <p>Best regards,<br>Food Delivery Team</p>
                    </body>
                </html>
            """
        }
    }

    @classmethod
    def send_email(
        cls,
        to_email: str,
        subject: str,
        body: str,
        is_html: bool = True,
    ) -> Tuple[bool, str]:
        """
        Send email to recipient
        
        Args:
            to_email: Recipient email address
            subject: Email subject
            body: Email body content
            is_html: Whether body is HTML
            
        Returns:
            Tuple of (success: bool, message: str)
        """
        try:
            # Skip if SMTP credentials not configured
            if not cls.SENDER_EMAIL or not cls.SENDER_PASSWORD:
                return False, "Email service not configured"
            
            # Create message
            message = MIMEMultipart("alternative")
            message["Subject"] = subject
            message["From"] = cls.FROM_ADDRESS
            message["To"] = to_email
            
            # Attach body
            mime_type = "html" if is_html else "plain"
            message.attach(MIMEText(body, mime_type))
            
            # Send email
            with smtplib.SMTP(cls.SMTP_SERVER, cls.SMTP_PORT) as server:
                server.starttls()
                server.login(cls.SENDER_EMAIL, cls.SENDER_PASSWORD)
                server.sendmail(cls.FROM_ADDRESS, to_email, message.as_string())
            
            return True, "Email sent successfully"
            
        except smtplib.SMTPAuthenticationError:
            return False, "SMTP authentication failed"
        except smtplib.SMTPException as e:
            return False, f"SMTP error: {str(e)}"
        except Exception as e:
            return False, f"Failed to send email: {str(e)}"

    @classmethod
    def send_welcome_email(cls, email: str, name: str) -> Tuple[bool, str]:
        """
        Send welcome email to new user
        
        Args:
            email: User email
            name: User name
            
        Returns:
            Tuple of (success: bool, message: str)
        """
        template = cls.TEMPLATES["welcome"]
        body = template["body"].format(name=name)
        return cls.send_email(email, template["subject"], body)

    @classmethod
    def send_password_reset_email(
        cls,
        email: str,
        name: str,
        reset_link: str,
    ) -> Tuple[bool, str]:
        """
        Send password reset email
        
        Args:
            email: User email
            name: User name
            reset_link: Password reset link
            
        Returns:
            Tuple of (success: bool, message: str)
        """
        template = cls.TEMPLATES["reset_password"]
        body = template["body"].format(name=name, reset_link=reset_link)
        return cls.send_email(email, template["subject"], body)

    @classmethod
    def send_order_confirmation_email(
        cls,
        email: str,
        name: str,
        order_id: str,
        amount: str,
        delivery_time: str,
    ) -> Tuple[bool, str]:
        """
        Send order confirmation email
        
        Args:
            email: User email
            name: User name
            order_id: Order ID
            amount: Order amount
            delivery_time: Estimated delivery time
            
        Returns:
            Tuple of (success: bool, message: str)
        """
        template = cls.TEMPLATES["order_confirmation"]
        body = template["body"].format(
            name=name,
            order_id=order_id,
            amount=amount,
            delivery_time=delivery_time,
        )
        return cls.send_email(email, template["subject"], body)

    @classmethod
    def send_order_delivered_email(
        cls,
        email: str,
        name: str,
        order_id: str,
    ) -> Tuple[bool, str]:
        """
        Send order delivered email
        
        Args:
            email: User email
            name: User name
            order_id: Order ID
            
        Returns:
            Tuple of (success: bool, message: str)
        """
        template = cls.TEMPLATES["order_delivered"]
        body = template["body"].format(
            name=name,
            order_id=order_id,
        )
        return cls.send_email(email, template["subject"], body)

    @classmethod
    def send_bulk_email(
        cls,
        recipients: List[str],
        subject: str,
        body: str,
        is_html: bool = True,
    ) -> Tuple[int, int]:
        """
        Send email to multiple recipients
        
        Args:
            recipients: List of recipient email addresses
            subject: Email subject
            body: Email body
            is_html: Whether body is HTML
            
        Returns:
            Tuple of (sent_count, failed_count)
        """
        sent_count = 0
        failed_count = 0
        
        for email in recipients:
            success, _ = cls.send_email(email, subject, body, is_html)
            if success:
                sent_count += 1
            else:
                failed_count += 1
        
        return sent_count, failed_count