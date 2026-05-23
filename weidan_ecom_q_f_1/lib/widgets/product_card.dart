import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../services/cart_provider.dart';

// ── Palette (mirrors app-wide tokens) ───────────────────────────────────────────
const _kNeon    = Color(0xFFB8FF57);
const _kDark    = Color(0xFF0D0D0D);
const _kText    = Color(0xFF1A1A1A);
const _kMuted   = Color(0xFF9A9A9A);
const _kRed     = Color(0xFFFF5252);

const _productImageMap = {
  '2.0 air shuttle':       'assets/products_image/2.0 Air Shuttle.jpg',
  'flight wing 350':       'assets/products_image/Flight Wing 350.jpg',
  'kinesiology tape':      'assets/products_image/kinesiology Tape.jpg',
  'mult 2 feather shuttle':'assets/products_image/MULT 2 Feather shuttle.jpg',
  'weidan t-shirt':        'assets/products_image/Weidan T-Shirt.jpg',
};

String? _resolveAsset(String name) =>
    _productImageMap[name.trim().toLowerCase()];

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with TickerProviderStateMixin {
  // Press-down scale
  late AnimationController _pressCtrl;
  late Animation<double>   _pressAnim;

  // Wishlist heart bounce
  late AnimationController _heartCtrl;
  late Animation<double>   _heartAnim;

  // Entrance fade-in
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  bool _wishlisted = false;

  @override
  void initState() {
    super.initState();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;
    _pressAnim = _pressCtrl;

    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0),  weight: 60),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeOutBack));

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _heartCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Image builder ────────────────────────────────────────────────────────────
  Widget _buildImage() {
    final assetPath = _resolveAsset(widget.product.name);
    final placeholder = Container(
      color: const Color(0xFFF0F1F3),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Color(0xFFCCCCCC), size: 36),
      ),
    );
    if (assetPath != null) {
      return Image.asset(assetPath, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder);
    }
    if (widget.product.imageUrl.startsWith('assets/')) {
      return Image.asset(widget.product.imageUrl, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder);
    }
    if (widget.product.imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.product.imageUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      );
    }
    return placeholder;
  }

  // ── Add to cart ──────────────────────────────────────────────────────────────
  void _addToCart() {
    HapticFeedback.lightImpact();
    Provider.of<CartProvider>(context, listen: false).addItem(
      widget.product.id,
      widget.product.name,
      widget.product.price,
      widget.product.imageUrl,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: _kDark,
      ),
    );
  }

  // ── Wishlist toggle ──────────────────────────────────────────────────────────
  void _toggleWishlist() {
    HapticFeedback.lightImpact();
    setState(() => _wishlisted = !_wishlisted);
    _heartCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isLowStock   = widget.product.stock > 0 && widget.product.stock <= 5;
    final isOutOfStock = widget.product.stock == 0;
    final hasDiscount  = widget.product.originalPrice != null &&
        widget.product.originalPrice! > widget.product.price;

    return FadeTransition(
      opacity: _fadeAnim,
      child: GestureDetector(
        onTapDown:   (_) => _pressCtrl.reverse(),
        onTapUp:     (_) { _pressCtrl.forward(); widget.onTap(); },
        onTapCancel: ()  => _pressCtrl.forward(),
        child: ScaleTransition(
          scale: _pressAnim,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                // Ambient shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  spreadRadius: -2,
                  offset: const Offset(0, 6),
                ),
                // Contact shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Image area ───────────────────────────────────────────────
                Expanded(
                  flex: 6,
                  child: Stack(
                    children: [
                      // Photo
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: _buildImage(),
                        ),
                      ),

                      // Out-of-stock overlay — full card radius
                      if (isOutOfStock)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.45),
                              child: const Center(
                                child: Text(
                                  'Out of Stock',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    fontFamily: 'SF Pro Display',
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Low stock badge
                      if (isLowStock)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _kRed,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'LOW STOCK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'SF Pro Display',
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),

                      // Discount badge
                      if (hasDiscount && !isOutOfStock)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: _kNeon,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '-${(((widget.product.originalPrice! - widget.product.price) / widget.product.originalPrice!) * 100).round()}%',
                              style: const TextStyle(
                                color: _kDark,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ),
                        ),

                      // Wishlist button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _toggleWishlist,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ScaleTransition(
                              scale: _heartAnim,
                              child: Icon(
                                _wishlisted
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 16,
                                color: _wishlisted ? _kRed : _kMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Info area ────────────────────────────────────────────────
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        // Product name
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: _kText,
                            fontFamily: 'SF Pro Display',
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Price row + add-to-cart
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Price block
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '₹${widget.product.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: _kText,
                                      fontFamily: 'SF Pro Display',
                                    ),
                                  ),
                                  if (hasDiscount)
                                    Text(
                                      '₹${widget.product.originalPrice!.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: _kMuted,
                                        fontFamily: 'SF Pro Display',
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: _kMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Add-to-cart button — neon green accent
                            GestureDetector(
                              onTap: isOutOfStock ? null : _addToCart,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: isOutOfStock
                                      ? const Color(0xFFE0E0E0)
                                      : _kNeon,
                                  borderRadius: BorderRadius.circular(9),
                                  boxShadow: isOutOfStock
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: _kNeon.withValues(alpha: 0.40),
                                            blurRadius: 8,
                                            spreadRadius: -2,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Icon(
                                  Icons.add_rounded,
                                  color: isOutOfStock
                                      ? const Color(0xFFAAAAAA)
                                      : _kDark,
                                  size: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
