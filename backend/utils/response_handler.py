from flask import jsonify
from typing import Any, Dict, Optional, Tuple
from datetime import datetime
 
 
class ResponseHandler:
    """Handles standardized API responses"""
 
    @staticmethod
    def success(
        message: str = "Success",
        data: Optional[Dict[str, Any]] = None,
        status_code: int = 200,
        **extra_fields
    ) -> Tuple[Any, int]:
        """
        Return a success response
        
        Args:
            message: Success message
            data: Response data
            status_code: HTTP status code (default 200)
            **extra_fields: Additional fields to include
            
        Returns:
            Tuple of (JSON response, status code)
        """
        response = {
            "status": "success",
            "message": message,
            "timestamp": datetime.utcnow().isoformat(),
        }
        
        if data is not None:
            response["data"] = data
        
        # Add any extra fields
        response.update(extra_fields)
        
        return jsonify(response), status_code
 
    @staticmethod
    def error(
        message: str = "An error occurred",
        status_code: int = 400,
        error_code: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None,
        **extra_fields
    ) -> Tuple[Any, int]:
        """
        Return an error response
        
        Args:
            message: Error message
            status_code: HTTP status code (default 400)
            error_code: Custom error code
            details: Additional error details
            **extra_fields: Additional fields to include
            
        Returns:
            Tuple of (JSON response, status code)
        """
        response = {
            "status": "error",
            "message": message,
            "timestamp": datetime.utcnow().isoformat(),
        }
        
        if error_code:
            response["error_code"] = error_code
        
        if details:
            response["details"] = details
        
        # Add any extra fields
        response.update(extra_fields)
        
        return jsonify(response), status_code
 
    @staticmethod
    def created(
        message: str = "Resource created successfully",
        data: Optional[Dict[str, Any]] = None,
        **extra_fields
    ) -> Tuple[Any, int]:
        """Return a 201 Created response"""
        return ResponseHandler.success(message, data, 201, **extra_fields)
 
    @staticmethod
    def bad_request(
        message: str = "Bad request",
        details: Optional[Dict[str, Any]] = None,
        **extra_fields
    ) -> Tuple[Any, int]:
        """Return a 400 Bad Request response"""
        return ResponseHandler.error(message, 400, "BAD_REQUEST", details, **extra_fields)
 
    @staticmethod
    def unauthorized(
        message: str = "Unauthorized",
        details: Optional[Dict[str, Any]] = None,
        **extra_fields
    ) -> Tuple[Any, int]:
        """Return a 401 Unauthorized response"""
        return ResponseHandler.error(message, 401, "UNAUTHORIZED", details, **extra_fields)
 
    @staticmethod
    def forbidden(
        message: str = "Forbidden",
        details: Optional[Dict[str, Any]] = None,
        **extra_fields
    ) -> Tuple[Any, int]:
        """Return a 403 Forbidden response"""
        return ResponseHandler.error(message, 403, "FORBIDDEN", details, **extra_fields)
 
    @staticmethod
    def not_found(
        message: str = "Resource not found",
        **extra_fields
    ) -> Tuple[Any, int]:
        """Return a 404 Not Found response"""
        return ResponseHandler.error(message, 404, "NOT_FOUND", **extra_fields)
 
    @staticmethod
    def conflict(
        message: str = "Conflict",
        details: Optional[Dict[str, Any]] = None,
        **extra_fields
    ) -> Tuple[Any, int]:
        """Return a 409 Conflict response"""
        return ResponseHandler.error(message, 409, "CONFLICT", details, **extra_fields)
 
    @staticmethod
    def internal_error(
        message: str = "Internal server error",
        details: Optional[Dict[str, Any]] = None,
        **extra_fields
    ) -> Tuple[Any, int]:
        """Return a 500 Internal Server Error response"""
        return ResponseHandler.error(message, 500, "INTERNAL_ERROR", details, **extra_fields)
 
    @staticmethod
    def validation_error(
        message: str = "Validation failed",
        errors: Optional[Dict[str, str]] = None,
        **extra_fields
    ) -> Tuple[Any, int]:
        """
        Return a validation error response
        
        Args:
            message: Error message
            errors: Dictionary of field-specific errors
        """
        return ResponseHandler.error(
            message,
            400,
            "VALIDATION_ERROR",
            errors,
            **extra_fields
        )
 
    @staticmethod
    def paginated(
        data: list,
        page: int = 1,
        per_page: int = 20,
        total: int = 0,
        message: str = "Data retrieved successfully",
        **extra_fields
    ) -> Tuple[Any, int]:
        """
        Return a paginated response
        
        Args:
            data: List of items
            page: Current page number
            per_page: Items per page
            total: Total number of items
        """
        response = {
            "status": "success",
            "message": message,
            "data": data,
            "pagination": {
                "page": page,
                "per_page": per_page,
                "total": total,
                "total_pages": (total + per_page - 1) // per_page if total > 0 else 0,
            },
            "timestamp": datetime.utcnow().isoformat(),
        }
        
        response.update(extra_fields)
        
        return jsonify(response), 200
 