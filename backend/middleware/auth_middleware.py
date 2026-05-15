# ============================================================
# FILE: middleware/auth_middleware.py
# PURPOSE: JWT token validation and user authentication
# ============================================================

from functools import wraps
from flask import request, jsonify
import jwt
import os
import inspect

SECRET_KEY = os.getenv("SECRET_KEY", "fallback_secret")

def token_required(f):
    """
    Decorator to check if a valid JWT token is provided in the Authorization header.
    Decodes the token, attaches the user payload to the request, and then
    calls the wrapped route function in a compatible way.
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

            # Attach the user_id to the request for controllers that use request.user_id
            request.user_id = decoded.get("user_id")
            request.current_user = decoded

            # If the wrapped route expects a current_user parameter, pass it.
            parameters = list(inspect.signature(f).parameters.values())
            if parameters and parameters[0].name in (
                "current_user",
                "user",
                "decoded",
                "current_user_payload",
            ):
                return f(decoded, *args, **kwargs)

            return f(*args, **kwargs)

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
