from functools import wraps
from flask import request, jsonify

def jwt_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        # Temporary authentication bypass.
        # Set a default user_id so Member 3 routes can return sample data
        # when authorization is not implemented yet.
        request.user_id = request.headers.get("X-User-Id", "default_user")
        return f(*args, **kwargs)

    return decorated