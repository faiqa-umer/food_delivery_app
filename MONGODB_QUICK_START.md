# ============================================================
# MONGODB CONNECTION SETUP - QUICK START
# ============================================================

## What You Need to Do (5 Minutes)

### Step 1: Verify `.env` File ✅ DONE
The `.env` file has been created with your connection string:
- Location: `backend/.env`
- Contains: MongoDB Atlas URI, database name, JWT settings

### Step 2: Install Python Packages
Open PowerShell in the `backend` directory and run:

```powershell
pip install -r requirements.txt
```

**What this installs:**
- `pymongo` - MongoDB driver
- `Flask` - Web framework
- `python-dotenv` - Load environment variables
- `PyJWT` - Token authentication
- Other utilities for production

### Step 3: Test the Connection
From the `backend` directory, run:

```powershell
python test_mongodb_connection.py --test
```

**Expected output:**
```
✅ Successfully connected to MongoDB Atlas!
📦 Database: food_delivery_system
📋 Collections in database: 0
```

### Step 4: Import Sample Data (Optional but Recommended)
```powershell
python test_mongodb_connection.py --load-data
```

This will:
1. Create 10 collections automatically
2. Load sample data for testing
3. Create performance indexes
4. Ready for API testing

---

## Verify Each Step

### ✓ Check Connection
```powershell
python -c "from config.database import db; db.client.admin.command('ping'); print('Connected!')"
```

### ✓ Check Collections
```powershell
python -c "from config.database import db; print(db.list_collection_names())"
```

### ✓ Check Sample Data
```powershell
python -c "from config.database import users_collection; print('Users:', users_collection.count_documents({}))"
```

---

## Connection String Details

**What it contains:**
```
mongodb+srv://faiqa-umer:food12345@cluster0.uzdffnc.mongodb.net/food_delivery_system?retryWrites=true&w=majority
```

| Part | Value |
|------|-------|
| Username | faiqa-umer |
| Password | food12345 |
| Cluster | cluster0.uzdffnc.mongodb.net |
| Database | food_delivery_system |

**Security Note:** This is development only. For production, use strong passwords and environment variables!

---

## Collections Created

After importing sample data, you'll have:

| Collection | Purpose | Documents |
|------------|---------|-----------|
| users | User accounts | sample data |
| restaurants | Restaurant info | sample data |
| menu_items | Food menu | sample data |
| orders | Customer orders | sample data |
| order_items | Items in orders | sample data |
| payments | Payment records | sample data |
| deliveries | Delivery tracking | sample data |
| carts | Shopping carts | sample data |
| reviews | Customer reviews | sample data |
| notifications | System alerts | sample data |

---

## Browse in MongoDB Compass (Optional)

For a visual interface:

1. Download: https://www.mongodb.com/products/tools/compass
2. New Connection → Paste the URI
3. Browse `food_delivery_system` database
4. View collections and documents

---

## Start Your Backend

After verification, run your Flask app:

```powershell
cd backend
python app.py
```

The API will be at: `http://localhost:5000`

Test with:
```
http://localhost:5000/health
```

---

## Next: Connect Frontend to Backend

Once the backend is running with real MongoDB:

1. Update Flutter screens to use real API endpoints (not dummy data)
2. Example: Replace `PaymentModel.getDummyPayment()` with `http.get('/api/payments/...')`
3. Add error handling for network failures
4. Test end-to-end workflows

---

## 🆘 Troubleshooting

| Problem | Solution |
|---------|----------|
| "Connection refused" | Check MongoDB Atlas is online, IP whitelisted |
| "Authentication failed" | Verify `.env` has correct credentials |
| "pymongo not found" | Run `pip install -r requirements.txt` |
| "Collections empty" | Run `python test_mongodb_connection.py --load-data` |

---

## ✅ You're Ready!

Your MongoDB connection is configured. Run:
```
python test_mongodb_connection.py --load-data
```

Then start the backend:
```
python app.py
```

Your Food Delivery App is now connected to the live MongoDB cluster! 🚀
