import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../services/cart_provider.dart';

// ── Palette ──────────────────────────────────────────────────────────────────────
const _kNeon  = Color(0xFFB8FF57);
const _kDark  = Color(0xFF0D0D0D);
const _kText  = Color(0xFF1A1A1A);
const _kMuted = Color(0xFF9A9A9A);
const _kRed   = Color(0xFFFF5252);

const _productImageMap = {
  '2.0 air shuttle':        'assets/products_image/2.0 Air Shuttle.jpg',
  'flight wing 350':        'assets/products_image/Flight Wing 350.jpg',
  'kinesiology tape':       'assets/products_image/kinesiology Tape.jpg',
  'mult 2 feather shuttle': 'assets/products_image/MULT 2 Feather shuttle.jpg',
  'weidan t-shirt':         'assets/products_image/Weidan T-Shirt.jpg',
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
  late final AnimationController _pressCtrl;
  late final AnimationController _heartCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double>   _pressAnim;
  late final Animation<double>   _heartAnim;
  late final Animation<double>   _fadeAnim;

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

  Widget _placeholder() => Container(
        color: const Color(0xFFF0F1F3),
        child: const Center(
          child: Icon(Icons.image_outlined, color: Color(0xFFCCCCCC), size: 32),
        ),
      );

  Widget _buildImage() {
    final assetPath = _resolveAsset(widget.product.name);
    if (assetPath != null) {
      return Image.asset(assetPath, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder());
    }
    if (widget.product.imageUrl.startsWith('assets/')) {
      return Image.asset(widget.product.imageUrl, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder());
    }
    if (widget.product.imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.product.imageUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

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
          // LayoutBuilder gives us the exact card width × height the grid
          // assigned, so every size decision is proportional — never fixed.
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardW = constraints.maxWidth;
              final cardH = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : cardW / 0.65; // fallback aspect ratio

              // ── Derived sizes — all proportional to card dimensions ──────
              // Image takes ~58 % of card height
              final imageH      = cardH * 0.58;

              // Padding scales with card width, min 6 max 12
              final pad         = (cardW * 0.06).clamp(6.0, 12.0);

              // Font sizes scale with card width
              final nameFs      = (cardW * 0.082).clamp(10.0, 14.0);
              final priceFs     = (cardW * 0.090).clamp(11.0, 15.0);
              final origPriceFs = (cardW * 0.068).clamp(9.0, 12.0);
              final badgeFs     = (cardW * 0.060).clamp(7.5, 10.0);

              // Cart button scales with card width
              final btnSize     = (cardW * 0.22).clamp(24.0, 36.0);
              final btnIconSize = btnSize * 0.52;
              final btnRadius   = btnSize * 0.30;

              // Wishlist button
              final wishSize    = (cardW * 0.22).clamp(24.0, 34.0);
              final wishIconSize = wishSize * 0.47;

              // Badge overlay sizes
              final badgePadH   = (cardW * 0.040).clamp(5.0, 8.0);
              final badgePadV   = (cardW * 0.020).clamp(2.5, 4.0);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                      (cardW * 0.09).clamp(12.0, 20.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16, spreadRadius: -2,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4, offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Image ───────────────────────────────────────────────
                    SizedBox(
                      width: cardW,
                      height: imageH,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(
                                    (cardW * 0.09).clamp(12.0, 20.0))),
                            child: SizedBox.expand(child: _buildImage()),
                          ),

                          // Out-of-stock overlay
                          if (isOutOfStock)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(
                                        (cardW * 0.09).clamp(12.0, 20.0))),
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  child: Center(
                                    child: Text(
                                      'Out of Stock',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: badgeFs,
                                        fontFamily: 'SF Pro Display',
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Low-stock badge
                          if (isLowStock)
                            Positioned(
                              top: pad * 0.7,
                              left: pad * 0.7,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: badgePadH, vertical: badgePadV),
                                decoration: BoxDecoration(
                                  color: _kRed,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  'LOW STOCK',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: badgeFs * 0.85,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'SF Pro Display',
                                    letterSpacing: 0.7,
                                  ),
                                ),
                              ),
                            ),

                          // Discount badge
                          if (hasDiscount && !isOutOfStock)
                            Positioned(
                              top: pad * 0.7,
                              left: pad * 0.7,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: badgePadH, vertical: badgePadV),
                                decoration: BoxDecoration(
                                  color: _kNeon,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '-${(((widget.product.originalPrice! - widget.product.price) / widget.product.originalPrice!) * 100).round()}%',
                                  style: TextStyle(
                                    color: _kDark,
                                    fontSize: badgeFs,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'SF Pro Display',
                                  ),
                                ),
                              ),
                            ),

                          // Wishlist button
                          Positioned(
                            top: pad * 0.6,
                            right: pad * 0.6,
                            child: GestureDetector(
                              onTap: _toggleWishlist,
                              child: Container(
                                width: wishSize,
                                height: wishSize,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.10),
                                      blurRadius: 6, offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ScaleTransition(
                                  scale: _heartAnim,
                                  child: Icon(
                                    _wishlisted
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: wishIconSize,
                                    color: _wishlisted ? _kRed : _kMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Info area ────────────────────────────────────────────
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(pad, pad * 0.7, pad, pad * 0.8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [

                            // Product name — 2 lines max
                            Flexible(
                              child: Text(
                                widget.product.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: nameFs,
                                  color: _kText,
                                  fontFamily: 'SF Pro Display',
                                  height: 1.25,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Price row + cart button
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
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: priceFs,
                                          color: _kText,
                                          fontFamily: 'SF Pro Display',
                                          height: 1.1,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (hasDiscount)
                                        Text(
                                          '₹${widget.product.originalPrice!.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: origPriceFs,
                                            color: _kMuted,
                                            fontFamily: 'SF Pro Display',
                                            decoration: TextDecoration.lineThrough,
                                            decorationColor: _kMuted,
                                            height: 1.2,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),

                                SizedBox(width: pad * 0.5),

                                // Add-to-cart button
                                GestureDetector(
                                  onTap: isOutOfStock ? null : _addToCart,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: btnSize,
                                    height: btnSize,
                                    decoration: BoxDecoration(
                                      color: isOutOfStock
                                          ? const Color(0xFFE0E0E0)
                                          : _kNeon,
                                      borderRadius:
                                          BorderRadius.circular(btnRadius),
                                      boxShadow: isOutOfStock
                                          ? []
                                          : [
                                              BoxShadow(
                                                color: _kNeon.withValues(
                                                    alpha: 0.40),
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
                                      size: btnIconSize,
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
              );
            },
          ),
        ),
      ),
    );
  }
}
