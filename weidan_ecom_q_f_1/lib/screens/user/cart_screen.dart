import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/cart_provider.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../widgets/cart_item_card.dart';
import 'home_screen.dart';

class CartScreen extends StatelessWidget {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          'Cart',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add items to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Shop Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
                ),
                child: Row(
                  children: [
                    Text(
                      '${cart.itemCount} ${cart.itemCount == 1 ? 'Item' : 'Items'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    return CartItemCard(
                      cartItem: cart.items[index],
                      onQuantityChanged: (quantity) {
                        cart.updateQuantity(
                          cart.items[index].productId,
                          quantity,
                          size: cart.items[index].size,
                        );
                      },
                      onRemove: () {
                        cart.removeItem(
                          cart.items[index].productId,
                          size: cart.items[index].size,
                        );
                      },
                    );
                  },
                ),
              ),
              
              // Cart Summary
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                        Text(
                          '₹${cart.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _checkout(context, cart),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _checkout(BuildContext context, CartProvider cart) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      List<OrderItem> orderItems = cart.items.map((cartItem) {
        return OrderItem(
          productId: cartItem.productId,
          productName: cartItem.productName,
          quantity: cartItem.quantity,
          price: cartItem.price,
          size: cartItem.size,
        );
      }).toList();

      OrderModel order = OrderModel(
        id: '',
        userId: user.uid,
        items: orderItems,
        status: 'delivered',
        date: DateTime.now(),
        totalPrice: cart.totalAmount,
      );

      await _orderService.createOrder(order);
      
      // Send notification
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': user.uid,
        'title': 'Order Placed Successfully!',
        'message': 'Your order has been placed and is being processed.',
        'timestamp': Timestamp.now(),
      });
      
      cart.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order placed successfully!',
            style: TextStyle(fontFamily: 'SF Pro Display'),
          ),
          backgroundColor: Colors.black,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error placing order: ${e.toString()}',
            style: TextStyle(fontFamily: 'SF Pro Display'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}