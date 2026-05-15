"""
    Creates documents for the 'carts' collection in MongoDB.

    Cart structure:
    - Each user has one cart per restaurant
    - Cart contains multiple items
    - Items reference menu_items and include quantity
"""

from datetime import datetime


def create_cart_document(
    user_id: str,
    restaurant_id: str,
    items: list,
    total_amount: float = 0.0,
) -> dict:
    """
    Creates a new cart document.

    Parameters:
        user_id       : User who owns the cart
        restaurant_id : Restaurant the cart is for
        items         : List of cart items (see create_cart_item_document)
        total_amount  : Calculated total price

    Returns:
        dict: MongoDB-ready cart document
    """
    return {
        "user_id": user_id,
        "restaurant_id": restaurant_id,
        "items": items,
        "total_amount": total_amount,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
    }


def create_cart_item_document(
    menu_item_id: str,
    quantity: int,
    price: float,
    special_instructions: str = "",
) -> dict:
    """
    Creates a cart item sub-document.

    Parameters:
        menu_item_id         : Reference to menu_items collection
        quantity            : Number of items
        price               : Price per item
        special_instructions: Customer notes

    Returns:
        dict: Cart item sub-document
    """
    return {
        "menu_item_id": menu_item_id,
        "quantity": quantity,
        "price": price,
        "special_instructions": special_instructions,
    }