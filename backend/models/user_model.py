from datetime import datetime
from bson import ObjectId
from typing import Optional, Dict, Any
 
class User:
    """User model representing a customer in the system"""
    
    def __init__(
        self,
        name: str,
        email: str,
        password_hash: str,
        phone: str,
        role: str = "customer",
        _id: Optional[ObjectId] = None,
        created_at: Optional[datetime] = None,
        updated_at: Optional[datetime] = None,
        address: Optional[str] = None,
        city: Optional[str] = None,
        is_active: bool = True,
        total_orders: int = 0,
    ):
        self._id = _id or ObjectId()
        self.name = name
        self.email = email
        self.password_hash = password_hash
        self.phone = phone
        self.role = role
        self.address = address
        self.city = city
        self.is_active = is_active
        self.total_orders = total_orders
        self.created_at = created_at or datetime.utcnow()
        self.updated_at = updated_at or datetime.utcnow()
 
    def to_dict(self, include_password: bool = False) -> Dict[str, Any]:
        """Convert user object to dictionary for MongoDB"""
        data = {
            "_id": self._id,
            "name": self.name,
            "email": self.email,
            "phone": self.phone,
            "role": self.role,
            "address": self.address,
            "city": self.city,
            "is_active": self.is_active,
            "total_orders": self.total_orders,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
        }
        
        if include_password:
            data["password"] = self.password_hash
        
        return data
 
    def to_json(self, include_password: bool = False) -> Dict[str, Any]:
        """Convert user to JSON-serializable format for API responses"""
        data = {
            "user_id": str(self._id),
            "name": self.name,
            "email": self.email,
            "phone": self.phone,
            "role": self.role,
            "address": self.address,
            "city": self.city,
            "is_active": self.is_active,
            "total_orders": self.total_orders,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
        
        if include_password:
            data["password"] = self.password_hash
        
        return data
 
    @staticmethod
    def from_dict(data: Dict[str, Any]) -> "User":
        """Create User object from dictionary (MongoDB document)"""
        return User(
            name=data.get("name", ""),
            email=data.get("email", ""),
            password_hash=data.get("password", ""),
            phone=data.get("phone", ""),
            role=data.get("role", "customer"),
            _id=data.get("_id"),
            created_at=data.get("created_at"),
            updated_at=data.get("updated_at"),
            address=data.get("address"),
            city=data.get("city"),
            is_active=data.get("is_active", True),
            total_orders=data.get("total_orders", 0),
        )
 
    @staticmethod
    def from_json(data: Dict[str, Any]) -> "User":
        """Create User object from JSON (API requests)"""
        return User(
            name=data.get("name", ""),
            email=data.get("email", ""),
            password_hash=data.get("password", ""),
            phone=data.get("phone", ""),
            role=data.get("role", "customer"),
            address=data.get("address"),
            city=data.get("city"),
        )
 
    def update(self, **kwargs) -> None:
        """Update user fields and set updated_at timestamp"""
        allowed_fields = ["name", "phone", "address", "city", "is_active"]
        for key, value in kwargs.items():
            if key in allowed_fields and value is not None:
                setattr(self, key, value)
        self.updated_at = datetime.utcnow()
 
    def is_profile_complete(self) -> bool:
        """Check if user has completed their profile"""
        return all([
            self.name and len(self.name) >= 2,
            self.email,
            self.phone,
            self.address,
            self.city,
        ])
 
    def get_full_address(self) -> str:
        """Get formatted full address"""
        parts = []
        if self.address:
            parts.append(self.address)
        if self.city:
            parts.append(self.city)
        return ", ".join(parts) if parts else "Not provided"
 
    def __repr__(self) -> str:
        return f"<User(id={self._id}, email={self.email}, name={self.name})>"
 
    def __eq__(self, other) -> bool:
        if not isinstance(other, User):
            return False
        return self._id == other._id and self.email == other.email
 
    def __hash__(self) -> int:
        return hash(str(self._id))