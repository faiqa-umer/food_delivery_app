<div align="center">

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=30&duration=3000&pause=1000&color=F97316&center=true&vCenter=true&width=600&lines=🍔+Food+Delivery+System;Flutter+%7C+Flask+%7C+MongoDB" alt="Typing SVG" />

<br/>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white"/>
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white"/>
  <img src="https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Status-University%20Project-orange?style=flat-square"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue?style=flat-square"/>
  <img src="https://img.shields.io/badge/Architecture-Feature--Based%20Modular-green?style=flat-square"/>
  <img src="https://img.shields.io/badge/License-Educational-red?style=flat-square"/>
</p>

<br/>

> **A full-stack mobile food delivery application** built with Flutter, Flask, and MongoDB.
> Developed as a university final year project using a clean, feature-based modular architecture —
> where each team member owns their module end-to-end: frontend, backend, and database.

<br/>

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Tech Stack](#-tech-stack)
- [System Architecture](#-system-architecture)
- [Project Structure](#-project-structure)
- [Team & Modules](#-team--modules)
- [Database Design](#-database-design)
- [API Reference](#-api-reference)
- [Features](#-features)
- [Installation & Setup](#-installation--setup)
- [GitHub Workflow](#-github-workflow)
- [Shared Responsibilities](#-shared-responsibilities)
- [Learning Outcomes](#-learning-outcomes)
- [Future Roadmap](#-future-roadmap)
- [Contributors](#-contributors)

---

## 🌐 Overview

The **Food Delivery System** is a cross-platform mobile application that connects users with local restaurants, enabling seamless browsing, ordering, payment, and delivery tracking — all from a single mobile interface.

The project follows a **feature-based modular architecture**, where each team member is fully responsible for their own feature module across all layers of the stack. This approach simulates real-world team-based software development practices.

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Mobile Frontend** | Flutter + Dart | Cross-platform UI (Android & iOS) |
| **Backend** | Flask (Python) | RESTful API server |
| **Database** | MongoDB | NoSQL document storage |
| **Cloud DB** | MongoDB Atlas | Hosted cloud database |
| **API Testing** | Postman | Endpoint testing & documentation |
| **Version Control** | Git & GitHub | Collaboration & source control |
| **IDE** | VS Code / Android Studio | Development environment |

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER MOBILE APP                      │
│           (Dart — Cross Platform: Android & iOS)            │
└───────────────────────┬─────────────────────────────────────┘
                        │  HTTP Requests (REST)
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                     FLASK REST API                          │
│               (Python — Backend Server)                     │
│                                                             │
│    /auth/*         /restaurants/*        /orders/*          │
│    Wajiha          Faiqa                 Ayesha             │
└───────────────────────┬─────────────────────────────────────┘
                        │  Database Queries
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                       MONGODB                               │
│            Database: food_delivery_system                   │
│                                                             │
│   users  │  restaurants  │  orders  │  payments  │  ...    │
└─────────────────────────────────────────────────────────────┘
```

---

## 📂 Project Structure

```
food-delivery-system/
│
├── 📁 frontend/                    # Flutter mobile application
│   ├── 📁 auth/                    # Wajiha — Login, Register, Profile
│   ├── 📁 restaurants/             # Faiqa  — Home, Menu, Reviews
│   └── 📁 orders/                  # Ayesha — Cart, Orders, Payments
│
├── 📁 backend/                     # Flask REST API server
│   ├── 📁 auth/                    # Authentication routes & logic
│   ├── 📁 restaurants/             # Restaurant & menu routes
│   └── 📁 orders/                  # Cart, order & payment routes
│
├── 📁 database/                    # DB schemas, seed data, ERD
├── 📁 docs/                        # Project documentation & reports
├── 📄 requirements.txt             # Python dependencies
└── 📄 README.md
```

---

## 👩‍💻 Team & Modules

The project is divided into three independent feature modules. Each member handles the complete feature stack — frontend, backend, and database.

---

### 🔐 Module 1 — Wajiha · Authentication & User Management

> Handles all aspects of user identity, access control, and profile management.

<table>
<tr>
<th>📱 Frontend Screens</th>
<th>⚙️ Backend Endpoints</th>
<th>🗄️ Database</th>
<th>🎯 Responsibilities</th>
</tr>
<tr>
<td>

- Splash Screen
- Login Screen
- Register Screen
- Profile Screen

</td>
<td>

- `POST /register`
- `POST /login`
- `GET  /profile`
- `PUT  /profile`
- `POST /logout`

</td>
<td>

**Collection:**
- `users`

</td>
<td>

- User Authentication
- JWT Token Handling
- Session Management
- Password Validation
- Profile Management

</td>
</tr>
</table>

---

### 🍕 Module 2 — Faiqa · Restaurants, Menu & Reviews

> Handles restaurant discovery, food menu browsing, search, and customer reviews.

<table>
<tr>
<th>📱 Frontend Screens</th>
<th>⚙️ Backend Endpoints</th>
<th>🗄️ Database</th>
<th>🎯 Responsibilities</th>
</tr>
<tr>
<td>

- Home Screen
- Restaurant List
- Restaurant Details
- Food Menu Screen
- Search Screen
- Review Screen

</td>
<td>

- `GET  /restaurants`
- `GET  /restaurants/:id`
- `GET  /menu/:restaurant_id`
- `GET  /search`
- `GET  /reviews/:id`
- `POST /reviews`

</td>
<td>

**Collections:**
- `restaurants`
- `menu_items`
- `reviews`

</td>
<td>

- Restaurant Listing
- Menu Display
- Food Search & Filter
- Ratings & Reviews
- Category Browsing

</td>
</tr>
</table>

---

### 🛒 Module 3 — Ayesha · Cart, Orders, Payments & Delivery

> Handles the complete order lifecycle — from cart management to delivery tracking.

<table>
<tr>
<th>📱 Frontend Screens</th>
<th>⚙️ Backend Endpoints</th>
<th>🗄️ Database</th>
<th>🎯 Responsibilities</th>
</tr>
<tr>
<td>

- Cart Screen
- Checkout Screen
- Payment Screen
- Order Tracking Screen
- Delivery Status Screen

</td>
<td>

- `GET/POST   /cart`
- `DELETE     /cart/:item_id`
- `POST       /orders`
- `GET        /orders/:id`
- `POST       /payments`
- `GET        /deliveries/:order_id`

</td>
<td>

**Collections:**
- `carts`
- `orders`
- `order_items`
- `payments`
- `deliveries`
- `notifications`

</td>
<td>

- Cart Management
- Order Placement
- Payment Integration
- Delivery Tracking
- Push Notifications

</td>
</tr>
</table>

---

## 🗄️ Database Design

**Database Name:** `food_delivery_system`

| Collection | Module | Description |
|------------|--------|-------------|
| `users` | 🔐 Wajiha | User accounts, credentials, profile info |
| `restaurants` | 🍕 Faiqa | Restaurant listings, location, hours |
| `menu_items` | 🍕 Faiqa | Food items, prices, categories, images |
| `reviews` | 🍕 Faiqa | Customer ratings and review text |
| `carts` | 🛒 Ayesha | Active cart sessions per user |
| `orders` | 🛒 Ayesha | Placed orders and their statuses |
| `order_items` | 🛒 Ayesha | Individual items within each order |
| `payments` | 🛒 Ayesha | Payment records and transaction details |
| `deliveries` | 🛒 Ayesha | Delivery assignments and status tracking |
| `notifications` | 🛒 Ayesha | Push notification logs per user |

---

## 📡 API Reference

### Authentication — Wajiha

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|:---:|
| `POST` | `/register` | Create a new user account | ❌ |
| `POST` | `/login` | Authenticate user, return JWT | ❌ |
| `GET` | `/profile` | Get current user profile | ✅ |
| `PUT` | `/profile` | Update user profile | ✅ |
| `POST` | `/logout` | Invalidate session token | ✅ |

### Restaurants & Menu — Faiqa

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|:---:|
| `GET` | `/restaurants` | List all restaurants | ❌ |
| `GET` | `/restaurants/:id` | Get restaurant details | ❌ |
| `GET` | `/menu/:restaurant_id` | Get menu for a restaurant | ❌ |
| `GET` | `/search?q=` | Search restaurants or food items | ❌ |
| `GET` | `/reviews/:restaurant_id` | Get reviews for a restaurant | ❌ |
| `POST` | `/reviews` | Submit a new review | ✅ |

### Orders & Delivery — Ayesha

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|:---:|
| `GET` | `/cart` | Get current user's cart | ✅ |
| `POST` | `/cart` | Add item to cart | ✅ |
| `DELETE` | `/cart/:item_id` | Remove item from cart | ✅ |
| `POST` | `/orders` | Place a new order | ✅ |
| `GET` | `/orders/:id` | Get order details & status | ✅ |
| `POST` | `/payments` | Process a payment | ✅ |
| `GET` | `/deliveries/:order_id` | Track delivery status | ✅ |

---

## 🌟 Features

| Feature | Status | Module |
|---------|:------:|--------|
| User Registration & Login | ✅ | Wajiha |
| JWT Authentication | ✅ | Wajiha |
| Profile Management | ✅ | Wajiha |
| Restaurant Browsing | ✅ | Faiqa |
| Food Search & Filter | ✅ | Faiqa |
| Menu Display | ✅ | Faiqa |
| Ratings & Reviews | ✅ | Faiqa |
| Cart Management | ✅ | Ayesha |
| Order Placement | ✅ | Ayesha |
| Payment Processing | ✅ | Ayesha |
| Delivery Tracking | ✅ | Ayesha |
| Push Notifications | ✅ | Ayesha |
| Responsive Mobile UI | ✅ | All |
| RESTful API Design | ✅ | All |

---

## ⚙️ Installation & Setup

### Prerequisites

Ensure the following are installed before proceeding:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.0+)
- [Python](https://www.python.org/downloads/) (v3.8+)
- [MongoDB Compass](https://www.mongodb.com/products/compass) or a [MongoDB Atlas](https://www.mongodb.com/atlas) account
- [Git](https://git-scm.com/)

---

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/your-username/food-delivery-system.git
cd food-delivery-system
```

---

### 2️⃣ Backend Setup (Flask)

```bash
# Navigate to backend
cd backend

# Create a virtual environment
python -m venv venv

# Activate — Windows
venv\Scripts\activate

# Activate — macOS / Linux
source venv/bin/activate

# Install all dependencies
pip install -r requirements.txt

# Start the Flask server
python app.py
```

> The Flask server will run at `http://localhost:5000`

---

### 3️⃣ MongoDB Setup

1. Open **MongoDB Compass** or log in to **MongoDB Atlas**
2. Create a new database named:
   ```
   food_delivery_system
   ```
3. Update the connection string in `backend/config.py`:
   ```python
   # Local
   MONGO_URI = "mongodb://localhost:27017/food_delivery_system"

   # MongoDB Atlas
   MONGO_URI = "mongodb+srv://<username>:<password>@cluster.mongodb.net/food_delivery_system"
   ```

---

### 4️⃣ Flutter Setup

```bash
# Navigate to frontend
cd frontend

# Install Flutter packages
flutter pub get

# Run the app (ensure a device or emulator is connected)
flutter run
```

> Make sure the `baseUrl` in your Flutter API config points to your Flask server address.

---

## 🌿 GitHub Workflow

Each team member works on a dedicated feature branch and opens a pull request before merging into `main`.

| Branch | Owner | Module |
|--------|-------|--------|
| `auth-module` | Wajiha | Authentication & User Management |
| `restaurant-module` | Faiqa | Restaurants, Menu & Reviews |
| `order-module` | Ayesha | Cart, Orders, Payments & Delivery |

```bash
# Step 1: Create your feature branch
git checkout -b auth-module

# Step 2: Stage your changes
git add .

# Step 3: Commit with a clear, descriptive message
git commit -m "feat(auth): add JWT login and register endpoints"

# Step 4: Push to remote
git push origin auth-module

# Step 5: Open a Pull Request on GitHub → merge into main
```

> **Commit Convention:** Use prefixes like `feat:`, `fix:`, `docs:`, `refactor:` for a clean and readable commit history.

---

## 🤝 Shared Responsibilities

| Task | Wajiha | Faiqa | Ayesha |
|------|:------:|:-----:|:------:|
| Final Integration Testing | ✅ | ✅ | ✅ |
| UI/UX Consistency Review | ✅ | ✅ | ✅ |
| Project Report Writing | ✅ | ✅ | ✅ |
| ERD & Database Diagram | ✅ | ✅ | ✅ |
| GitHub Repository Management | ✅ | ✅ | ✅ |
| Viva & Presentation Preparation | ✅ | ✅ | ✅ |

---

## 📖 Learning Outcomes

Through this project, the team gained hands-on experience in:

- ✦ **Full-Stack Mobile Development** — building a complete app from UI to database
- ✦ **REST API Design** — creating clean, documented, and testable endpoints
- ✦ **NoSQL Database Modelling** — designing efficient MongoDB schemas
- ✦ **Modular Architecture** — writing maintainable, feature-separated code
- ✦ **Team Collaboration** — working with Git branches, pull requests, and code reviews
- ✦ **Agile Practices** — iterative development and structured task division

---

## 🚀 Future Roadmap

| Feature | Priority | Description |
|---------|:--------:|-------------|
| 🗺️ Live Order Tracking | High | Real-time GPS map tracking for active deliveries |
| 🔔 Push Notifications | High | Order status updates via Firebase Cloud Messaging |
| 💳 Online Payment Gateway | High | Integration with Stripe or JazzCash |
| 🛡️ Admin Dashboard | Medium | Web panel for managing restaurants, users & orders |
| 🤖 AI Food Recommendations | Medium | Personalised suggestions powered by ML |
| 🌙 Dark Mode UI | Low | System-based dark/light theme toggle |
| 🌍 Multi-language Support | Low | Urdu and English language toggle |

---

## 👩‍🎓 Contributors

<table align="center">
<tr>
<td align="center">
<b>Wajiha</b><br/>
<sub>🔐 Authentication & User Management</sub><br/>
<sub>Frontend · Backend · Database</sub>
</td>
<td align="center">
<b>Faiqa</b><br/>
<sub>🍕 Restaurants, Menu & Reviews</sub><br/>
<sub>Frontend · Backend · Database</sub>
</td>
<td align="center">
<b>Ayesha</b><br/>
<sub>🛒 Cart, Orders, Payments & Delivery</sub><br/>
<sub>Frontend · Backend · Database</sub>
</td>
</tr>
</table>

---

<div align="center">

**⭐ If you found this project helpful, please give it a star!**

<br/>

*Developed for educational purposes as a University Final Year Project.*

</div>
