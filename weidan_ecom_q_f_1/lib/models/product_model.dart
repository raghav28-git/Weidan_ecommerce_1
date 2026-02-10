class ProductModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;
  final List<String> sizes;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    this.sizes = const [],
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      stock: map['stock'] ?? 0,
      sizes: List<String>.from(map['sizes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,
      'sizes': sizes,
    };
  }
}