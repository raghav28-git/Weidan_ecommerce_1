import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cart_model.dart';

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  CartItemCard({
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: cartItem.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey[800],
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.image_outlined, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: 16),
              
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.productName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.grey[900],
                        fontFamily: 'SF Pro Display',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (cartItem.size != null) ...[
                      SizedBox(height: 4),
                      Text(
                        'Size: ${cartItem.size}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ],
                    
                    SizedBox(height: 8),
                    
                    Text(
                      '\$${cartItem.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.grey[900],
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ],
                ),
              ),
              
              // Remove Button
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.grey[700],
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Quantity Controls and Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (cartItem.quantity > 1) {
                          onQuantityChanged(cartItem.quantity - 1);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.remove,
                          size: 16,
                          color: cartItem.quantity > 1 ? Colors.grey[800] : Colors.grey[400],
                        ),
                      ),
                    ),
                    
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        '${cartItem.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.grey[800],
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                    
                    GestureDetector(
                      onTap: () => onQuantityChanged(cartItem.quantity + 1),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Total Price
              Text(
                '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.grey[900],
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}