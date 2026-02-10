class CartItem {
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
  int quantity;
  final String? size;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.size,
  });

  double get totalPrice => price * quantity;
}