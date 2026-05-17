# ============================================================
# FILE: controllers/auth_controller.py
# PURPOSE: Handles user registration, login, profile retrieval, logout
# ============================================================

from flask import request, jsonify
from middleware.auth_middleware import token_required
from services.auth_service import AuthService
from utils.response_handler import ResponseHandler


class AuthController:
    """Authentication controller"""

    @staticmethod
    def register():
        """Register a new user"""
        try:
            data = request.get_json()
            
            if not data:
                return ResponseHandler.bad_request("Request body is empty")
            
            # Extract fields
            name = data.get("name", "").strip()
            email = data.get("email", "").strip()
            password = data.get("password", "")
            phone = data.get("phone", "").strip()
            
            # Use service to register
            success, response_data, status_code = AuthService.register_user(
                name=name,
                email=email,
                password=password,
                phone=phone,
            )
            
            return jsonify(response_data), status_code
            
        except Exception as e:
            return ResponseHandler.internal_error(f"Registration error: {str(e)}")

    @staticmethod
    def login():
        """Login user and return JWT token"""
        try:
            data = request.get_json()
            
            if not data:
                return ResponseHandler.bad_request("Request body is empty")
            
            email = data.get("email", "").strip()
            password = data.get("password", "")
            
            # Use service to login
            success, response_data, status_code = AuthService.login_user(
                email=email,
                password=password,
            )
            
            return jsonify(response_data), status_code
            
        except Exception as e:
            return ResponseHandler.internal_error(f"Login error: {str(e)}")

    @staticmethod
    @token_required
    def get_profile(current_user):
        """Get current user's profile"""
        try:
            user_id = current_user.get("user_id")
            
            success, response_data, status_code = AuthService.get_user_profile(user_id)
            
            return jsonify(response_data), status_code
            
        except Exception as e:
            return ResponseHandler.internal_error(f"Profile fetch error: {str(e)}")

    @staticmethod
    @token_required
    def update_profile(current_user):
        """Update user profile"""
        try:
            user_id = current_user.get("user_id")
            data = request.get_json()
            
            if not data:
                return ResponseHandler.bad_request("Request body is empty")
            
            # Use service to update
            success, response_data, status_code = AuthService.update_user_profile(
                user_id=user_id,
                **data
            )
            
            return jsonify(response_data), status_code
            
        except Exception as e:
            return ResponseHandler.internal_error(f"Profile update error: {str(e)}")

    @staticmethod
    @token_required
    def logout(current_user):
        """Logout user"""
        try:
            user_id = current_user.get("user_id")
            
            success, response_data, status_code = AuthService.logout_user(user_id)
            
            return jsonify(response_data), status_code
            
        except Exception as e:
            return ResponseHandler.internal_error(f"Logout error: {str(e)}")