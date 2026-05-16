🍔 Food Delivery System

A full-stack mobile food delivery application built with Flutter, Flask, and MongoDB — developed as a university final project using a feature-based modular architecture.

📌 Technologies Used
LayerTechnologiesFrontendFlutter, DartBackendFlask (Python), REST APIsDatabaseMongoDB, MongoDB AtlasToolsGit & GitHub, Postman, MongoDB Compass, VS Code, Android Studio

📂 Project Structure
food-delivery-system/
│
├── frontend/
│   ├── auth/           → Wajiha
│   ├── restaurants/    → Faiqa
│   └── orders/         → Ayesha
│
├── backend/
│   ├── auth/
│   ├── restaurants/
│   └── orders/
│
├── database/
├── docs/
└── README.md

👩‍💻 Team Division (Feature-Based)
🔐 Wajiha — Authentication & User Management
<table>
<tr>
<td valign="top" width="33%">
Frontend Screens

Splash Screen
Login Screen
Register Screen
Profile Screen

</td>
<td valign="top" width="33%">
Backend APIs

POST /register
POST /login
GET /profile
POST /logout

</td>
<td valign="top" width="33%">
Database Collection

users

Responsibilities

User Authentication
JWT / Session Handling
Password Validation
Profile Management

</td>
</tr>
</table>

🍕 Faiqa — Restaurants, Menu & Reviews
<table>
<tr>
<td valign="top" width="33%">
Frontend Screens

Home Screen
Restaurant List
Restaurant Details
Food Menu Screen
Search Screen
Review Screen

</td>
<td valign="top" width="33%">
Backend APIs

GET /restaurants
GET /menu
GET /POST /reviews

</td>
<td valign="top" width="33%">
Database Collections

restaurants
menu_items
reviews

Responsibilities

Restaurant Listing
Food Search
Menu Display
Ratings & Reviews

</td>
</tr>
</table>

🛒 Ayesha — Cart, Orders, Payments & Delivery
<table>
<tr>
<td valign="top" width="33%">
Frontend Screens

Cart Screen
Checkout Screen
Payment Screen
Order Tracking Screen
Delivery Status Screen

</td>
<td valign="top" width="33%">
Backend APIs

GET/POST /cart
GET/POST /orders
POST /payments
GET /deliveries

</td>
<td valign="top" width="33%">
Database Collections

carts
orders
order_items
payments
deliveries
notifications

Responsibilities

Cart Management
Order Placement
Payment Integration
Delivery Tracking

</td>
</tr>
</table>

🗄️ Database
All modules share a single MongoDB database:
food_delivery_system
Collections:
CollectionOwnerusersWajiharestaurantsFaiqamenu_itemsFaiqareviewsFaiqacartsAyeshaordersAyeshaorder_itemsAyeshapaymentsAyeshadeliveriesAyeshanotificationsAyesha

🔗 API Integration
The Flutter frontend communicates with Flask backend APIs via HTTP requests.
Flutter App  →  Flask REST API  →  MongoDB

🌟 Features

✅ User Authentication (Register, Login, JWT)
✅ Restaurant Browsing & Search
✅ Food Menu Display
✅ Cart Management
✅ Order Placement
✅ Payment System
✅ Delivery Tracking
✅ Ratings & Reviews
✅ Responsive Mobile UI
✅ RESTful APIs
✅ MongoDB Integration


⚙️ Installation & Setup
1️⃣ Clone the Repository
bashgit clone https://github.com/your-username/food-delivery-system.git
cd food-delivery-system
2️⃣ Backend Setup (Flask)
bashcd backend

# Create virtual environment
python -m venv venv

# Activate — Windows
venv\Scripts\activate

# Activate — Mac/Linux
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run server
python app.py
3️⃣ MongoDB Setup

Install MongoDB Compass or use MongoDB Atlas
Create a database named: food_delivery_system
Update the MongoDB connection string in your Flask configuration file

4️⃣ Flutter Setup
bashcd frontend

# Install packages
flutter pub get

# Run app
flutter run

🌿 GitHub Workflow
Each member works on a separate feature branch:
BranchOwnerauth-moduleWajiharestaurant-moduleFaiqaorder-moduleAyesha
bash# Create and switch to your branch
git checkout -b auth-module

# Stage, commit, and push changes
git add .
git commit -m "Added authentication module"
git push origin auth-module

🤝 Shared Responsibilities
TaskMembersFinal TestingWajiha, Faiqa, AyeshaUI ConsistencyWajiha, Faiqa, AyeshaReport WritingWajiha, Faiqa, AyeshaERD DiagramWajiha, Faiqa, AyeshaGitHub ManagementWajiha, Faiqa, AyeshaViva PreparationWajiha, Faiqa, Ayesha

📖 Learning Outcomes
Through this project, the team developed skills in:

Full-Stack Mobile Application Development
REST API Design & Development
MongoDB Database Design & Modelling
GitHub Collaboration & Branch Management
Modular / Feature-Based Architecture
Team-Based Software Engineering


🚀 Future Improvements

 Live Order Tracking (real-time map)
 Push Notifications
 Online Payment Gateway Integration
 Admin Dashboard
 AI-Based Food Recommendations
 Dark Mode UI


👩‍🎓 Contributors
NameModuleWajihaAuthentication & User ManagementFaiqaRestaurants, Menu & ReviewsAyeshaCart, Orders, Payments & Delivery


📜 This project is developed for educational purposes as a university final project.
