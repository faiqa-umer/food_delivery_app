

"""
    Creates a new restaurant document (dictionary) ready to be
    inserted into the MongoDB 'restaurants' collection.

    Parameters:
        name           : Restaurant name e.g. "Burger Palace"
        description    : Short description
        cuisine_type   : e.g. "Fast Food", "Italian", "Desi"
        address        : dict with keys: street, city, state, zip
        phone          : Contact number
        email          : Contact email
        image_url      : URL to restaurant cover image
        rating         : Average rating (0.0 - 5.0)
        total_reviews  : Count of reviews
        is_open        : Whether restaurant is currently open
        delivery_time_min : Estimated delivery time in minutes
        delivery_fee   : Delivery charge in PKR/USD
        minimum_order  : Minimum order amount
        tags           : List of tags e.g. ["halal", "spicy"]

    Returns:
        dict: A MongoDB-ready document
    """

from datetime import datetime


def create_restaurant_document(
    name: str,
    description: str,
    cuisine_type: str,
    address: dict,
    phone: str,
    email: str,
    image_url: str = "",
    rating: float = 0.0,
    total_reviews: int = 0,
    is_open: bool = True,
    delivery_time_min: int = 30,
    delivery_fee: float = 0.0,
    minimum_order: float = 0.0,
    tags: list = None,
) -> dict:

    return {
        "name":             name,
        "description":      description,
        "cuisine_type":     cuisine_type,

        # address is stored as a nested document (sub-object)
        # e.g. { "street": "123 Main St", "city": "Rawalpindi" }
        "address":          address,
        "phone":            phone,
        "email":            email,

        "image_url":        image_url,

        "rating":           rating,
        "total_reviews":    total_reviews,

        "is_open":          is_open,
        "delivery_time_min": delivery_time_min,
        "delivery_fee":     delivery_fee,
        "minimum_order":    minimum_order,

        "tags":             tags if tags is not None else [],

        "created_at":       datetime.utcnow(),
        "updated_at":       datetime.utcnow(),
    }


