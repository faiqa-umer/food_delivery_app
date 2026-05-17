# ============================================================
# FILE: middleware/auth_middleware.py
# PURPOSE: JWT token validation and user authentication
# ============================================================

from functools import wraps
from flask import request, jsonify
import jwt
import os

SECRET_KEY = os.getenv("SECRET_KEY", "fallback_secret")

def token_required(f):
    """
    Decorator to check if a valid JWT token is provided in the Authorization header.
    Extracts and validates the token, passing the decoded payload to the route handler.
    """
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get("Authorization")

        # Check if token exists
        if not token:
            return jsonify({
                "status": "error",
                "message": "Token is missing"
            }), 401

        try:
            # Remove "Bearer " prefix if present
            # Authorization header format: "Bearer <token>"
            if token.startswith("Bearer "):
                token = token[7:]

            # Decode the JWT token
            decoded = jwt.decode(
                token,
                SECRET_KEY,
                algorithms=["HS256"]
            )

            # Pass decoded token to route handler
            # The route handler receives it as the current_user parameter
            return f(decoded, *args, **kwargs)

        except jwt.ExpiredSignatureError:
            return jsonify({
                "status": "error",
                "message": "Token has expired"
            }), 401

        except jwt.InvalidTokenError:
            return jsonify({
                "status": "error",
                "message": "Invalid token"
            }), 401

        except Exception as e:
            return jsonify({
                "status": "error",
                "message": f"Authentication failed: {str(e)}"
            }), 401

    return decorated


def jwt_required(f):
    """Alias for token_required decorator"""
    return token_required(f)
