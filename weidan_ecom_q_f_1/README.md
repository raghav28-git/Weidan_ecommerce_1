# Weidan Sports — E-Commerce App

A Flutter mobile app for **Weidan Sports**, a badminton and sports gear store. Built with Firebase for backend services.

---

## What It Does

- Browse and buy sports products (T-shirts, shuttlecocks, tapes, socks, and more)
- Filter products by category, price range, and sort order
- Add items to cart and place orders
- Track order history and get notifications
- Admin panel to manage products, orders, and inventory

---

## Screens

**User**

- Splash, Onboarding, Get Started
- Login, Sign Up, Forgot Password, OTP Verification
- Home, Categories, Product Detail
- Cart, Payment, Order History
- Profile, Notifications, Help, About

**Admin**

- Dashboard with Products, Orders, and Inventory management

---

## Tech Stack

| Layer            | Technology                               |
| ---------------- | ---------------------------------------- |
| Framework        | Flutter (Dart)                           |
| Auth             | Firebase Authentication + Google Sign-In |
| Database         | Cloud Firestore                          |
| Storage          | Firebase Storage                         |
| State Management | Provider                                 |
| UI               | Material Design + SF Pro Display font    |

---

## Project Structure

```
lib/
├── models/        # Data models (Product, Cart, Order, User)
├── screens/
│   ├── auth/      # Login, signup, onboarding screens
│   ├── user/      # Home, cart, profile, etc.
│   └── admin/     # Admin dashboard screens
├── services/      # Firebase auth, product, order, cart logic
├── widgets/       # Reusable UI components
├── constants/     # App-wide constants
└── utils/         # Responsive layout helpers
```
