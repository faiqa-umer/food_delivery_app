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
from config.db import db


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
            "version":  "2.0.0",
            "endpoints": {
                "restaurants": "/api/restaurants/",
                "menu":        "/api/menu/",
                "reviews":     "/api/reviews/",
            }
        }), 200

    # ── Register Blueprints ───────────────────────────────────
    # url_prefix: every route in that blueprint is prefixed with this
    # e.g., restaurant_bp's "/" becomes "/api/restaurants/"
    from routes.restaurant_routes import restaurant_bp
    from routes.menu_routes        import menu_bp
    from routes.review_routes      import review_bp

    app.register_blueprint(restaurant_bp, url_prefix="/api/restaurants")
    app.register_blueprint(menu_bp,       url_prefix="/api/menu")
    app.register_blueprint(review_bp,     url_prefix="/api/reviews")

    return app


# ── Run ───────────────────────────────────────────────────────
if __name__ == "__main__":
    app = create_app()

    print("=" * 55)
    print("🍔  Food Delivery Backend — Phase 2 Running!")
    print("=" * 55)
    print("📡  Base URL    : http://localhost:5000")
    print("🔗  Health      : http://localhost:5000/api/health")
    print("🍽️   Restaurants : http://localhost:5000/api/restaurants/")
    print("📋  Menu        : http://localhost:5000/api/menu/")
    print("⭐  Reviews     : http://localhost:5000/api/reviews/")
    print("=" * 55)

    app.run(debug=True, host="0.0.0.0", port=5000)