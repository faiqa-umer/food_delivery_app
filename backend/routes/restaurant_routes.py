# ============================================================
# FILE: backend/routes/restaurant_routes.py
# PURPOSE: Defines the URL endpoints for all restaurant APIs.
#          Uses Flask's Blueprint system to keep routes modular.
#
#          A Blueprint is like a mini Flask app — a group of
#          related routes that gets registered with the main app.
#
# ALL ENDPOINTS (prefix /api/restaurants is added in app.py):
#
#   GET    /api/restaurants                  → list all restaurants
#   GET    /api/restaurants/search?q=burger  → search restaurants
#   GET    /api/restaurants/<id>             → get one restaurant
#   POST   /api/restaurants                  → create restaurant
#   PUT    /api/restaurants/<id>             → update restaurant
#   DELETE /api/restaurants/<id>             → delete restaurant
# ============================================================

from flask import Blueprint

# ── Import controller functions (the actual logic lives there) ─
from controllers.restaurant_controller import (
    get_all_restaurants,
    get_restaurant_by_id,
    create_restaurant,
    update_restaurant,
    delete_restaurant,
    search_restaurants,
)

# ── Create the Blueprint ──────────────────────────────────────
# "restaurant_bp" = the name of this blueprint (used internally by Flask)
# This Blueprint is registered in app.py with the prefix /api/restaurants
restaurant_bp = Blueprint("restaurant_bp", __name__)


# ── ROUTE DEFINITIONS ─────────────────────────────────────────
# Each route:
#   1. Specifies the URL pattern (relative to the prefix in app.py)
#   2. Specifies allowed HTTP methods
#   3. Calls the matching controller function

# ── Search must come BEFORE /<restaurant_id> ─────────────────
# WHY: Flask matches routes top-to-bottom. If /<id> is defined
# first, then /search would be treated as an ID value "search"
# and fail validation. Always put specific routes above dynamic ones.

@restaurant_bp.route("/search", methods=["GET"])
def search():
    """
    GET /api/restaurants/search?q=<keyword>
    Searches restaurants by name, description, cuisine, or tags.
    """
    return search_restaurants()


@restaurant_bp.route("", methods=["GET"])
@restaurant_bp.route("/", methods=["GET"])
def list_restaurants():
    """
    GET /api/restaurants and /api/restaurants/
    Returns paginated list of all restaurants.
    Optional filters: ?cuisine=Fast Food&is_open=true&sort_by=rating
    """
    return get_all_restaurants()


@restaurant_bp.route("/<string:restaurant_id>", methods=["GET"])
def retrieve_restaurant(restaurant_id):
    """
    GET /api/restaurants/<restaurant_id>
    Returns a single restaurant by its ID.
    """
    return get_restaurant_by_id(restaurant_id)


@restaurant_bp.route("/", methods=["POST"])
def add_restaurant():
    """
    POST /api/restaurants/
    Creates a new restaurant. Send JSON body with restaurant data.
    """
    return create_restaurant()


@restaurant_bp.route("/<string:restaurant_id>", methods=["PUT"])
def edit_restaurant(restaurant_id):
    """
    PUT /api/restaurants/<restaurant_id>
    Updates fields of an existing restaurant.
    """
    return update_restaurant(restaurant_id)


@restaurant_bp.route("/<string:restaurant_id>", methods=["DELETE"])
def remove_restaurant(restaurant_id):
    """
    DELETE /api/restaurants/<restaurant_id>
    Permanently deletes a restaurant.
    """
    return delete_restaurant(restaurant_id)