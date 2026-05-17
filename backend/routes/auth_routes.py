# ============================================================
# FILE: backend/routes/auth_routes.py
# PURPOSE: Authentication routes (login, register, logout)
# ============================================================

from flask import Blueprint, request, jsonify
from controllers.auth_controller import AuthController
from middleware.auth_middleware import token_required

auth_bp = Blueprint('auth', __name__)


@auth_bp.route('/register', methods=['POST'])
def register():
    """
    Register endpoint
    POST /api/auth/register
    
    Request body:
    {
        "name": "John Doe",
        "email": "john@example.com",
        "password": "SecurePass123",
        "phone": "03001234567"
    }
    
    Response:
    {
        "status": "success",
        "message": "Registered successfully",
        "user_id": "...",
        "user": {...}
    }
    """
    return AuthController.register()


@auth_bp.route('/login', methods=['POST'])
def login():
    """
    Login endpoint
    POST /api/auth/login
    
    Request body:
    {
        "email": "john@example.com",
        "password": "SecurePass123"
    }
    
    Response:
    {
        "status": "success",
        "message": "Login successful",
        "token": "jwt_token",
        "user": {...}
    }
    """
    return AuthController.login()


@auth_bp.route('/profile', methods=['GET'])
@token_required
def get_profile(current_user):
    """
    Get user profile
    GET /api/auth/profile
    
    Headers:
    Authorization: Bearer <token>
    
    Response:
    {
        "status": "success",
        "user": {...}
    }
    """
    return AuthController.get_profile(current_user)


@auth_bp.route('/profile', methods=['PUT'])
@token_required
def update_profile(current_user):
    """
    Update user profile
    PUT /api/auth/profile
    
    Headers:
    Authorization: Bearer <token>
    
    Request body (all optional):
    {
        "name": "John Doe",
        "phone": "03001234567",
        "address": "123 Main Street",
        "city": "Rawalpindi"
    }
    
    Response:
    {
        "status": "success",
        "message": "Profile updated successfully",
        "user": {...}
    }
    """
    return AuthController.update_profile(current_user)


@auth_bp.route('/logout', methods=['POST'])
@token_required
def logout(current_user):
    """
    Logout user
    POST /api/auth/logout
    
    Headers:
    Authorization: Bearer <token>
    
    Response:
    {
        "status": "success",
        "message": "Logout successful"
    }
    """
    return AuthController.logout(current_user)


@auth_bp.route('/verify-token', methods=['POST'])
def verify_token():
    """
    Verify JWT token validity
    POST /api/auth/verify-token
    
    Headers:
    Authorization: Bearer <token>
    
    Response:
    {
        "status": "success",
        "message": "Token is valid",
        "user_id": "...",
        "email": "..."
    }
    """
    from middleware.auth_middleware import token_required as tr
    from services.auth_service import AuthService
    
    try:
        auth_header = request.headers.get('Authorization')
        
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({
                'status': 'error',
                'message': 'Missing or invalid authorization header'
            }), 401
        
        token = auth_header.split(' ')[1]
        
        is_valid, payload, error = AuthService.verify_token(token)
        
        if not is_valid:
            return jsonify({
                'status': 'error',
                'message': error or 'Invalid token'
            }), 401
        
        return jsonify({
            'status': 'success',
            'message': 'Token is valid',
            'user_id': payload.get('user_id'),
            'email': payload.get('email'),
            'name': payload.get('name'),
            'role': payload.get('role'),
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'Token verification failed: {str(e)}'
        }), 500


# ─── HEALTH CHECK ───────────────────────────────────────
@auth_bp.route('/health', methods=['GET'])
def auth_health():
    """Health check for auth endpoints"""
    return jsonify({
        'status': 'success',
        'message': 'Auth service is running',
        'endpoints': {
            'register': 'POST /api/auth/register',
            'login': 'POST /api/auth/login',
            'get_profile': 'GET /api/auth/profile',
            'update_profile': 'PUT /api/auth/profile',
            'logout': 'POST /api/auth/logout',
            'verify_token': 'POST /api/auth/verify-token',
        }
    }), 200