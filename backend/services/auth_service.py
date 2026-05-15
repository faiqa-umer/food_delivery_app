import jwt
import os
from datetime import datetime, timedelta
from typing import Tuple, Optional, Dict, Any
from werkzeug.security import generate_password_hash, check_password_hash
from bson import ObjectId
from config.database import db
from models.user_model import User
from utils.validators import Validator
from utils.response_handler import ResponseHandler
 
users_collection = db.users
SECRET_KEY = os.getenv("SECRET_KEY", "fallback_secret")
 
 
class AuthService:
    """Authentication service for handling user operations"""
 
    # ─── USER REGISTRATION ──────────────────────────────────────
    @staticmethod
    def register_user(
        name: str,
        email: str,
        password: str,
        phone: str,
    ) -> Tuple[bool, Dict[str, Any], int]:
        """
        Register a new user
        
        Args:
            name: User's full name
            email: User's email address
            password: User's password (will be hashed)
            phone: User's phone number
            
        Returns:
            Tuple of (success: bool, response_data: dict, status_code: int)
        """
        try:
            # Validate all fields
            is_valid, errors = Validator.validate_registration({
                "name": name,
                "email": email,
                "password": password,
                "phone": phone,
            })
            
            if not is_valid:
                response = {
                    "status": "error",
                    "message": "Validation failed",
                    "errors": errors,
                }
                return False, response, 400
            
            # Check if user already exists
            existing_user = users_collection.find_one({"email": email.lower()})
            if existing_user:
                response = {
                    "status": "error",
                    "message": "Email already registered. Please login or use a different email.",
                    "error_code": "EMAIL_EXISTS",
                }
                return False, response, 409
            
            # Hash password
            hashed_password = generate_password_hash(password)
            
            # Create new user
            new_user = {
                "name": name.strip(),
                "email": email.lower().strip(),
                "password": hashed_password,
                "phone": phone.strip(),
                "role": "customer",
                "is_active": True,
                "total_orders": 0,
                "address": None,
                "city": None,
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow(),
            }
            
            result = users_collection.insert_one(new_user)
            user_id = str(result.inserted_id)
            
            response = {
                "status": "success",
                "message": "Registered successfully",
                "user_id": user_id,
                "user": {
                    "user_id": user_id,
                    "name": name,
                    "email": email.lower(),
                    "phone": phone,
                    "role": "customer",
                }
            }
            
            return True, response, 201
            
        except Exception as e:
            response = {
                "status": "error",
                "message": f"Registration failed: {str(e)}",
            }
            return False, response, 500
 
    # ─── USER LOGIN ─────────────────────────────────────────────
    @staticmethod
    def login_user(email: str, password: str) -> Tuple[bool, Dict[str, Any], int]:
        """
        Login user and return JWT token
        
        Args:
            email: User's email
            password: User's password
            
        Returns:
            Tuple of (success: bool, response_data: dict, status_code: int)
        """
        try:
            # Validate input
            is_valid, errors = Validator.validate_login({
                "email": email,
                "password": password,
            })
            
            if not is_valid:
                response = {
                    "status": "error",
                    "message": "Validation failed",
                    "errors": errors,
                }
                return False, response, 400
            
            # Find user by email
            user_doc = users_collection.find_one({"email": email.lower()})
            
            if not user_doc:
                response = {
                    "status": "error",
                    "message": "Invalid email or password",
                }
                return False, response, 401
            
            # Check if user is active
            if not user_doc.get("is_active", True):
                response = {
                    "status": "error",
                    "message": "Account is inactive. Please contact support.",
                }
                return False, response, 401
            
            # Verify password
            if not check_password_hash(user_doc["password"], password):
                response = {
                    "status": "error",
                    "message": "Invalid email or password",
                }
                return False, response, 401
            
            # Generate JWT token
            token = AuthService.generate_token(
                user_id=str(user_doc["_id"]),
                email=user_doc["email"],
                name=user_doc.get("name", ""),
                role=user_doc.get("role", "customer"),
            )
            
            response = {
                "status": "success",
                "message": "Login successful",
                "token": token,
                "user": {
                    "user_id": str(user_doc["_id"]),
                    "name": user_doc.get("name", ""),
                    "email": user_doc.get("email", ""),
                    "phone": user_doc.get("phone", ""),
                    "role": user_doc.get("role", "customer"),
                }
            }
            
            return True, response, 200
            
        except Exception as e:
            response = {
                "status": "error",
                "message": f"Login failed: {str(e)}",
            }
            return False, response, 500
 
    # ─── GET USER PROFILE ───────────────────────────────────────
    @staticmethod
    def get_user_profile(user_id: str) -> Tuple[bool, Dict[str, Any], int]:
        """
        Get user profile information
        
        Args:
            user_id: User's ID
            
        Returns:
            Tuple of (success: bool, response_data: dict, status_code: int)
        """
        try:
            # Validate user_id
            is_valid, error = Validator.validate_uuid(user_id)
            if not is_valid:
                response = {
                    "status": "error",
                    "message": error,
                }
                return False, response, 400
            
            # Find user
            user_doc = users_collection.find_one({"_id": ObjectId(user_id)})
            
            if not user_doc:
                response = {
                    "status": "error",
                    "message": "User not found",
                }
                return False, response, 404
            
            response = {
                "status": "success",
                "user": {
                    "user_id": str(user_doc["_id"]),
                    "name": user_doc.get("name", ""),
                    "email": user_doc.get("email", ""),
                    "phone": user_doc.get("phone", ""),
                    "role": user_doc.get("role", "customer"),
                    "address": user_doc.get("address"),
                    "city": user_doc.get("city"),
                    "is_active": user_doc.get("is_active", True),
                    "total_orders": user_doc.get("total_orders", 0),
                    "created_at": user_doc.get("created_at").isoformat() if user_doc.get("created_at") else None,
                    "updated_at": user_doc.get("updated_at").isoformat() if user_doc.get("updated_at") else None,
                }
            }
            
            return True, response, 200
            
        except Exception as e:
            response = {
                "status": "error",
                "message": f"Failed to fetch profile: {str(e)}",
            }
            return False, response, 500
 
    # ─── UPDATE USER PROFILE ────────────────────────────────────
    @staticmethod
    def update_user_profile(user_id: str, **kwargs) -> Tuple[bool, Dict[str, Any], int]:
        """
        Update user profile information
        
        Args:
            user_id: User's ID
            **kwargs: Fields to update (name, phone, address, city)
            
        Returns:
            Tuple of (success: bool, response_data: dict, status_code: int)
        """
        try:
            # Validate user_id
            is_valid, error = Validator.validate_uuid(user_id)
            if not is_valid:
                response = {
                    "status": "error",
                    "message": error,
                }
                return False, response, 400
            
            # Validate update data
            is_valid, errors = Validator.validate_profile_update(kwargs)
            if not is_valid:
                response = {
                    "status": "error",
                    "message": "Validation failed",
                    "errors": errors,
                }
                return False, response, 400
            
            # Prepare update data
            update_data = {"updated_at": datetime.utcnow()}
            
            for key in ["name", "phone", "address", "city"]:
                if key in kwargs and kwargs[key]:
                    update_data[key] = kwargs[key].strip() if isinstance(kwargs[key], str) else kwargs[key]
            
            # Update user
            result = users_collection.update_one(
                {"_id": ObjectId(user_id)},
                {"$set": update_data}
            )
            
            if result.matched_count == 0:
                response = {
                    "status": "error",
                    "message": "User not found",
                }
                return False, response, 404
            
            # Fetch updated user
            updated_user = users_collection.find_one({"_id": ObjectId(user_id)})
            
            response = {
                "status": "success",
                "message": "Profile updated successfully",
                "user": {
                    "user_id": str(updated_user["_id"]),
                    "name": updated_user.get("name", ""),
                    "email": updated_user.get("email", ""),
                    "phone": updated_user.get("phone", ""),
                    "role": updated_user.get("role", "customer"),
                    "address": updated_user.get("address"),
                    "city": updated_user.get("city"),
                    "is_active": updated_user.get("is_active", True),
                    "total_orders": updated_user.get("total_orders", 0),
                }
            }
            
            return True, response, 200
            
        except Exception as e:
            response = {
                "status": "error",
                "message": f"Failed to update profile: {str(e)}",
            }
            return False, response, 500
 
    # ─── JWT TOKEN OPERATIONS ───────────────────────────────────
    @staticmethod
    def generate_token(
        user_id: str,
        email: str,
        name: str = "",
        role: str = "customer",
        expires_in_days: int = 7,
    ) -> str:
        """
        Generate JWT token
        
        Args:
            user_id: User's ID
            email: User's email
            name: User's name
            role: User's role
            expires_in_days: Token expiration in days
            
        Returns:
            JWT token string
        """
        payload = {
            "user_id": user_id,
            "email": email,
            "name": name,
            "role": role,
            "iat": datetime.utcnow(),
            "exp": datetime.utcnow() + timedelta(days=expires_in_days),
        }
        
        token = jwt.encode(payload, SECRET_KEY, algorithm="HS256")
        return token
 
    @staticmethod
    def verify_token(token: str) -> Tuple[bool, Optional[Dict[str, Any]], Optional[str]]:
        """
        Verify JWT token
        
        Args:
            token: JWT token to verify
            
        Returns:
            Tuple of (is_valid: bool, payload: dict or None, error_message: str or None)
        """
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            return True, payload, None
        except jwt.ExpiredSignatureError:
            return False, None, "Token has expired"
        except jwt.InvalidTokenError:
            return False, None, "Invalid token"
        except Exception as e:
            return False, None, str(e)
 
    @staticmethod
    def decode_token(token: str) -> Tuple[bool, Optional[Dict[str, Any]]]:
        """
        Decode JWT token without verification
        
        Args:
            token: JWT token to decode
            
        Returns:
            Tuple of (success: bool, payload: dict or None)
        """
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            return True, payload
        except Exception:
            return False, None
 
    # ─── LOGOUT ─────────────────────────────────────────────────
    @staticmethod
    def logout_user(user_id: str) -> Tuple[bool, Dict[str, Any], int]:
        """
        Logout user (currently just returns success, token removal is client-side)
        
        Args:
            user_id: User's ID
            
        Returns:
            Tuple of (success: bool, response_data: dict, status_code: int)
        """
        try:
            response = {
                "status": "success",
                "message": "Logout successful",
            }
            return True, response, 200
        except Exception as e:
            response = {
                "status": "error",
                "message": f"Logout failed: {str(e)}",
            }
            return False, response, 500