# ============================================================
# FILE: backend/config/jwt_config.py
# PURPOSE: JWT token configuration and constants
# ============================================================

import os
from datetime import timedelta
from typing import Dict, Any

class JWTConfig:
    """JWT Configuration"""
    
    # Secret key for JWT signing
    SECRET_KEY = os.getenv("SECRET_KEY", "fallback_secret_change_in_production")
    
    # JWT Algorithm
    ALGORITHM = "HS256"
    
    # Token expiration times
    ACCESS_TOKEN_EXPIRE_DAYS = int(os.getenv("ACCESS_TOKEN_EXPIRE_DAYS", 7))
    REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", 30))
    
    # Access token expiration
    ACCESS_TOKEN_EXPIRE_TIMEDELTA = timedelta(days=ACCESS_TOKEN_EXPIRE_DAYS)
    
    # Refresh token expiration
    REFRESH_TOKEN_EXPIRE_TIMEDELTA = timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    
    # Token claims
    REQUIRED_CLAIMS = ["user_id", "email", "exp", "iat"]
    OPTIONAL_CLAIMS = ["name", "role", "phone"]
    
    # Token types
    TOKEN_TYPE_ACCESS = "access"
    TOKEN_TYPE_REFRESH = "refresh"
    
    @staticmethod
    def get_token_payload_template(user_id: str, email: str, name: str = "", role: str = "customer") -> Dict[str, Any]:
        """
        Get template for JWT token payload
        
        Args:
            user_id: User ID
            email: User email
            name: User name (optional)
            role: User role
            
        Returns:
            Dictionary with token payload
        """
        return {
            "user_id": user_id,
            "email": email,
            "name": name,
            "role": role,
        }
    
    @staticmethod
    def validate_required_claims(payload: Dict[str, Any]) -> bool:
        """
        Validate that all required claims are present in token payload
        
        Args:
            payload: Token payload
            
        Returns:
            True if all required claims present, False otherwise
        """
        return all(claim in payload for claim in JWTConfig.REQUIRED_CLAIMS)