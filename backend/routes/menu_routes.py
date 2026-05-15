# ============================================================
# FILE: backend/routes/menu_routes.py
# PURPOSE: URL endpoints for all menu item operations.
#
# ALL ENDPOINTS (prefix /api/menu added in app.py):
#
#   GET    /api/menu/restaurant/<id>              → all items for a restaurant
#   GET    /api/menu/restaurant/<id>/categories   → distinct category names
#   GET    /api/menu/<menu_item_id>               → single menu item
#   POST   /api/menu/                             → create menu item
#   PUT    /api/menu/<menu_item_id>               → update menu item
#   DELETE /api/menu/<menu_item_id>               → delete menu item
# ============================================================

from flask import Blueprint

from controllers.menu_controller import (
    get_menu_by_restaurant,
    get_menu_item_by_id,
    create_menu_item,
    update_menu_item,
    delete_menu_item,
    get_menu_categories,
)

menu_bp = Blueprint("menu_bp", __name__)


# ── Restaurant-scoped menu routes (no ID conflict risk) ───────
@menu_bp.route("/restaurant/<string:restaurant_id>", methods=["GET"])
def list_menu(restaurant_id):
    """
    GET /api/menu/restaurant/<restaurant_id>
    Returns all menu items for a specific restaurant.
    Optional filter: ?category=Burgers&available=true
    """
    return get_menu_by_restaurant(restaurant_id)


@menu_bp.route("/restaurant/<string:restaurant_id>/categories", methods=["GET"])
def list_categories(restaurant_id):
    """
    GET /api/menu/restaurant/<restaurant_id>/categories
    Returns list of distinct category names for a restaurant.
    Flutter uses this for the category tab bar.
    """
    return get_menu_categories(restaurant_id)


# ── Single item routes ────────────────────────────────────────
@menu_bp.route("/<string:menu_item_id>", methods=["GET"])
def retrieve_menu_item(menu_item_id):
    """
    GET /api/menu/<menu_item_id>
    Returns a single menu item by its ID.
    """
    return get_menu_item_by_id(menu_item_id)


@menu_bp.route("/", methods=["POST"])
def add_menu_item():
    """
    POST /api/menu/
    Creates a new menu item.
    Body must include: restaurant_id, name, description, price, category
    """
    return create_menu_item()


@menu_bp.route("/<string:menu_item_id>", methods=["PUT"])
def edit_menu_item(menu_item_id):
    """
    PUT /api/menu/<menu_item_id>
    Updates a menu item. Common use: toggle is_available.
    """
    return update_menu_item(menu_item_id)


@menu_bp.route("/<string:menu_item_id>", methods=["DELETE"])
def remove_menu_item(menu_item_id):
    """
    DELETE /api/menu/<menu_item_id>
    Permanently deletes a menu item.
    """
    return delete_menu_item(menu_item_id)