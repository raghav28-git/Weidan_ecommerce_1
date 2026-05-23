import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<ProductModel>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<ProductModel?> getProduct(String productId) async {
    DocumentSnapshot doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists) {
      return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<String> uploadImage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref().child('products').child(fileName);
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _firestore.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  Future<void> updateStock(String productId, int newStock) async {
    await _firestore.collection('products').doc(productId).update({'stock': newStock});
  }

  Future<void> seedProducts() async {
    final existing = await _firestore.collection('products').limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final products = [
      ProductModel(
        id: '',
        name: '2.0 Air Shuttle',
        category: 'Shuttle',
        description: 'High-performance featherless shuttlecock designed for consistent flight and durability.',
        price: 450.00,
        imageUrl: 'assets/products_image/2.0 Air Shuttle.jpg',
        stock: 50,
        sizes: [],
      ),
      ProductModel(
        id: '',
        name: 'Flight Wing 350',
        category: 'Shuttle',
        description: 'Premium badminton shuttlecock with stable trajectory and excellent speed control.',
        price: 380.00,
        imageUrl: 'assets/products_image/Flight Wing 350.jpg',
        stock: 40,
        sizes: [],
      ),
      ProductModel(
        id: '',
        name: 'Kinesiology Tape',
        category: 'Tape',
        description: 'Elastic sports tape for muscle support, pain relief, and injury prevention during play.',
        price: 299.00,
        imageUrl: 'assets/products_image/kinesiology Tape.jpg',
        stock: 100,
        sizes: [],
      ),
      ProductModel(
        id: '',
        name: 'MULT 2 Feather Shuttle',
        category: 'Shuttle',
        description: 'Natural feather shuttlecock offering superior flight accuracy for competitive play.',
        price: 620.00,
        imageUrl: 'assets/products_image/MULT 2 Feather shuttle.jpg',
        stock: 30,
        sizes: [],
      ),
      ProductModel(
        id: '',
        name: 'Weidan T-Shirt',
        category: 'T-Shirt',
        description: 'Lightweight breathable sports T-shirt designed for comfort and performance on the court.',
        price: 799.00,
        imageUrl: 'assets/products_image/Weidan T-Shirt.jpg',
        stock: 60,
        sizes: ['S', 'M', 'L', 'XL'],
      ),
    ];

    for (final product in products) {
      await _firestore.collection('products').add(product.toMap());
    }
  }

  Future<void> syncProductImages() async {
    final imageMap = {
      '2.0 Air Shuttle': 'assets/products_image/2.0 Air Shuttle.jpg',
      'Flight Wing 350': 'assets/products_image/Flight Wing 350.jpg',
      'Kinesiology Tape': 'assets/products_image/kinesiology Tape.jpg',
      'MULT 2 Feather Shuttle': 'assets/products_image/MULT 2 Feather shuttle.jpg',
      'Weidan T-Shirt': 'assets/products_image/Weidan T-Shirt.jpg',
    };

    final snapshot = await _firestore.collection('products').get();
    for (final doc in snapshot.docs) {
      final name = doc.data()['name'] as String? ?? '';
      final currentUrl = doc.data()['imageUrl'] as String? ?? '';
      final assetPath = imageMap[name];
      if (assetPath != null && currentUrl != assetPath) {
        await doc.reference.update({'imageUrl': assetPath});
      }
    }
  }
}