# ============================================================
# FILE: backend/config/database.py
# PURPOSE: Establishes a single connection to MongoDB Atlas.
#          All models and controllers import 'db' from here.
# ============================================================

import os
from pymongo import MongoClient
from dotenv import load_dotenv

# ── Load the .env file so we can access MONGO_URI and DB_NAME ──
load_dotenv()

# ── Read values from the .env file ──
MONGO_URI = os.getenv("MONGO_URI")
DB_NAME   = os.getenv("DB_NAME", "food_delivery_db")  # default fallback


def get_database():
    """
    Creates a MongoClient and returns the database object.

    Returns:
        db (Database): The MongoDB database instance.

    How it works:
        MongoClient connects to Atlas using the URI string.
        Think of it like a phone call — MongoClient dials Atlas,
        and we ask for a specific 'room' (database) inside it.
    """
    client = MongoClient(MONGO_URI)
    return client[DB_NAME]


# ── Single shared database instance used across the whole app ──
# We create it once here so every import gets the same connection.
db = get_database()


# ── Named collection references (like named tables in SQL) ──
# These are the exact collections Member 2 is responsible for.
restaurants_collection  = db["restaurants"]
menu_items_collection   = db["menu_items"]
reviews_collection      = db["reviews"]