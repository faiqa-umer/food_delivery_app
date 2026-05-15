#!/usr/bin/env python3
# ============================================================
# FILE: backend/test_mongodb_connection.py
# PURPOSE: Test MongoDB Atlas connection and import sample data
#
# USAGE:
#   python test_mongodb_connection.py --test              # Test connection only
#   python test_mongodb_connection.py --load-data         # Test + import sample data
#   python test_mongodb_connection.py --clear             # Clear all collections
# ============================================================

import sys
import json
import argparse
from pathlib import Path
from config.database import db, restaurants_collection, menu_items_collection, \
    reviews_collection, carts_collection, orders_collection, order_items_collection, \
    payments_collection, deliveries_collection, notifications_collection, users_collection


def test_connection():
    """Test MongoDB Atlas connection"""
    print("=" * 60)
    print("Testing MongoDB Atlas Connection...")
    print("=" * 60)
    
    try:
        # Try to run a simple ping command
        client = db.client
        client.admin.command('ping')
        print("✅ Successfully connected to MongoDB Atlas!")
        print(f"📦 Database: {db.name}")
        
        # List all collections
        collections = db.list_collection_names()
        print(f"📋 Collections in database: {len(collections)}")
        for col in collections:
            count = db[col].count_documents({})
            print(f"   • {col}: {count} documents")
        
        return True
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        return False


def import_sample_data():
    """Import sample data from JSON files"""
    print("\n" + "=" * 60)
    print("Importing Sample Data...")
    print("=" * 60)
    
    database_path = Path(__file__).parent.parent / "database" / "collections"
    
    collections_to_import = {
        "users_collection.json": users_collection,
        "restaurants_collection.json": restaurants_collection,
        "menu_items_collection.json": menu_items_collection,
        "orders_collection.json": orders_collection,
        "payments_collection.json": payments_collection,
        "deliveries_collection.json": deliveries_collection,
        "carts_collection.json": carts_collection,
        "order_items_collection.json": order_items_collection,
        "reviews_collection.json": reviews_collection,
        "notifications_collection.json": notifications_collection,
    }
    
    success_count = 0
    
    for filename, collection in collections_to_import.items():
        file_path = database_path / filename
        
        if not file_path.exists():
            print(f"⚠️  File not found: {filename}")
            continue
        
        try:
            with open(file_path, 'r') as f:
                data = json.load(f)
            
            # Data should be a list of documents
            if isinstance(data, list):
                # Clear existing data
                collection.delete_many({})
                # Insert new data
                result = collection.insert_many(data)
                print(f"✅ {filename}: {len(result.inserted_ids)} documents imported")
                success_count += 1
            else:
                print(f"❌ {filename}: Expected list of documents")
        except Exception as e:
            print(f"❌ {filename}: {e}")
    
    print(f"\n📊 Successfully imported data for {success_count} collections")
    return success_count > 0


def clear_all_collections():
    """Clear all collections (WARNING: destructive operation)"""
    print("\n" + "=" * 60)
    print("⚠️  Clearing All Collections...")
    print("=" * 60)
    
    confirm = input("Are you sure? This will delete ALL data. Type 'YES' to confirm: ")
    
    if confirm != "YES":
        print("❌ Operation cancelled")
        return False
    
    collections = [
        users_collection, restaurants_collection, menu_items_collection,
        orders_collection, payments_collection, deliveries_collection,
        carts_collection, order_items_collection, reviews_collection,
        notifications_collection
    ]
    
    for collection in collections:
        count = collection.count_documents({})
        collection.delete_many({})
        print(f"🗑️  {collection.name}: {count} documents deleted")
    
    print("✅ All collections cleared!")
    return True


def create_indexes():
    """Create MongoDB indexes for performance"""
    print("\n" + "=" * 60)
    print("Creating Indexes...")
    print("=" * 60)
    
    try:
        # Users indexes
        users_collection.create_index("email", unique=True)
        print("✅ users_collection: email index created")
        
        # Orders indexes
        orders_collection.create_index("user_id")
        orders_collection.create_index("restaurant_id")
        orders_collection.create_index("status")
        print("✅ orders_collection: user_id, restaurant_id, status indexes created")
        
        # Deliveries indexes
        deliveries_collection.create_index("order_id")
        deliveries_collection.create_index("rider_id")
        deliveries_collection.create_index("status")
        print("✅ deliveries_collection: order_id, rider_id, status indexes created")
        
        # Payments indexes
        payments_collection.create_index("order_id")
        payments_collection.create_index("user_id")
        payments_collection.create_index("status")
        print("✅ payments_collection: order_id, user_id, status indexes created")
        
        # Restaurants indexes
        restaurants_collection.create_index("owner_id")
        restaurants_collection.create_index("status")
        print("✅ restaurants_collection: owner_id, status indexes created")
        
        # Menu items indexes
        menu_items_collection.create_index("restaurant_id")
        menu_items_collection.create_index("category")
        print("✅ menu_items_collection: restaurant_id, category indexes created")
        
        # Carts indexes
        carts_collection.create_index("user_id", unique=True)
        print("✅ carts_collection: user_id index created")
        
        print("\n✅ All indexes created successfully!")
        return True
    except Exception as e:
        print(f"❌ Error creating indexes: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description='MongoDB Atlas connection and data import tool'
    )
    parser.add_argument(
        '--test',
        action='store_true',
        help='Test MongoDB connection only'
    )
    parser.add_argument(
        '--load-data',
        action='store_true',
        help='Test connection and import sample data'
    )
    parser.add_argument(
        '--clear',
        action='store_true',
        help='Clear all collections'
    )
    parser.add_argument(
        '--indexes',
        action='store_true',
        help='Create database indexes'
    )
    
    args = parser.parse_args()
    
    # Default action: test connection
    if not any(vars(args).values()):
        args.test = True
    
    # Run test
    if args.test or args.load_data or args.clear:
        if not test_connection():
            sys.exit(1)
    
    # Run import
    if args.load_data:
        import_sample_data()
    
    # Create indexes
    if args.load_data or args.indexes:
        create_indexes()
    
    # Clear collections
    if args.clear:
        clear_all_collections()
    
    print("\n" + "=" * 60)
    print("✅ Done!")
    print("=" * 60)


if __name__ == "__main__":
    main()
