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
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final margin = screenWidth * 0.025;
        final padding = screenWidth * 0.04;
        final imageSize = screenWidth * 0.18;
        final spacing = screenWidth * 0.035;
        final fontSize = screenWidth * 0.038;
        final priceSize = screenWidth * 0.04;
        final iconSize = screenWidth * 0.045;
        
        return Container(
          margin: EdgeInsets.only(bottom: margin.clamp(12, 20)),
          padding: EdgeInsets.all(padding.clamp(12, 18)),
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
                    width: imageSize.clamp(70, 90),
                    height: imageSize.clamp(70, 90),
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
                          child: Icon(Icons.image_outlined, color: Colors.grey[600], size: imageSize.clamp(30, 40)),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: spacing.clamp(12, 18)),
                  
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cartItem.productName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: fontSize.clamp(14, 17),
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
                              fontSize: (fontSize * 0.9).clamp(12, 15),
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                        ],
                        
                        SizedBox(height: 8),
                        
                        Text(
                          '\$${cartItem.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: priceSize.clamp(14, 17),
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
                        size: iconSize.clamp(18, 22),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: spacing.clamp(12, 18)),
              
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
                            padding: EdgeInsets.all((screenWidth * 0.02).clamp(8, 12)),
                            child: Icon(
                              Icons.remove,
                              size: (iconSize * 0.8).clamp(14, 18),
                              color: cartItem.quantity > 1 ? Colors.grey[800] : Colors.grey[400],
                            ),
                          ),
                        ),
                        
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: (screenWidth * 0.035).clamp(12, 18),
                            vertical: (screenWidth * 0.02).clamp(8, 12),
                          ),
                          child: Text(
                            '${cartItem.quantity}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: priceSize.clamp(14, 17),
                              color: Colors.grey[800],
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                        ),
                        
                        GestureDetector(
                          onTap: () => onQuantityChanged(cartItem.quantity + 1),
                          child: Container(
                            padding: EdgeInsets.all((screenWidth * 0.02).clamp(8, 12)),
                            child: Icon(
                              Icons.add,
                              size: (iconSize * 0.8).clamp(14, 18),
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
                      fontSize: (priceSize * 1.1).clamp(16, 20),
                      color: Colors.grey[900],
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}