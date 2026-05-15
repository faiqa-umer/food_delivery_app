"""
    Creates documents for the 'orders' and 'order_items' collections in MongoDB.

    Order structure:
    - Main order document with user/restaurant info
    - Separate order_items collection for detailed items
    - Links to payment and delivery
"""

from datetime import datetime


def create_order_document(
    user_id: str,
    restaurant_id: str,
    items: list,
    total_amount: float,
    delivery_address: dict,
    payment_id: str = None,
    delivery_id: str = None,
    status: str = "pending",
) -> dict:
    """
    Creates a new order document.

    Parameters:
        user_id          : Customer placing the order
        restaurant_id    : Restaurant fulfilling the order
        items            : List of order item IDs
        total_amount     : Total order amount
        delivery_address : Delivery address sub-document
        payment_id       : Reference to payments collection
        delivery_id      : Reference to deliveries collection
        status           : Order status

    Returns:
        dict: MongoDB-ready order document
    """
    return {
        "user_id": user_id,
        "restaurant_id": restaurant_id,
        "items": items,  # List of order_item_ids
        "total_amount": total_amount,
        "delivery_address": delivery_address,
        "payment_id": payment_id,
        "delivery_id": delivery_id,
        "status": status,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
    }


def create_order_item_document(
    order_id: str,
    menu_item_id: str,
    quantity: int,
    price: float,
    special_instructions: str = "",
) -> dict:
    """
    Creates an order item document.

    Parameters:
        order_id            : Reference to orders collection
        menu_item_id        : Reference to menu_items collection
        quantity           : Number of items ordered
        price              : Price per item at time of order
        special_instructions: Customer notes

    Returns:
        dict: MongoDB-ready order item document
    """
    return {
        "order_id": order_id,
        "menu_item_id": menu_item_id,
        "quantity": quantity,
        "price": price,
        "special_instructions": special_instructions,
        "created_at": datetime.utcnow(),
    }