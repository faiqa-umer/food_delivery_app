"""
    Creates documents for the 'deliveries' collection in MongoDB.

    Delivery structure:
    - Tracks delivery status and location
    - Links to orders and riders
    - Real-time location updates
"""

from datetime import datetime


def create_delivery_document(
    order_id: str,
    rider_id: str = None,
    status: str = "assigned",
    current_location: dict = None,
    estimated_delivery_time: datetime = None,
) -> dict:
    """
    Creates a new delivery document.

    Parameters:
        order_id                : Reference to orders collection
        rider_id                : Rider assigned to delivery
        status                  : Delivery status
        current_location        : Current location sub-document {lat, lng}
        estimated_delivery_time : ETA

    Returns:
        dict: MongoDB-ready delivery document
    """
    return {
        "order_id": order_id,
        "rider_id": rider_id,
        "status": status,
        "current_location": current_location or {"lat": 0.0, "lng": 0.0},
        "estimated_delivery_time": estimated_delivery_time,
        "actual_delivery_time": None,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
    }