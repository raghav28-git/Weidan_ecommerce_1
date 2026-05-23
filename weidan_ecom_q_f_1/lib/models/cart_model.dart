class CartItem {
  final String productId;
  final String productName;
  final double price;
  final double? originalPrice;
  final double rating;
  final String imageUrl;
  int quantity;
  final String? size;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.originalPrice,
    this.rating = 4.5,
    required this.imageUrl,
    this.quantity = 1,
    this.size,
  });

  double get totalPrice => price * quantity;

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercent => hasDiscount
      ? (((originalPrice! - price) / originalPrice!) * 100).round()
      : 0;

  double get totalSavings => hasDiscount ? (originalPrice! - price) * quantity : 0;
}