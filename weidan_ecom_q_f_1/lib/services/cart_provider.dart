import 'package:flutter/foundation.dart';
import '../models/cart_model.dart';

// Valid coupon definitions
const _kCoupons = {
  'WEIDAN10': 0.10,
  'SPORT20':  0.20,
  'FIRST15':  0.15,
};

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  String? _couponCode;
  double _couponRate = 0.0;

  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  String? get appliedCoupon => _couponCode;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get totalDiscount {
    return _items.fold(0.0, (sum, item) => sum + item.totalSavings);
  }

  double get deliveryFee {
    if (_items.isEmpty) return 0;
    return totalAmount >= 499 ? 0 : 49;
  }

  double get tax => totalAmount * 0.05;

  double get couponDiscount => totalAmount * _couponRate;

  double get grandTotal =>
      totalAmount + deliveryFee + tax - couponDiscount;

  /// Returns null on success, or an error message string on failure.
  String? applyCoupon(String code) {
    final rate = _kCoupons[code.trim().toUpperCase()];
    if (rate == null) return 'Invalid coupon code';
    if (_couponCode == code.trim().toUpperCase()) return 'Coupon already applied';
    _couponCode = code.trim().toUpperCase();
    _couponRate = rate;
    notifyListeners();
    return null;
  }

  void removeCoupon() {
    _couponCode = null;
    _couponRate = 0.0;
    notifyListeners();
  }

  void addItem(
    String productId,
    String productName,
    double price,
    String imageUrl, {
    String? size,
    double? originalPrice,
    double rating = 4.5,
  }) {
    final existingIndex = _items.indexWhere(
      (item) => item.productId == productId && item.size == size,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        productId: productId,
        productName: productName,
        price: price,
        originalPrice: originalPrice,
        rating: rating,
        imageUrl: imageUrl,
        size: size,
      ));
    }
    notifyListeners();
  }

  void removeItem(String productId, {String? size}) {
    _items.removeWhere((item) => item.productId == productId && item.size == size);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity, {String? size}) {
    final index = _items.indexWhere(
      (item) => item.productId == productId && item.size == size,
    );
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}