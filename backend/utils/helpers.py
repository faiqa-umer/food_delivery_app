# ============================================================
# FILE: backend/utils/helpers.py
# PURPOSE: Shared utility functions used by ALL controllers.
#          Centralising these means if we change how we format
#          a response, we change it in ONE place, not 10.
# ============================================================

from bson import ObjectId          # MongoDB uses ObjectId for _id fields
from bson.errors import InvalidId  # Raised when an ObjectId string is malformed
from datetime import datetime


# ──────────────────────────────────────────────────────────────
# 1. RESPONSE FORMATTERS
#    Every API response follows the same shape so Flutter can
#    reliably parse it without special-casing each endpoint.
# ──────────────────────────────────────────────────────────────

def success_response(data=None, message="Success", status_code=200):
    """
    Builds a standardised SUCCESS response dictionary.

    Shape:
        {
            "status":  "success",
            "message": "...",
            "data":    { ... }   ← the actual payload
        }

    Args:
        data        : The payload (dict, list, or None)
        message     : Human-readable success message
        status_code : HTTP status code (200, 201, etc.)

    Returns:
        tuple: (response_dict, status_code)
               Flask's jsonify() wraps this into a JSON response.
    """
    return {
        "status":  "success",
        "message": message,
        "data":    data,
    }, status_code


def error_response(message="An error occurred", status_code=400, errors=None):
    """
    Builds a standardised ERROR response dictionary.

    Shape:
        {
            "status":  "error",
            "message": "...",
            "errors":  [ ... ]   ← optional list of field-level errors
        }

    Args:
        message     : Human-readable error description
        status_code : HTTP status code (400, 404, 500, etc.)
        errors      : Optional list of specific error details

    Returns:
        tuple: (response_dict, status_code)
    """
    return {
        "status":  "error",
        "message": message,
        "errors":  errors or [],
    }, status_code


# ──────────────────────────────────────────────────────────────
# 2. MONGODB DOCUMENT SERIALIZER
#    MongoDB stores documents with an '_id' field of type ObjectId.
#    ObjectId is NOT JSON-serializable by default — it will crash
#    if you try to return it directly. This function converts it
#    to a plain string so Flask can send it as JSON.
# ──────────────────────────────────────────────────────────────

def serialize_document(document: dict) -> dict:
    """
    Converts a single MongoDB document into a JSON-safe dictionary.

    What it does:
        - Converts ObjectId fields (_id, restaurant_id, etc.) → strings
        - Converts datetime fields → ISO 8601 string ("2024-01-15T10:30:00")

    Args:
        document : A raw MongoDB document (dict)

    Returns:
        dict: A JSON-serializable version of the document
    """
    if document is None:
        return None

    serialized = {}
    for key, value in document.items():
        if isinstance(value, ObjectId):
            # Convert ObjectId to string
            # "_id" → "id" (removes the underscore for cleaner Flutter parsing)
            new_key = "id" if key == "_id" else key
            serialized[new_key] = str(value)

        elif isinstance(value, datetime):
            # Convert datetime to ISO string e.g. "2024-01-15T10:30:00.000000"
            serialized[key] = value.isoformat()

        elif isinstance(value, dict):
            # Recursively serialize nested documents (e.g., address field)
            serialized[key] = serialize_document(value)

        elif isinstance(value, list):
            # Recursively serialize each item in lists
            serialized[key] = [
                serialize_document(item) if isinstance(item, dict)
                else str(item) if isinstance(item, ObjectId)
                else item
                for item in value
            ]
        else:
            serialized[key] = value

    return serialized


def serialize_list(documents: list) -> list:
    """
    Converts a list of MongoDB documents to JSON-safe dicts.

    Args:
        documents : List of raw MongoDB documents

    Returns:
        list: List of JSON-serializable dicts
    """
    return [serialize_document(doc) for doc in documents]


# ──────────────────────────────────────────────────────────────
# 3. OBJECT ID VALIDATOR
#    MongoDB's ObjectId has a specific 24-character hex format.
#    If Flutter sends a bad ID (typo, wrong format), we catch it
#    here before hitting the database.
# ──────────────────────────────────────────────────────────────

def validate_object_id(id_string: str) -> tuple:
    """
    Validates and converts a string into a MongoDB ObjectId.

    Args:
        id_string : The ID string received from the API request

    Returns:
        tuple: (ObjectId, None)          on success
               (None, error_response)    on failure

    Usage in a controller:
        object_id, err = validate_object_id(restaurant_id)
        if err:
            return err        ← immediately return the error to Flutter
    """
    try:
        return ObjectId(id_string), None
    except (InvalidId, TypeError):
        return None, error_response(
            message=f"Invalid ID format: '{id_string}'. Must be a 24-character hex string.",
            status_code=400
        )


# ──────────────────────────────────────────────────────────────
# 4. REQUEST BODY VALIDATOR
#    Checks that required fields are present in the incoming
#    JSON body. Returns clear error messages if fields are missing.
# ──────────────────────────────────────────────────────────────

def validate_required_fields(data: dict, required_fields: list) -> tuple:
    """
    Checks that all required fields are present and non-empty
    in the request body dictionary.

    Args:
        data            : The parsed JSON body from the request
        required_fields : List of field name strings that must exist

    Returns:
        tuple: (True, None)              if all fields are present
               (False, error_response)   if any field is missing

    Usage:
        is_valid, err = validate_required_fields(body, ["name", "price"])
        if not is_valid:
            return err
    """
    missing = []
    for field in required_fields:
        if field not in data or data[field] is None or data[field] == "":
            missing.append(field)

    if missing:
        return False, error_response(
            message=f"Missing required fields: {', '.join(missing)}",
            status_code=422,   # 422 = Unprocessable Entity
            errors=[{"field": f, "message": f"'{f}' is required"} for f in missing]
        )

    return True, None


# ──────────────────────────────────────────────────────────────
# 5. PAGINATION HELPER
#    Handles page/limit query parameters for list endpoints.
#    e.g. GET /api/restaurants?page=2&limit=10
# ──────────────────────────────────────────────────────────────

def get_pagination_params(request_args: dict) -> tuple:
    """
    Extracts and validates pagination parameters from query string.

    Args:
        request_args : Flask's request.args dict

    Returns:
        tuple: (page, limit, skip)
            page  = current page number (1-indexed)
            limit = number of items per page
            skip  = how many documents to skip in MongoDB query
    """
    try:
        page  = max(1, int(request_args.get("page",  1)))
        limit = max(1, min(100, int(request_args.get("limit", 10))))  # max 100 per page
    except (ValueError, TypeError):
        page  = 1
        limit = 10

    skip = (page - 1) * limit   # MongoDB's skip() uses absolute offset
    return page, limit, skip