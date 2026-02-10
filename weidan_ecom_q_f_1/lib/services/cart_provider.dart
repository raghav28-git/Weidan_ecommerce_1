import 'package:flutter/foundation.dart';
import '../models/cart_model.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(String productId, String productName, double price, String imageUrl, {String? size}) {
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