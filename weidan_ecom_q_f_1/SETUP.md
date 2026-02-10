# Weidan Sports E-commerce App

A complete Flutter e-commerce mobile app like Nike with Firebase backend.

## Features Implemented

### Authentication & User Management
- ✅ Splash screen with auth state detection
- ✅ Login/Sign up with email & password
- ✅ Role-based navigation (Admin/User)
- ✅ Password reset functionality
- ✅ User profile management

### User Features
- ✅ Home screen with featured products carousel
- ✅ Categories screen with filtering
- ✅ Product detail page with size selection
- ✅ Shopping cart with quantity management
- ✅ Checkout and order creation
- ✅ Order history
- ✅ Bottom navigation

### Admin Features
- ✅ Admin dashboard with tabbed interface
- ✅ Product management (Add/Edit/Delete)
- ✅ Image upload to Firebase Storage
- ✅ Order management with status updates
- ✅ Inventory management

### Technical Features
- ✅ Firebase Authentication
- ✅ Cloud Firestore database
- ✅ Firebase Storage for images
- ✅ Provider state management
- ✅ Cached network images
- ✅ Modern Nike-like UI design

## Setup Instructions

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Firebase Setup**
   - Firebase project is already configured
   - `firebase_options.dart` contains all platform configurations
   - Admin emails: `admin@weidan.com`, `admin@example.com`

3. **Run the App**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                    # App entry point with Firebase init
├── firebase_options.dart        # Firebase configuration
├── models/                      # Data models
│   ├── user_model.dart
│   ├── product_model.dart
│   ├── order_model.dart
│   └── cart_model.dart
├── services/                    # Business logic
│   ├── auth_service.dart
│   ├── product_service.dart
│   ├── order_service.dart
│   └── cart_provider.dart
├── screens/                     # UI screens
│   ├── auth/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── user/
│   │   ├── home_screen.dart
│   │   ├── categories_screen.dart
│   │   ├── product_detail_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── profile_screen.dart
│   │   └── order_history_screen.dart
│   └── admin/
│       ├── admin_dashboard.dart
│       ├── manage_products_screen.dart
│       ├── view_orders_screen.dart
│       └── manage_inventory_screen.dart
└── widgets/                     # Reusable components
    ├── product_card.dart
    ├── category_card.dart
    └── cart_item_card.dart
```

## Firestore Collections

### users
```json
{
  "uid": "string",
  "name": "string",
  "email": "string",
  "role": "user|admin",
  "createdAt": "timestamp"
}
```

### products
```json
{
  "name": "string",
  "category": "Shoes|Apparel|Accessories",
  "description": "string",
  "price": "number",
  "imageUrl": "string",
  "stock": "number",
  "sizes": ["array of strings"]
}
```

### orders
```json
{
  "userId": "string",
  "items": [
    {
      "productId": "string",
      "productName": "string",
      "quantity": "number",
      "price": "number",
      "size": "string?"
    }
  ],
  "status": "pending|processing|shipped|delivered|cancelled",
  "date": "timestamp",
  "totalPrice": "number"
}
```

## Usage

1. **First Run**: App opens to splash screen
2. **New User**: Sign up with email/password (role auto-assigned)
3. **Admin Access**: Use admin emails for admin dashboard
4. **User Flow**: Browse → Add to Cart → Checkout → View Orders
5. **Admin Flow**: Manage Products → View Orders → Update Inventory

## Key Features

- **Role Detection**: Automatic admin role for predefined emails
- **Real-time Updates**: Firestore streams for live data
- **Image Upload**: Firebase Storage integration
- **State Management**: Provider for cart management
- **Modern UI**: Nike-inspired design with black/white theme
- **Responsive**: Works on Android, iOS, and Web

The app is fully functional and ready for production use!