"""
    Creates a menu item document ready for MongoDB insertion.

    Parameters:
        restaurant_id       : The _id of the restaurant this item belongs to
                              (stored as string, converted to ObjectId when querying)
        name                : Item name e.g. "Cheese Burger"
        description         : Short description of the item
        price               : Price in local currency
        category            : e.g. "Burgers", "Drinks", "Desserts"
        image_url           : URL to item image
        is_available        : Can customers currently order this?
        is_vegetarian       : True if vegetarian
        is_vegan            : True if vegan
        is_spicy            : True if spicy
        calories            : Caloric value
        preparation_time_min: How long it takes to prepare
        discount_percent    : Discount % applied to price (0 = no discount)

    Returns:
        dict: MongoDB-ready document
    """

from datetime import datetime

def create_menu_item_document(
    restaurant_id: str,
    name: str,
    description: str,
    price: float,
    category: str,
    image_url: str = "",
    is_available: bool = True,
    is_vegetarian: bool = False,
    is_vegan: bool = False,
    is_spicy: bool = False,
    calories: int = 0,
    preparation_time_min: int = 15,
    discount_percent: float = 0.0,
) -> dict:

    #Calculate discounted price
    discounted_price = price
    if discount_percent > 0:
        discounted_price = round(price - (price * discount_percent / 100), 2)

    return {
        # ── Relationship: which restaurant owns this item ──────
        # NOTE: We store restaurant_id as a string here.
        # In the controller, we'll convert it to ObjectId for queries.
        "restaurant_id":        restaurant_id,

        #main info
        "name":                 name,
        "description":          description,
        "price":                price,
        "discounted_price":     discounted_price,
        "discount_percent":     discount_percent,

        "category":             category,

        
        "image_url":            image_url,

        #availability
        "is_available":         is_available,

        #dietary info
        "is_vegetarian":        is_vegetarian,
        "is_vegan":             is_vegan,
        "is_spicy":             is_spicy,

        #additional info
        "calories":             calories,
        "preparation_time_min": preparation_time_min,

        #timestamps
        "created_at":           datetime.utcnow(),
        "updated_at":           datetime.utcnow(),
    }

