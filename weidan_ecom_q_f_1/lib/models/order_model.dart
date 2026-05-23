class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double? originalPrice;
  final String? imageUrl;
  final String? size;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.originalPrice,
    this.imageUrl,
    this.size,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: map['originalPrice'] != null
          ? (map['originalPrice'] as num).toDouble()
          : null,
      imageUrl: map['imageUrl'],
      size: map['size'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      if (originalPrice != null) 'originalPrice': originalPrice,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'size': size,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final String status;
  final DateTime date;
  final double totalPrice;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.status,
    required this.date,
    required this.totalPrice,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item))
              .toList() ??
          [],
      status: map['status'] ?? 'pending',
      date: DateTime.parse(map['date']),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'status': status,
      'date': date.toIso8601String(),
      'totalPrice': totalPrice,
    };
  }
}