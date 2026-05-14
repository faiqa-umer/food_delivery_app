# ============================================================
# FILE: backend/app.py
# PURPOSE: This is the ENTRY POINT of the Flask backend.
#          Running this file starts the web server.
#          It will later register all route blueprints.
# ============================================================

import os
from flask import Flask, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

# ── Load environment variables from .env ──────────────────────
load_dotenv()

# ── Import database connection to verify it on startup ────────
from config.database import db


def create_app():
    """
    Application factory pattern.
    Creates and configures the Flask app.

    Why factory pattern?
        It lets us create multiple app instances (e.g., one for
        testing, one for production) without conflicts.
    """

    app = Flask(__name__)

    # ── Secret key (used for sessions, tokens) ─────────────────
    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "fallback_secret")

    # ── Enable CORS ────────────────────────────────────────────
    # CORS (Cross-Origin Resource Sharing) allows our Flutter app
    # to make HTTP requests to this Flask server from a different
    # origin (different port or domain).
    CORS(app)

    # ── Health Check Route ─────────────────────────────────────
    # Used to verify the server is running.
    # Test it by visiting: http://localhost:5000/api/health
    @app.route("/api/health", methods=["GET"])
    def health_check():
        return jsonify({
            "status": "success",
            "message": "Food Delivery API is running!",
            "database": "Connected to MongoDB Atlas"
        }), 200

    # ── Register Route Blueprints (added in Phase 2) ───────────
    # Blueprints are modular route files.
    # We'll uncomment these as we build each module in Phase 2:
    #
    # from routes.restaurant_routes import restaurant_bp
    # from routes.menu_routes import menu_bp
    # from routes.review_routes import review_bp
    #
    # app.register_blueprint(restaurant_bp, url_prefix="/api/restaurants")
    # app.register_blueprint(menu_bp,       url_prefix="/api/menu")
    # app.register_blueprint(review_bp,     url_prefix="/api/reviews")

    return app


# ── Run the app ────────────────────────────────────────────────
if __name__ == "__main__":
    app = create_app()

    print("=" * 50)
    print("🍔 Food Delivery Backend Started!")
    print("📡 Server: http://localhost:5000")
    print("🔗 Health: http://localhost:5000/api/health")
    print("=" * 50)

    # debug=True: auto-restarts server when you save a file
    # Only use debug=True in development, NOT in production!
    app.run(debug=True, host="0.0.0.0", port=5000)