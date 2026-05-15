import re
from typing import Tuple, Optional
from datetime import datetime
 
 
class Validator:
    """Input validation utilities"""
 
    # ─── EMAIL VALIDATION ───────────────────────────────────────
    @staticmethod
    def validate_email(email: str) -> Tuple[bool, Optional[str]]:
        """
        Validate email format
        
        Args:
            email: Email address to validate
            
        Returns:
            Tuple of (is_valid, error_message)
        """
        if not email or not isinstance(email, str):
            return False, "Email is required"
        
        email = email.strip().lower()
        
        # RFC 5322 simplified regex pattern
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        
        if not re.match(pattern, email):
            return False, "Please provide a valid email address"
        
        if len(email) > 254:
            return False, "Email address is too long"
        
        return True, None
 
    # ─── PASSWORD VALIDATION ────────────────────────────────────
    @staticmethod
    def validate_password(password: str) -> Tuple[bool, Optional[str]]:
        """
        Validate password strength
        Requirements:
            - Minimum 6 characters
            - At least one uppercase letter
            - At least one number
            - Optional: special character
        
        Args:
            password: Password to validate
            
        Returns:
            Tuple of (is_valid, error_message)
        """
        if not password or not isinstance(password, str):
            return False, "Password is required"
        
        if len(password) < 6:
            return False, "Password must be at least 6 characters long"
        
        if len(password) > 128:
            return False, "Password is too long"
        
        if not any(char.isupper() for char in password):
            return False, "Password must contain at least one uppercase letter"
        
        if not any(char.isdigit() for char in password):
            return False, "Password must contain at least one number"
        
        return True, None
 
    # ─── NAME VALIDATION ────────────────────────────────────────
    @staticmethod
    def validate_name(name: str) -> Tuple[bool, Optional[str]]:
        """
        Validate user name
        
        Args:
            name: Name to validate
            
        Returns:
            Tuple of (is_valid, error_message)
        """
        if not name or not isinstance(name, str):
            return False, "Name is required"
        
        name = name.strip()
        
        if len(name) < 2:
            return False, "Name must be at least 2 characters long"
        
        if len(name) > 100:
            return False, "Name is too long"
        
        # Allow letters, spaces, hyphens, apostrophes
        if not re.match(r"^[a-zA-Z\s\-']+$", name):
            return False, "Name can only contain letters, spaces, hyphens, and apostrophes"
        
        return True, None
 
    # ─── PHONE VALIDATION ───────────────────────────────────────
    @staticmethod
    def validate_phone(phone: str) -> Tuple[bool, Optional[str]]:
        """
        Validate phone number (international format)
        Accepts: +92 300 1234567, 03001234567, +1-123-456-7890, etc.
        
        Args:
            phone: Phone number to validate
            
        Returns:
            Tuple of (is_valid, error_message)
        """
        if not phone or not isinstance(phone, str):
            return False, "Phone number is required"
        
        phone = phone.strip()
        
        # Remove common separators
        cleaned = re.sub(r'[\s\-().]', '', phone)
        
        # Must start with + or digit
        if not re.match(r'^[\+]?[0-9]', cleaned):
            return False, "Please provide a valid phone number"
        
        # Extract only digits and +
        digits_only = re.sub(r'[^\d+]', '', cleaned)
        
        # Count digits (excluding +)
        digit_count = len(re.sub(r'[^\d]', '', digits_only))
        
        if digit_count < 10:
            return False, "Phone number must have at least 10 digits"
        
        if digit_count > 15:
            return False, "Phone number is too long"
        
        return True, None
 
    # ─── ADDRESS VALIDATION ─────────────────────────────────────
    @staticmethod
    def validate_address(address: str) -> Tuple[bool, Optional[str]]:
        """
        Validate address
        
        Args:
            address: Address to validate
            
        Returns:
            Tuple of (is_valid, error_message)
        """
        if not address or not isinstance(address, str):
            return False, "Address is required"
        
        address = address.strip()
        
        if len(address) < 3:
            return False, "Address must be at least 3 characters long"
        
        if len(address) > 255:
            return False, "Address is too long"
        
        return True, None
 
    # ─── CITY VALIDATION ────────────────────────────────────────
    @staticmethod
    def validate_city(city: str) -> Tuple[bool, Optional[str]]:
        """
        Validate city name
        
        Args:
            city: City name to validate
            
        Returns:
            Tuple of (is_valid, error_message)
        """
        if not city or not isinstance(city, str):
            return False, "City is required"
        
        city = city.strip()
        
        if len(city) < 2:
            return False, "City name must be at least 2 characters long"
        
        if len(city) > 100:
            return False, "City name is too long"
        
        return True, None
 
    # ─── UUID VALIDATION ────────────────────────────────────────
    @staticmethod
    def validate_uuid(user_id: str) -> Tuple[bool, Optional[str]]:
        """
        Validate MongoDB ObjectId format
        
        Args:
            user_id: User ID to validate
            
        Returns:
            Tuple of (is_valid, error_message)
        """
        if not user_id or not isinstance(user_id, str):
            return False, "User ID is required"
        
        # MongoDB ObjectId is 24 hex characters
        if not re.match(r'^[a-f0-9]{24}$', user_id):
            return False, "Invalid user ID format"
        
        return True, None
 
    # ─── ROLE VALIDATION ────────────────────────────────────────
    @staticmethod
    def validate_role(role: str) -> Tuple[bool, Optional[str]]:
        """
        Validate user role
        
        Args:
            role: Role to validate
            
        Returns:
            Tuple of (is_valid, error_message)
        """
        valid_roles = ["customer", "restaurant_owner", "delivery_agent", "admin"]
        
        if not role or role.lower() not in valid_roles:
            return False, f"Role must be one of: {', '.join(valid_roles)}"
        
        return True, None
 
    # ─── REGISTRATION DATA VALIDATION ───────────────────────────
    @staticmethod
    def validate_registration(data: dict) -> Tuple[bool, dict]:
        """
        Validate all registration fields
        
        Args:
            data: Registration data dictionary
            
        Returns:
            Tuple of (is_valid, errors_dict)
        """
        errors = {}
        
        # Name validation
        is_valid, error = Validator.validate_name(data.get("name", ""))
        if not is_valid:
            errors["name"] = error
        
        # Email validation
        is_valid, error = Validator.validate_email(data.get("email", ""))
        if not is_valid:
            errors["email"] = error
        
        # Password validation
        is_valid, error = Validator.validate_password(data.get("password", ""))
        if not is_valid:
            errors["password"] = error
        
        # Phone validation
        is_valid, error = Validator.validate_phone(data.get("phone", ""))
        if not is_valid:
            errors["phone"] = error
        
        return len(errors) == 0, errors
 
    # ─── LOGIN DATA VALIDATION ──────────────────────────────────
    @staticmethod
    def validate_login(data: dict) -> Tuple[bool, dict]:
        """
        Validate login fields
        
        Args:
            data: Login data dictionary
            
        Returns:
            Tuple of (is_valid, errors_dict)
        """
        errors = {}
        
        # Email validation
        is_valid, error = Validator.validate_email(data.get("email", ""))
        if not is_valid:
            errors["email"] = error
        
        # Password validation (just check if provided)
        if not data.get("password"):
            errors["password"] = "Password is required"
        
        return len(errors) == 0, errors