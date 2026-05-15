# ============================================================
# MongoDB Atlas Setup Guide - Food Delivery App
# ============================================================

## 📋 Connection Details

Your groupmate has provided this MongoDB Atlas connection string:

```
MONGO_URI=mongodb+srv://faiqa-umer:food12345@cluster0.uzdffnc.mongodb.net/food_delivery_system?retryWrites=true&w=majority
```

### Connection String Breakdown:
- **Username**: faiqa-umer
- **Password**: food12345
- **Cluster**: cluster0.uzdffnc.mongodb.net
- **Database**: food_delivery_system
- **Region**: South Asia (UDF)

---

## ✅ Setup Steps

### 1. Verify the `.env` File (Already Created)

The `.env` file has been created at `backend/.env` with the connection string:

```
MONGO_URI=mongodb+srv://faiqa-umer:food12345@cluster0.uzdffnc.mongodb.net/food_delivery_system?retryWrites=true&w=majority
DB_NAME=food_delivery_system
```

### 2. Install Required Python Packages

```bash
pip install pymongo python-dotenv
```

Or install all dependencies from requirements.txt:

```bash
pip install -r backend/requirements.txt
```

### 3. Test MongoDB Connection

Navigate to the backend directory and run:

```bash
# Test connection only
python test_mongodb_connection.py --test

# Test connection and import sample data
python test_mongodb_connection.py --load-data

# Create database indexes for performance
python test_mongodb_connection.py --indexes

# Clear all data (WARNING: destructive)
python test_mongodb_connection.py --clear
```

---

## 📦 Collections Structure

The following 10 collections will be automatically created:

### Member 1 Collections:
- **users** - User accounts, authentication, profiles

### Member 2 Collections:
- **restaurants** - Restaurant information and metadata
- **menu_items** - Food items offered by restaurants
- **reviews** - Customer reviews and ratings

### Member 3 Collections:
- **carts** - Shopping carts per user
- **orders** - Customer orders
- **order_items** - Items within each order
- **payments** - Payment transactions
- **deliveries** - Delivery tracking information
- **notifications** - System notifications

---

## 🔑 Sample Data Import

The app includes sample data for all collections in `database/collections/`:

```
database/
├── collections/
│   ├── users_collection.json
│   ├── restaurants_collection.json
│   ├── menu_items_collection.json
│   ├── orders_collection.json
│   ├── payments_collection.json
│   ├── deliveries_collection.json
│   ├── carts_collection.json
│   ├── order_items_collection.json
│   ├── reviews_collection.json
│   └── notifications_collection.json
└── indexes/
    └── mongodb_indexes.txt
```

**To import sample data:**

```bash
python test_mongodb_connection.py --load-data
```

This will:
1. ✅ Test the connection
2. ✅ Load JSON files from `database/collections/`
3. ✅ Clear existing collections
4. ✅ Insert new sample documents
5. ✅ Create performance indexes

---

## 🌐 Using MongoDB Compass (GUI)

For visual inspection and manual testing:

### 1. Download MongoDB Compass
- Visit: https://www.mongodb.com/products/tools/compass
- Download for Windows

### 2. Connect to Your Cluster
1. Open MongoDB Compass
2. Click "New Connection"
3. Paste the connection string:
   ```
   mongodb+srv://faiqa-umer:food12345@cluster0.uzdffnc.mongodb.net/food_delivery_system?retryWrites=true&w=majority
   ```
4. Click "Connect"

### 3. Browse Collections
- Navigate to `food_delivery_system` database
- View all collections
- Inspect documents in real-time
- Query data using MongoDB query syntax

---

## 🧪 Testing the Connection

### Quick Python Test

```python
from config.database import db, users_collection

# Test connection
try:
    db.client.admin.command('ping')
    print("✅ Connected to MongoDB Atlas!")
except Exception as e:
    print(f"❌ Connection failed: {e}")

# Check collections
print("Collections:", db.list_collection_names())

# Count documents
print("Users:", users_collection.count_documents({}))
print("Restaurants:", restaurants_collection.count_documents({}))
```

### Flask Backend Test

```bash
# Navigate to backend directory
cd backend

# Run the Flask app
python app.py

# Test endpoints in another terminal
curl http://localhost:5000/health

# Check MongoDB integration
curl http://localhost:5000/api/restaurants/list
```

---

## ⚠️ Important Security Notes

### Current Setup (Development Only):
- ✅ Connection string is hardcoded in `.env`
- ✅ Credentials are visible to group members
- ✅ Good for learning and development

### For Production:
1. **Rotate credentials** - Change password in MongoDB Atlas
2. **Use environment variables** - Don't commit `.env` to Git
3. **IP Whitelist** - Add only your server IP in Atlas
4. **Create read-only users** - For specific roles
5. **Enable encryption** - Use TLS/SSL (already enabled by default)

### Add to `.gitignore`:

```
.env
.env.local
*.pyc
__pycache__/
venv/
.DS_Store
```

---

## 🔗 MongoDB Atlas Dashboard

Monitor your cluster:

1. Visit: https://cloud.mongodb.com
2. Login with: **faiqa-umer** account
3. Select: **cluster0** (UDF)
4. Monitor:
   - Connection metrics
   - Query performance
   - Storage usage
   - Active connections

---

## 🚀 Next Steps

### Phase 4 - API Integration

1. **Backend**: Replace dummy data calls with real MongoDB queries
   - All models already use database collections
   - Controllers execute find/insert/update/delete operations

2. **Frontend**: Replace mock data with HTTP API calls
   - Update `lib/services/` to make HTTP requests
   - Use `http` package for REST calls
   - Handle real authentication with JWT tokens

3. **Testing**: Validate end-to-end workflows
   - Create order in Flutter → API → MongoDB
   - Update delivery status → Backend → Frontend
   - Process payment → Database → History

---

## 🆘 Troubleshooting

### ❌ "Connection Refused"
- **Check**: Is MongoDB Atlas running?
- **Check**: Is your IP whitelisted in Atlas?
- **Solution**: Go to Atlas Dashboard → Network Access → Add your IP

### ❌ "Authentication Failed"
- **Check**: Are credentials correct?
- **Check**: Is MONGO_URI in `.env`?
- **Solution**: Verify username/password in `.env`

### ❌ "Database Not Found"
- **Check**: Does `food_delivery_system` exist?
- **Solution**: Collections are auto-created on first insert

### ❌ "Slow Queries"
- **Solution**: Run `python test_mongodb_connection.py --indexes`
- **Check**: MongoDB Compass → Performance Stats

---

## 📞 Contact & Support

For issues with MongoDB Atlas:
- **Support**: https://docs.mongodb.com/support/
- **Community**: https://community.mongodb.com/
- **Docs**: https://docs.mongodb.com/atlas/

For your specific cluster:
- **Database**: food_delivery_system
- **Region**: UDF (South Asia)
- **Cluster**: cluster0

---

## ✅ Checklist

- [ ] `.env` file created with connection string
- [ ] Dependencies installed (`pymongo`, `python-dotenv`)
- [ ] Connection tested: `python test_mongodb_connection.py --test`
 - [ ] Sample data imported: `python test_mongodb_connection.py --load-data`
- [ ] Indexes created: `python test_mongodb_connection.py --indexes`
- [ ] MongoDB Compass connected and verified
- [ ] Backend Flask app starts without errors
- [ ] API endpoints return real data from MongoDB

---

**You're all set! Your app is now connected to MongoDB Atlas.** 🎉
