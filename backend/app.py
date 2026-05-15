# ============================================================
# FILE: backend/app.py
# PURPOSE: Flask application entry point.
#          UPDATED in Phase 2 to register all route blueprints.
#
# REGISTERED ROUTES:
#   /api/health          → server health check
#   /api/restaurants/... → restaurant operations
#   /api/menu/...        → menu item operations
#   /api/reviews/...     → review operations
# ============================================================

import os
from flask import Flask, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

load_dotenv()

# ── Import DB to verify connection on startup ─────────────────
from config.database import db


def create_app():
    """
    Application factory: creates, configures and returns the Flask app.
    Registering blueprints here keeps app.py clean and modular.
    """
    app = Flask(__name__)
    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "fallback_secret")

    # ── Enable CORS for all routes ────────────────────────────
    # Allows Flutter (running on a different port/device) to
    # make HTTP requests to this server without being blocked.
    CORS(app)

    # ── Health Check ──────────────────────────────────────────
    @app.route("/api/health", methods=["GET"])
    def health_check():
        return jsonify({
            "status":   "success",
            "message":  "Food Delivery API is running!",
            "version":  "3.0.0",
            "endpoints": {
                "restaurants": "/api/restaurants/",
                "menu":        "/api/menu/",
                "reviews":     "/api/reviews/",
                "cart":        "/api/cart/",
                "orders":      "/api/orders/",
                "payments":    "/api/payments/",
                "deliveries":  "/api/deliveries/",
                "notifications": "/api/notifications/",
            }
        }), 200

    # ── Register Blueprints ───────────────────────────────────
    # url_prefix: every route in that blueprint is prefixed with this
    # e.g., restaurant_bp's "/" becomes "/api/restaurants/"
    from routes.restaurant_routes import restaurant_bp
    from routes.menu_routes        import menu_bp
    from routes.review_routes      import review_bp
    from routes.cart_routes        import cart_bp
    from routes.order_routes       import orders_bp
    from routes.payment_routes     import payment_bp
    from routes.delivery_routes    import delivery_bp
    from routes.notification_routes import notification_bp

    app.register_blueprint(restaurant_bp, url_prefix="/api/restaurants")
    app.register_blueprint(menu_bp,       url_prefix="/api/menu")
    app.register_blueprint(review_bp,     url_prefix="/api/reviews")
    app.register_blueprint(cart_bp,       url_prefix="/api/cart")
    app.register_blueprint(orders_bp,     url_prefix="/api/orders")
    app.register_blueprint(payment_bp,    url_prefix="/api/payments")
    app.register_blueprint(delivery_bp,   url_prefix="/api/deliveries")
    app.register_blueprint(notification_bp, url_prefix="/api/notifications")

    return app


# ── Run ───────────────────────────────────────────────────────
if __name__ == "__main__":
    app = create_app()

    print("=" * 55)
    print("🍔  Food Delivery Backend — Phase 3 Running!")
    print("=" * 55)
    print("📡  Base URL       : http://192.168.1.13:5000")
    print("🔗  Health         : http://192.168.1.13:5000/api/health")
    print("🍽️   Restaurants    : http://192.168.1.13:5000/api/restaurants/")
    print("📋  Menu           : http://192.168.1.13:5000/api/menu/")
    print("⭐  Reviews        : http://192.168.1.13:5000/api/reviews/")
    print("🛒  Cart           : http://192.168.1.13:5000/api/cart/")
    print("📦  Orders         : http://192.168.1.13:5000/api/orders/")
    print("💳  Payments       : http://192.168.1.13:5000/api/payments/")
    print("🚚  Deliveries     : http://192.168.1.13:5000/api/deliveries/")
    print("🔔  Notifications  : http://192.168.1.13:5000/api/notifications/")
    print("=" * 55)

    app.run(debug=True, host="0.0.0.0", port=5000)