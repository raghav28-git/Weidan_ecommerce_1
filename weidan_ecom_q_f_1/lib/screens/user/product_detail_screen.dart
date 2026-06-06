import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../utils/responsive.dart';
import '../../models/order_model.dart';
import '../../services/cart_provider.dart';
import 'payment_screen.dart';

const _productImageMap = {
  '2.0 air shuttle': 'assets/products_image/2.0 Air Shuttle.jpg',
  'flight wing 350': 'assets/products_image/Flight Wing 350.jpg',
  'kinesiology tape': 'assets/products_image/kinesiology Tape.jpg',
  'mult 2 feather shuttle': 'assets/products_image/MULT 2 Feather shuttle.jpg',
  'weidan t-shirt': 'assets/products_image/Weidan T-Shirt.jpg',
};

String? _resolveAsset(String name) => _productImageMap[name.trim().toLowerCase()];

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  bool _isWishlisted = false;
  int _currentImageIndex = 0;
  final Set<int> _expandedSections = {0};
  final Set<int> _helpfulTapped = {};
  final Set<String> _relatedWishlisted = {};
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get _images {
    final asset = _resolveAsset(widget.product.name);
    if (asset != null) return [asset];
    if (widget.product.imageUrl.isNotEmpty) return [widget.product.imageUrl];
    return [];
  }

  Widget _buildImage(String src) {
    final isAsset = src.startsWith('assets/');
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: isAsset
          ? Image.asset(src, fit: BoxFit.contain, width: double.infinity,
              errorBuilder: (_, __, ___) => _imagePlaceholder())
          : CachedNetworkImage(
              imageUrl: src,
              fit: BoxFit.contain,
              width: double.infinity,
              placeholder: (_, __) => _imagePlaceholder(),
              errorWidget: (_, __, ___) => _imagePlaceholder(),
            ),
    );
  }

  Widget _imagePlaceholder() => Container(
        color: const Color(0xFFF5F5F5),
        child: const Icon(Icons.image_outlined, color: Color(0xFFBDBDBD), size: 60),
      );

  @override
  Widget build(BuildContext context) {
    final images  = _images;
    final screenH = MediaQuery.of(context).size.height;
    final inStock = widget.product.stock > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildImageSection(images, screenH)),
                SliverToBoxAdapter(child: _buildInfoCard(inStock)),
                // Clearance adapts to nav bar height + safe area
                SliverToBoxAdapter(
                  child: SizedBox(height: Responsive.navBarClearance(context) + (Responsive.isSmallPhone(context) ? 40 : 80)),
                ),
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: Responsive.hPadding(context),
              child: _floatBtn(Icons.arrow_back_ios_new_rounded,
                  () => Navigator.pop(context)),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomCTA(inStock),
            ),
          ],
        ),
      ),
    );
  }

  // ── Image carousel ────────────────────────────────────────────────────────
  Widget _buildImageSection(List<String> images, double screenH) {
    final mq          = MediaQuery.of(context);
    final isLandscape = mq.orientation == Orientation.landscape;
    final isSmall     = Responsive.isSmallPhone(context);
    final hPad        = Responsive.hPadding(context);
    final imageH      = isLandscape
        ? (screenH * 0.55).clamp(140.0, 300.0)
        : (screenH * 0.40).clamp(isSmall ? 180.0 : 200.0, 380.0);
    return Container(
      height: imageH,
      margin: EdgeInsets.fromLTRB(hPad, hPad, hPad, 0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // ── PageView swiper ──────────────────────────────────────
            if (images.isEmpty)
              SizedBox.expand(child: _imagePlaceholder())
            else
              PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (i) => setState(() => _currentImageIndex = i),
                itemBuilder: (_, i) => _buildImage(images[i]),
              ),

            // ── Wishlist + Share overlay (bottom-right) ──────────────
            Positioned(
              right: 14,
              bottom: isSmall ? 44 : 56,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _overlayIconBtn(
                    icon: _isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: _isWishlisted ? Colors.redAccent : const Color(0xFF424242),
                    onTap: () => setState(() => _isWishlisted = !_isWishlisted),
                  ),
                  const SizedBox(height: 10),
                  _overlayIconBtn(
                    icon: Icons.share_outlined,
                    color: const Color(0xFF424242),
                    onTap: _onShare,
                  ),
                ],
              ),
            ),

            // ── Dot indicators ───────────────────────────────────────
            if (images.length > 1)
              Positioned(
                bottom: 18,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) {
                    final active = i == _currentImageIndex;
                    return GestureDetector(
                      onTap: () => _pageController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 22 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF111111)
                              : const Color(0xFF111111).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ),

            // ── Bottom fade gradient ─────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: isSmall ? 48 : 64,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFFF5F5F5).withOpacity(0.95),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overlayIconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isSmall = Responsive.isSmallPhone(context);
    final size    = isSmall ? 36.0 : 40.0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: isSmall ? 17 : 19, color: color),
      ),
    );
  }

  // ── Info card ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard(bool inStock) {
    final p           = widget.product;
    final hasDiscount = p.originalPrice != null && p.originalPrice! > p.price;
    final discountPct = hasDiscount
        ? (((p.originalPrice! - p.price) / p.originalPrice!) * 100).round()
        : 0;
    final hPad   = Responsive.hPadding(context);
    final isSmall = Responsive.isSmallPhone(context);
    final sw      = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.fromLTRB(hPad * 0.7, 16, hPad * 0.7, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(hPad, isSmall ? 14 : 20, hPad, isSmall ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          // ── Category badge + stock badge ──────────────────────────────
          Row(
            children: [
              _badge(p.category.toUpperCase(),
                  const Color(0xFFF0F0F0), Colors.black54),
              const Spacer(),
              _badge(
                inStock ? '● IN STOCK' : '● OUT OF STOCK',
                inStock ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                inStock ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
              ),
            ],
          ),

          SizedBox(height: isSmall ? 10 : 14),

          // ── Product name ──────────────────────────────────────────────
          Text(
            p.name,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: (sw * 0.065).clamp(20.0, 28.0),
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
              color: const Color(0xFF0D0D0D),
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),

          SizedBox(height: isSmall ? 12 : 18),

          // ── Price block ───────────────────────────────────────────────
          _buildPriceBlock(p.price, p.originalPrice, hasDiscount, discountPct),

          SizedBox(height: isSmall ? 10 : 16),

          // ── Rating + social proof row ─────────────────────────────────
          _buildSocialRow(p.soldCount),

          SizedBox(height: isSmall ? 16 : 24),
          _divider(),
          SizedBox(height: isSmall ? 14 : 20),

          // ── Size selector ─────────────────────────────────────────────
          if (widget.product.sizes.isNotEmpty) ...[
            Row(
              children: [
                const Text('Select Size',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color(0xFF111111))),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: const Text('Size Guide →',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF757575),
                          fontFamily: 'Poppins')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.product.sizes.map((size) {
                final selected = _selectedSize == size;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSize = size),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 16 : 22,
                      vertical:   isSmall ? 8  : 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF111111) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF111111)
                            : const Color(0xFFE0E0E0),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      size,
                      style: TextStyle(
                        fontSize: isSmall ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: selected ? Colors.white : const Color(0xFF424242),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: isSmall ? 14 : 20),
            _divider(),
            SizedBox(height: isSmall ? 14 : 20),
          ],

          // ── Accordion sections ──────────────────────────────────────────
          _buildAccordionBlock(p.description, p.category),

          SizedBox(height: isSmall ? 14 : 20),
          _divider(),
          SizedBox(height: isSmall ? 14 : 20),

          // ── Product features ──────────────────────────────────────────
          _buildFeaturesSection(p.category),

          SizedBox(height: isSmall ? 14 : 20),
          _divider(),
          SizedBox(height: isSmall ? 14 : 20),

          // ── Delivery & Offers card ────────────────────────────────────
          _buildDeliverySection(widget.product.stock),

          SizedBox(height: isSmall ? 14 : 20),
          _divider(),
          SizedBox(height: isSmall ? 14 : 20),

          // ── Customer reviews ──────────────────────────────────────────
          _buildReviewsSection(),

          SizedBox(height: isSmall ? 14 : 20),
          _divider(),
          SizedBox(height: isSmall ? 14 : 20),

          // ── Related products ─────────────────────────────────────────
          _buildRelatedProductsBlock(),
        ],
      ),
    ),
    );
  }

  // ── Price block ───────────────────────────────────────────────────────────
  Widget _buildPriceBlock(
      double price, double? originalPrice, bool hasDiscount, int discountPct) {
    final sw = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            Text(
              '₹${price.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: (sw * 0.075).clamp(22.0, 32.0),
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
                color: const Color(0xFF0D0D0D),
                height: 1.0,
                letterSpacing: -0.5,
              ),
            ),
            if (hasDiscount) ...[
              Text(
                '₹${originalPrice!.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: (sw * 0.042).clamp(14.0, 17.0),
                  fontFamily: 'Poppins',
                  color: const Color(0xFFAAAAAA),
                  decoration: TextDecoration.lineThrough,
                  decorationColor: const Color(0xFFAAAAAA),
                  height: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$discountPct% OFF',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (hasDiscount) ...[
          const SizedBox(height: 4),
          const Text(
            'Inclusive of all taxes',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFFBBBBBB),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ],
    );
  }

  // ── Rating + social proof row ─────────────────────────────────────────────
  Widget _buildSocialRow(int soldCount) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFA000), size: 15),
              const Text('4.5',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                      color: Color(0xFF0D0D0D), fontFamily: 'Poppins')),
              const Text('·', style: TextStyle(color: Color(0xFFCCCCCC))),
              const Text('128 reviews',
                  style: TextStyle(fontSize: 12, color: Color(0xFF666666), fontFamily: 'Poppins')),
              if (soldCount > 0) ...[
                const Text('·', style: TextStyle(color: Color(0xFFCCCCCC))),
                const Icon(Icons.local_fire_department_rounded,
                    color: Color(0xFFFF6D00), size: 13),
                Text(
                  soldCount >= 1000
                      ? '${(soldCount / 1000).toStringAsFixed(soldCount % 1000 == 0 ? 0 : 1)}k sold'
                      : '$soldCount sold',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: Color(0xFFFF6D00), fontFamily: 'Poppins'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Bottom CTA ────────────────────────────────────────────────────────────
  Widget _buildBottomCTA(bool inStock) {
    final mq        = MediaQuery.of(context);
    final isSmall   = Responsive.isSmallPhone(context);
    final sw        = mq.size.width;
    final btnH      = (sw * 0.13).clamp(isSmall ? 40.0 : 44.0, 54.0);
    final hPad      = Responsive.hPadding(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, isSmall ? 10 : 12, hPad, isSmall ? 10 : 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isWishlisted = !_isWishlisted),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: btnH,
                    height: btnH,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isWishlisted
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isWishlisted
                            ? Colors.redAccent.withOpacity(0.35)
                            : const Color(0xFFE8E8E8),
                      ),
                    ),
                    child: Icon(
                      _isWishlisted
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isWishlisted ? Colors.redAccent : const Color(0xFF666666),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: inStock ? _addToCart : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: btnH,
                      decoration: BoxDecoration(
                        color: inStock ? const Color(0xFFF5F5F5) : const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: inStock ? const Color(0xFFDDDDDD) : const Color(0xFFE8E8E8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 17,
                              color: inStock ? const Color(0xFF111111) : const Color(0xFFAAAAAA)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              inStock ? 'Add to Cart' : 'Out of Stock',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: (sw * 0.034).clamp(12.0, 15.0),
                                fontWeight: FontWeight.w700,
                                color: inStock ? const Color(0xFF111111) : const Color(0xFFAAAAAA),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: inStock ? _onBuyNow : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: btnH,
                decoration: BoxDecoration(
                  color: inStock ? const Color(0xFF111111) : const Color(0xFFBDBDBD),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt_rounded, size: 17,
                        color: inStock ? Colors.white : const Color(0xFFEEEEEE)),
                    const SizedBox(width: 6),
                    Text(
                      'Buy Now',
                      style: TextStyle(
                        fontSize: (sw * 0.036).clamp(13.0, 16.0),
                        fontWeight: FontWeight.w800,
                        color: inStock ? Colors.white : const Color(0xFFEEEEEE),
                        fontFamily: 'Poppins',
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _floatBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    final isSmall = Responsive.isSmallPhone(context);
    final size    = isSmall ? 40.0 : 44.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 12,
                offset: const Offset(0, 3))
          ],
        ),
        child: Icon(icon, size: isSmall ? 18 : 20,
            color: color ?? const Color(0xFF111111)),
      ),
    );
  }


  Widget _badge(String label, Color bg, Color fg) {
    final isSmall = Responsive.isSmallPhone(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical:   isSmall ? 4 : 5,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isSmall ? 10.0 : 11.0,
          fontWeight: FontWeight.w600,
          color: fg,
          fontFamily: 'Poppins',
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _divider() => const Divider(color: Color(0xFFEEEEEE), thickness: 1, height: 1);


  // ── Accordion block ───────────────────────────────────────────────────────────
  Widget _buildAccordionBlock(String description, String category) {
    final sections = _accordionSections(description, category);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(sections.length, (i) {
          final isFirst = i == 0;
          final isLast  = i == sections.length - 1;
          return _buildAccordionTile(
            index: i,
            section: sections[i],
            isFirst: isFirst,
            isLast: isLast,
          );
        }),
      ),
    );
  }

  Widget _buildAccordionTile({
    required int index,
    required _AccordionSection section,
    required bool isFirst,
    required bool isLast,
  }) {
    final isOpen = _expandedSections.contains(index);
    final topRadius    = isFirst ? const Radius.circular(18) : Radius.zero;
    final bottomRadius = isLast && !isOpen ? const Radius.circular(18) : Radius.zero;

    return Column(
      children: [
        // ── Header row ──────────────────────────────────────────────────
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() {
            if (isOpen) {
              _expandedSections.remove(index);
            } else {
              _expandedSections.add(index);
            }
          }),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.hPadding(context) * 0.85,
              vertical: Responsive.isSmallPhone(context) ? 10 : 14,
            ),
            decoration: BoxDecoration(
              color: isOpen ? const Color(0xFFFAFAFA) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: topRadius,
                topRight: topRadius,
                bottomLeft: isOpen ? Radius.zero : bottomRadius,
                bottomRight: isOpen ? Radius.zero : bottomRadius,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: Responsive.isSmallPhone(context) ? 30.0 : 34.0,
                  height: Responsive.isSmallPhone(context) ? 30.0 : 34.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: section.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(section.icon, color: section.iconColor,
                      size: Responsive.isSmallPhone(context) ? 15 : 17),
                ),
                const SizedBox(width: 12),
                // Title
                Expanded(
                  child: Text(
                    section.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isOpen ? FontWeight.w700 : FontWeight.w600,
                      color: isOpen
                          ? const Color(0xFF0D0D0D)
                          : const Color(0xFF333333),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                // Animated chevron
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: isOpen
                        ? const Color(0xFF0D0D0D)
                        : const Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Animated body ────────────────────────────────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 280),
          sizeCurve: Curves.easeInOut,
          crossFadeState:
              isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.only(
                bottomLeft:  isLast ? const Radius.circular(18) : Radius.zero,
                bottomRight: isLast ? const Radius.circular(18) : Radius.zero,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: section.body,
                ),
              ],
            ),
          ),
        ),

        // ── Inter-tile divider ────────────────────────────────────────────
        if (!isLast)
          const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
      ],
    );
  }

  // ── Accordion content per category ─────────────────────────────────────────
  List<_AccordionSection> _accordionSections(
      String description, String category) {
    final cat = category.trim().toLowerCase();

    final specs = _specsForCategory(cat);
    final benefits = _benefitsForCategory(cat);
    final howToUse = _howToUseForCategory(cat);

    return [
      _AccordionSection(
        title: 'About Product',
        icon: Icons.info_outline_rounded,
        iconBg: const Color(0xFFE3F2FD),
        iconColor: const Color(0xFF1565C0),
        body: Text(
          description.isNotEmpty ? description : 'No description available.',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF555555),
            height: 1.65,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      _AccordionSection(
        title: 'Specifications',
        icon: Icons.list_alt_rounded,
        iconBg: const Color(0xFFF3E5F5),
        iconColor: const Color(0xFF6A1B9A),
        body: Column(
          children: specs
              .map((e) => _specRow(e.$1, e.$2))
              .toList(),
        ),
      ),
      _AccordionSection(
        title: 'Benefits',
        icon: Icons.verified_outlined,
        iconBg: const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF2E7D32),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: benefits
              .map((b) => _bulletRow(b))
              .toList(),
        ),
      ),
      _AccordionSection(
        title: 'How to Use',
        icon: Icons.touch_app_outlined,
        iconBg: const Color(0xFFFFF8E1),
        iconColor: const Color(0xFFF57F17),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            howToUse.length,
            (i) => _stepRow(i + 1, howToUse[i]),
          ),
        ),
      ),
      _AccordionSection(
        title: 'Shipping Info',
        icon: Icons.local_shipping_outlined,
        iconBg: const Color(0xFFFFEBEE),
        iconColor: const Color(0xFFC62828),
        body: Column(
          children: [
            _specRow('Standard Delivery', '3–5 business days'),
            _specRow('Express Delivery',  '1–2 business days'),
            _specRow('Free Shipping',     'On orders above ₹499'),
            _specRow('COD Available',     'Yes, on all orders'),
            _specRow('Return Window',     '7 days from delivery'),
          ],
        ),
      ),
    ];
  }

  // ── Accordion body helpers ──────────────────────────────────────────────────
  Widget _specRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: Color(0xFF888888), fontFamily: 'Poppins')),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 6,
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500,
                      color: Color(0xFF0D0D0D), fontFamily: 'Poppins')),
            ),
          ],
        ),
      );

  Widget _bulletRow(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: CircleAvatar(
                  radius: 3,
                  backgroundColor: Color(0xFF2E7D32)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                      height: 1.5,
                      fontFamily: 'Poppins')),
            ),
          ],
        ),
      );

  Widget _stepRow(int step, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text('$step',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Poppins')),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                      height: 1.5,
                      fontFamily: 'Poppins')),
            ),
          ],
        ),
      );

  // ── Category-aware content ──────────────────────────────────────────────────
  static List<(String, String)> _specsForCategory(String cat) {
    if (cat.contains('tape') || cat.contains('kinesiology')) {
      return [
        ('Material',    'Cotton + Spandex'),
        ('Width',       '5 cm'),
        ('Length',      '5 m per roll'),
        ('Adhesive',    'Acrylic, latex-free'),
        ('Water Resist','Yes'),
        ('Skin Safe',   'Dermatologist tested'),
      ];
    } else if (cat.contains('shuttle')) {
      return [
        ('Type',        'Feather / Synthetic'),
        ('Speed',       'Medium (77)'),
        ('Pack',        '6 shuttles'),
        ('Standard',    'BWF Approved'),
        ('Feathers',    '16 natural goose'),
        ('Base',        'Cork'),
      ];
    } else if (cat.contains('apparel') || cat.contains('shirt')) {
      return [
        ('Material',    '100% Polyester'),
        ('Fit',         'Slim / Regular'),
        ('Care',        'Machine wash cold'),
        ('Sizes',       'XS – 3XL'),
        ('Breathable',  'Yes'),
        ('Origin',      'Made in India'),
      ];
    }
    return [
      ('Brand',    'Weidan'),
      ('Category', cat.isNotEmpty ? cat : 'Sports'),
      ('Warranty', '6 months'),
      ('Origin',   'Made in India'),
    ];
  }

  static List<String> _benefitsForCategory(String cat) {
    if (cat.contains('tape') || cat.contains('kinesiology')) {
      return [
        'Provides targeted muscle & joint support',
        'Sweat-resistant — stays on during intense workouts',
        'Latex-free, safe for sensitive skin',
        'Improves proprioception and reduces injury risk',
        'Lightweight and breathable for all-day wear',
      ];
    } else if (cat.contains('shuttle')) {
      return [
        'Consistent flight trajectory for accurate play',
        'Durable feathers withstand competitive rallies',
        'BWF-approved for tournament use',
        'Optimised weight for balanced speed and control',
        'Cork base for natural feel on impact',
      ];
    } else if (cat.contains('apparel') || cat.contains('shirt')) {
      return [
        'Moisture-wicking fabric keeps you dry',
        'Four-way stretch for unrestricted movement',
        'Anti-odour treatment for freshness',
        'Lightweight construction reduces fatigue',
        'Reinforced stitching for long-lasting durability',
      ];
    }
    return [
      'Premium quality materials for lasting performance',
      'Designed for professional athletes',
      'Rigorously tested for safety and durability',
      'Ergonomic design for maximum comfort',
    ];
  }

  static List<String> _howToUseForCategory(String cat) {
    if (cat.contains('tape') || cat.contains('kinesiology')) {
      return [
        'Clean and dry the skin area before application',
        'Cut the tape to the required length',
        'Round the corners to prevent early peeling',
        'Apply with 25–50% stretch over the target muscle',
        'Rub firmly to activate the adhesive with heat',
        'Leave on for up to 3–5 days; remove gently in shower',
      ];
    } else if (cat.contains('shuttle')) {
      return [
        'Store shuttles upright in the tube at room temperature',
        'Humidify feather shuttles 30 min before play if needed',
        'Inspect feathers for damage before each game',
        'Replace when flight becomes inconsistent',
      ];
    } else if (cat.contains('apparel') || cat.contains('shirt')) {
      return [
        'Wear as a base layer or standalone sports top',
        'Machine wash cold with similar colours',
        'Do not bleach or tumble dry on high heat',
        'Iron on low heat if needed; avoid print areas',
      ];
    }
    return [
      'Read the product manual before first use',
      'Follow recommended usage guidelines',
      'Store in a cool, dry place when not in use',
      'Contact support for any product queries',
    ];
  }

  // ── Product features ─────────────────────────────────────────────────────
  Widget _buildFeaturesSection(String category) {
    final features = _featuresForCategory(category);
    if (features.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Features',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0D0D0D),
            fontFamily: 'Poppins',
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final chipW = (constraints.maxWidth * 0.26).clamp(80.0, 120.0);
            final chipH = (chipW * 1.25).clamp(100.0, 145.0);
            return SizedBox(
              height: chipH,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: features.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => SizedBox(width: chipW, child: _featureChip(features[i])),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _featureChip(_FeatureChip f) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = (constraints.maxWidth).clamp(80.0, 120.0);
        return Container(
          width: w,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: (w * 0.28).clamp(26.0, 34.0),
                height: (w * 0.28).clamp(26.0, 34.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: f.iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(f.icon, color: f.iconColor,
                    size: (w * 0.16).clamp(14.0, 18.0)),
              ),
              const SizedBox(height: 6),
              Text(
                f.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                  fontFamily: 'Poppins',
                  height: 1.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static List<_FeatureChip> _featuresForCategory(String category) {
    switch (category.trim().toLowerCase()) {
      case 'tape':
      case 'kinesiology':
        return const [
          _FeatureChip(icon: Icons.water_drop_outlined,   iconBg: Color(0xFFE3F2FD), iconColor: Color(0xFF1565C0), label: 'Sweat\nResistant'),
          _FeatureChip(icon: Icons.handshake_outlined,    iconBg: Color(0xFFE8F5E9), iconColor: Color(0xFF2E7D32), label: 'Strong\nAdhesion'),
          _FeatureChip(icon: Icons.favorite_border,       iconBg: Color(0xFFFFEBEE), iconColor: Color(0xFFC62828), label: 'Skin\nFriendly'),
          _FeatureChip(icon: Icons.emoji_events_outlined, iconBg: Color(0xFFFFF8E1), iconColor: Color(0xFFF57F17), label: 'Athlete\nApproved'),
          _FeatureChip(icon: Icons.air_outlined,          iconBg: Color(0xFFF3E5F5), iconColor: Color(0xFF6A1B9A), label: 'Breathable'),
        ];
      case 'apparel':
      case 'clothing':
      case 't-shirt':
        return const [
          _FeatureChip(icon: Icons.air_outlined,           iconBg: Color(0xFFE3F2FD), iconColor: Color(0xFF1565C0), label: 'Breathable'),
          _FeatureChip(icon: Icons.water_drop_outlined,    iconBg: Color(0xFFE8F5E9), iconColor: Color(0xFF2E7D32), label: 'Moisture\nWick'),
          _FeatureChip(icon: Icons.straighten_outlined,    iconBg: Color(0xFFFFF8E1), iconColor: Color(0xFFF57F17), label: 'Slim Fit'),
          _FeatureChip(icon: Icons.favorite_border,        iconBg: Color(0xFFFFEBEE), iconColor: Color(0xFFC62828), label: 'Skin\nFriendly'),
          _FeatureChip(icon: Icons.recycling_outlined,     iconBg: Color(0xFFF3E5F5), iconColor: Color(0xFF6A1B9A), label: 'Eco\nFabric'),
        ];
      case 'shuttle':
      case 'shuttlecock':
        return const [
          _FeatureChip(icon: Icons.speed_outlined,         iconBg: Color(0xFFE3F2FD), iconColor: Color(0xFF1565C0), label: 'High\nSpeed'),
          _FeatureChip(icon: Icons.balance_outlined,       iconBg: Color(0xFFE8F5E9), iconColor: Color(0xFF2E7D32), label: 'Stable\nFlight'),
          _FeatureChip(icon: Icons.verified_outlined,      iconBg: Color(0xFFFFF8E1), iconColor: Color(0xFFF57F17), label: 'Tournament\nGrade'),
          _FeatureChip(icon: Icons.emoji_events_outlined,  iconBg: Color(0xFFFFEBEE), iconColor: Color(0xFFC62828), label: 'Athlete\nApproved'),
          _FeatureChip(icon: Icons.recycling_outlined,     iconBg: Color(0xFFF3E5F5), iconColor: Color(0xFF6A1B9A), label: 'Durable'),
        ];
      default:
        return const [
          _FeatureChip(icon: Icons.verified_outlined,      iconBg: Color(0xFFE8F5E9), iconColor: Color(0xFF2E7D32), label: 'Premium\nQuality'),
          _FeatureChip(icon: Icons.emoji_events_outlined,  iconBg: Color(0xFFFFF8E1), iconColor: Color(0xFFF57F17), label: 'Athlete\nApproved'),
          _FeatureChip(icon: Icons.favorite_border,        iconBg: Color(0xFFFFEBEE), iconColor: Color(0xFFC62828), label: 'Skin\nFriendly'),
          _FeatureChip(icon: Icons.speed_outlined,         iconBg: Color(0xFFE3F2FD), iconColor: Color(0xFF1565C0), label: 'High\nPerformance'),
        ];
    }
  }

  // ── Delivery & Offers card ───────────────────────────────────────────────
  Widget _buildDeliverySection(int stock) {
    final isLowStock = stock > 0 && stock <= 5;

    const items = [
      _DeliveryItem(
        icon: Icons.local_shipping_outlined,
        iconBg: Color(0xFFE8F5E9),
        iconColor: Color(0xFF2E7D32),
        title: 'Free Delivery',
        subtitle: 'On orders above ₹499',
      ),
      _DeliveryItem(
        icon: Icons.bolt_outlined,
        iconBg: Color(0xFFFFF8E1),
        iconColor: Color(0xFFF57F17),
        title: 'Fast Shipping',
        subtitle: 'Delivered in 2–4 business days',
      ),
      _DeliveryItem(
        icon: Icons.replay_rounded,
        iconBg: Color(0xFFE3F2FD),
        iconColor: Color(0xFF1565C0),
        title: '7-Day Easy Returns',
        subtitle: 'Hassle-free returns & exchanges',
      ),
      _DeliveryItem(
        icon: Icons.payments_outlined,
        iconBg: Color(0xFFF3E5F5),
        iconColor: Color(0xFF6A1B9A),
        title: 'Cash on Delivery',
        subtitle: 'Pay when your order arrives',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        const Text(
          'Delivery & Offers',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0D0D0D),
            fontFamily: 'Poppins',
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: Responsive.isSmallPhone(context) ? 8 : 12),

        // Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Limited stock warning ──────────────────────────────
              if (isLowStock)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFE65100), size: 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Only $stock left in stock — order soon!',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE65100),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Delivery rows ──────────────────────────────────────
              ...List.generate(items.length, (i) {
                final item = items[i];
                final isLast = i == items.length - 1;
                final topRadius = i == 0 && !isLowStock
                    ? const Radius.circular(18)
                    : Radius.zero;
                final bottomRadius = isLast
                    ? const Radius.circular(18)
                    : Radius.zero;

                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: topRadius,
                          topRight: topRadius,
                          bottomLeft: bottomRadius,
                          bottomRight: bottomRadius,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.hPadding(context),
                          vertical: Responsive.isSmallPhone(context) ? 12 : 14),
                      child: Row(
                        children: [
                          Container(
                            width: Responsive.isSmallPhone(context) ? 36.0 : 40.0,
                            height: Responsive.isSmallPhone(context) ? 36.0 : 40.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: item.iconBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(item.icon,
                                color: item.iconColor,
                                size: Responsive.isSmallPhone(context) ? 18 : 20),
                          ),
                          const SizedBox(width: 14),
                          // Title + subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0D0D0D),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.subtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF888888),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: Color(0xFFCCCCCC), size: 20),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFF5F5F5),
                          indent: 70,
                          endIndent: 16),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ── Customer reviews ───────────────────────────────────────────────────
  static const _reviews = [
    _ReviewData(
      id: 0,
      name: 'Arjun Mehta',
      initials: 'AM',
      avatarColor: Color(0xFF1565C0),
      rating: 5,
      date: '12 Jan 2025',
      verified: true,
      title: 'Excellent product!',
      body:
          'Absolutely love this product. The quality is top-notch and it held up perfectly during my training sessions. Highly recommend to every athlete.',
      helpfulCount: 24,
      hasImage: true,
    ),
    _ReviewData(
      id: 1,
      name: 'Priya Sharma',
      initials: 'PS',
      avatarColor: Color(0xFF6A1B9A),
      rating: 4,
      date: '3 Feb 2025',
      verified: true,
      title: 'Great value for money',
      body:
          'Really good quality for the price. Fits well and feels comfortable. Delivery was fast too. Would buy again.',
      helpfulCount: 11,
      hasImage: false,
    ),
    _ReviewData(
      id: 2,
      name: 'Rahul Nair',
      initials: 'RN',
      avatarColor: Color(0xFF2E7D32),
      rating: 4,
      date: '28 Feb 2025',
      verified: false,
      title: 'Solid build quality',
      body:
          'Good product overall. Packaging was neat and the item matched the description. Minor improvement in sizing would make it perfect.',
      helpfulCount: 7,
      hasImage: false,
    ),
  ];

  // Rating breakdown data: [5★, 4★, 3★, 2★, 1★] counts
  static const _ratingCounts = [74, 32, 14, 5, 3];
  static const _totalRatings = 128;
  static const _overallRating = 4.5;

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Flexible(
              child: Text(
                'Customer Reviews',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0D0D0D),
                  fontFamily: 'Poppins',
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$_totalRatings ratings',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Rating summary card ───────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Big rating number
              LayoutBuilder(
                builder: (context, constraints) {
                  final ratingFontSize = (MediaQuery.of(context).size.width * 0.10)
                      .clamp(Responsive.isSmallPhone(context) ? 28.0 : 32.0, 48.0);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _overallRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: ratingFontSize,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0D0D0D),
                          fontFamily: 'Poppins',
                          height: 1.0,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _starRow(_overallRating.round(), size: 13),
                      const SizedBox(height: 4),
                      const Text(
                        'out of 5',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFAAAAAA),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 20),
              // Breakdown bars
              Expanded(
                child: Column(
                  children: List.generate(5, (i) {
                    final star = 5 - i;
                    final count = _ratingCounts[i];
                    final pct = count / _totalRatings;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      child: Row(
                        children: [
                          Text(
                            '$star',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF555555),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFFFA000), size: 11),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 6,
                                backgroundColor: const Color(0xFFF0F0F0),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        Color(0xFFFFA000)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 24,
                            child: Text(
                              '$count',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF888888),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Review cards ───────────────────────────────────────────────
        ...List.generate(
          _reviews.length,
          (i) => Padding(
            padding: EdgeInsets.only(
                bottom: i < _reviews.length - 1 ? 12 : 0),
            child: _buildReviewCard(_reviews[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(_ReviewData r) {
    final isHelpful = _helpfulTapped.contains(r.id);
    final helpfulCount = r.helpfulCount + (isHelpful ? 1 : 0);

    return Container(
      padding: EdgeInsets.all(Responsive.isSmallPhone(context) ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: avatar + name + date ───────────────────────────
          Row(
            children: [
              // Avatar
              Container(
                width: Responsive.isSmallPhone(context) ? 36.0 : 40.0,
                height: Responsive.isSmallPhone(context) ? 36.0 : 40.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: r.avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  r.initials,
                  style: TextStyle(
                    fontSize: Responsive.isSmallPhone(context) ? 12.0 : 14.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            r.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0D0D0D),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        if (r.verified) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.verified_rounded,
                                    color: Color(0xFF2E7D32), size: 10),
                                SizedBox(width: 3),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2E7D32),
                                    fontFamily: 'Poppins',
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      r.date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFAAAAAA),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Stars + title ───────────────────────────────────────────
          Row(
            children: [
              _starRow(r.rating, size: 13),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  r.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D0D0D),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Review body ─────────────────────────────────────────────
          Text(
            r.body,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF555555),
              height: 1.55,
              fontFamily: 'Poppins',
            ),
          ),

          // ── Review image placeholder ────────────────────────────────
          if (r.hasImage) ...[
            const SizedBox(height: 10),
            Row(
              children: List.generate(
                2,
                (i) {
                  final thumbSize = Responsive.isSmallPhone(context) ? 52.0 : 64.0;
                  return Container(
                    width: thumbSize,
                    height: thumbSize,
                    margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFEEEEEE), width: 1),
                    ),
                    child: const Icon(Icons.image_outlined,
                        color: Color(0xFFCCCCCC), size: 24),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ── Helpful button ────────────────────────────────────────────
          const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Helpful?',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => setState(() {
                  if (isHelpful) {
                    _helpfulTapped.remove(r.id);
                  } else {
                    _helpfulTapped.add(r.id);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isHelpful
                        ? const Color(0xFF0D0D0D)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isHelpful
                          ? const Color(0xFF0D0D0D)
                          : const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isHelpful
                            ? Icons.thumb_up_rounded
                            : Icons.thumb_up_outlined,
                        size: 13,
                        color: isHelpful
                            ? Colors.white
                            : const Color(0xFF555555),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Yes ($helpfulCount)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isHelpful
                              ? Colors.white
                              : const Color(0xFF555555),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _starRow(int count, {double size = 14}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          5,
          (i) => Icon(
            i < count ? Icons.star_rounded : Icons.star_outline_rounded,
            color: const Color(0xFFFFA000),
            size: size,
          ),
        ),
      );

  // ── Related products ──────────────────────────────────────────────────────
  static final _youMayAlsoLike = [
    _RelatedProduct(id: 'r1', name: 'Flight Wing 350',        asset: 'assets/products_image/Flight Wing 350.jpg',        price: 899,  originalPrice: 1199, rating: 4.6, reviews: 84),
    _RelatedProduct(id: 'r2', name: 'MULT 2 Feather Shuttle', asset: 'assets/products_image/MULT 2 Feather shuttle.jpg', price: 349,  originalPrice: 499,  rating: 4.3, reviews: 52),
    _RelatedProduct(id: 'r3', name: 'Weidan T-Shirt',         asset: 'assets/products_image/Weidan T-Shirt.jpg',         price: 599,  originalPrice: 799,  rating: 4.5, reviews: 110),
    _RelatedProduct(id: 'r4', name: '2.0 Air Shuttle',        asset: 'assets/products_image/2.0 Air Shuttle.jpg',        price: 299,  originalPrice: 399,  rating: 4.2, reviews: 37),
  ];
  static final _frequentlyBought = [
    _RelatedProduct(id: 'f1', name: 'Kinesiology Tape',       asset: 'assets/products_image/kinesiology Tape.jpg',       price: 249,  originalPrice: 349,  rating: 4.7, reviews: 203),
    _RelatedProduct(id: 'f2', name: '2.0 Air Shuttle',        asset: 'assets/products_image/2.0 Air Shuttle.jpg',        price: 299,  originalPrice: 399,  rating: 4.2, reviews: 37),
    _RelatedProduct(id: 'f3', name: 'Flight Wing 350',        asset: 'assets/products_image/Flight Wing 350.jpg',        price: 899,  originalPrice: 1199, rating: 4.6, reviews: 84),
  ];
  static final _recentlyViewed = [
    _RelatedProduct(id: 'v1', name: 'Weidan T-Shirt',         asset: 'assets/products_image/Weidan T-Shirt.jpg',         price: 599,  originalPrice: 799,  rating: 4.5, reviews: 110),
    _RelatedProduct(id: 'v2', name: 'MULT 2 Feather Shuttle', asset: 'assets/products_image/MULT 2 Feather shuttle.jpg', price: 349,  originalPrice: 499,  rating: 4.3, reviews: 52),
    _RelatedProduct(id: 'v3', name: 'Kinesiology Tape',       asset: 'assets/products_image/kinesiology Tape.jpg',       price: 249,  originalPrice: 349,  rating: 4.7, reviews: 203),
  ];

  Widget _buildRelatedProductsBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRelatedSection(title: 'You May Also Like',          subtitle: 'Picked for you',                  items: _youMayAlsoLike),
        const SizedBox(height: 24),
        _buildRelatedSection(title: 'Frequently Bought Together', subtitle: 'Customers also bought',           items: _frequentlyBought),
        const SizedBox(height: 24),
        _buildRelatedSection(title: 'Recently Viewed',            subtitle: 'Continue where you left off',    items: _recentlyViewed),
      ],
    );
  }

  Widget _buildRelatedSection({
    required String title,
    required String subtitle,
    required List<_RelatedProduct> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: Color(0xFF0D0D0D), fontFamily: 'Poppins',
                        letterSpacing: -0.2,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11, color: Color(0xFFAAAAAA),
                        fontFamily: 'Poppins',
                      )),
                ],
              ),
            ),
            const Text('See all',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: Color(0xFF555555), fontFamily: 'Poppins',
                )),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            // Card width: 44% of available width, clamped
            final cardW = (constraints.maxWidth * 0.44).clamp(130.0, 200.0);
            // Card height: generous ratio so info area never squeezes
            final cardH = (cardW * 1.72).clamp(220.0, 300.0);
            return SizedBox(
              height: cardH,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) =>
                    _buildRelatedCard(items[i], cardW, cardH),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRelatedCard(
      _RelatedProduct p, double cardW, double cardH) {
    final isWishlisted  = _relatedWishlisted.contains(p.id);
    final discountPct   = (((p.originalPrice - p.price) / p.originalPrice) * 100).round();

    // ── All dimensions derived from cardW — no fixed values ──────────────
    final radius      = (cardW * 0.09).clamp(10.0, 16.0);
    // Image = 46% of card height
    final imgH        = cardH * 0.46;
    // Inner padding
    final pad         = (cardW * 0.07).clamp(7.0, 12.0);
    // Font sizes
    final ratingFs    = (cardW * 0.072).clamp(9.0, 12.0);
    final nameFs      = (cardW * 0.080).clamp(10.0, 13.0);
    final priceFs     = (cardW * 0.086).clamp(11.0, 14.0);
    final origPriceFs = (cardW * 0.066).clamp(9.0, 11.0);
    final btnFs       = (cardW * 0.074).clamp(9.5, 12.0);
    // Button height — proportion of cardW so it never overflows
    final btnH        = (cardW * 0.20).clamp(22.0, 32.0);
    // Badge sizes
    final badgePadH   = (cardW * 0.038).clamp(5.0, 8.0);
    final badgePadV   = (cardW * 0.020).clamp(2.0, 4.0);
    final badgeFs     = (cardW * 0.058).clamp(7.0, 10.0);
    // Wishlist button
    final wishSize    = (cardW * 0.20).clamp(22.0, 30.0);

    return SizedBox(
      width: cardW,
      height: cardH,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            // ── Image + overlays ───────────────────────────────────────
            SizedBox(
              width: cardW,
              height: imgH,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(radius)),
                    child: Image.asset(
                      p.asset,
                      width: cardW,
                      height: imgH,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF5F5F5),
                        child: Icon(Icons.image_outlined,
                            color: const Color(0xFFCCCCCC),
                            size: cardW * 0.22),
                      ),
                    ),
                  ),

                  // Discount badge
                  Positioned(
                    top: pad * 0.6,
                    left: pad * 0.6,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: badgePadH, vertical: badgePadV),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '$discountPct% OFF',
                        style: TextStyle(
                          fontSize: badgeFs,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  // Wishlist
                  Positioned(
                    top: pad * 0.5,
                    right: pad * 0.5,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        isWishlisted
                            ? _relatedWishlisted.remove(p.id)
                            : _relatedWishlisted.add(p.id);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: wishSize,
                        height: wishSize,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: wishSize * 0.50,
                          color: isWishlisted
                              ? Colors.redAccent
                              : const Color(0xFF888888),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info area ──────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, pad * 0.7, pad, pad * 0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [

                    // Rating row
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: const Color(0xFFFFA000),
                            size: ratingFs + 1),
                        SizedBox(width: pad * 0.25),
                        Text(
                          p.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: ratingFs,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF555555),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(width: pad * 0.3),
                        Flexible(
                          child: Text(
                            '(${p.reviews})',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: ratingFs * 0.9,
                              color: const Color(0xFFAAAAAA),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Product name
                    Text(
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: nameFs,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0D0D0D),
                        fontFamily: 'Poppins',
                        height: 1.25,
                      ),
                    ),

                    // Price row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            '₹${p.price.toStringAsFixed(0)}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: priceFs,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0D0D0D),
                              fontFamily: 'Poppins',
                              height: 1.1,
                            ),
                          ),
                        ),
                        SizedBox(width: pad * 0.35),
                        Flexible(
                          child: Text(
                            '₹${p.originalPrice.toStringAsFixed(0)}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: origPriceFs,
                              color: const Color(0xFFAAAAAA),
                              decoration: TextDecoration.lineThrough,
                              decorationColor: const Color(0xFFAAAAAA),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Add to cart button
                    SizedBox(
                      width: double.infinity,
                      height: btnH,
                      child: ElevatedButton(
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${p.name} added to cart'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D0D0D),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(radius * 0.65)),
                        ),
                        child: Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: btnFs,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onBuyNow() {
    if (widget.product.sizes.isNotEmpty && _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a size first'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final p = widget.product;
    final subtotal    = p.price;
    final discount    = p.originalPrice != null && p.originalPrice! > p.price
        ? p.originalPrice! - p.price
        : 0.0;
    final deliveryFee = subtotal >= 499 ? 0.0 : 49.0;
    final tax         = (subtotal * 0.05);
    final grandTotal  = subtotal + deliveryFee + tax;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          items: [
            OrderItem(
              productId:     p.id,
              productName:   p.name,
              quantity:      1,
              price:         p.price,
              size:          _selectedSize,
              imageUrl:      p.imageUrl,
              originalPrice: p.originalPrice,
            ),
          ],
          subtotal:    subtotal,
          discount:    discount,
          deliveryFee: deliveryFee,
          tax:         tax,
          grandTotal:  grandTotal,
        ),
      ),
    );
  }

  void _onShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${widget.product.name}…'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _addToCart() {
    if (widget.product.sizes.isNotEmpty && _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a size first'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Provider.of<CartProvider>(context, listen: false).addItem(
      widget.product.id,
      widget.product.name,
      widget.product.price,
      widget.product.imageUrl,
      size: _selectedSize,
      originalPrice: widget.product.originalPrice,
      rating: 4.5,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Added to cart!'),
          ],
        ),
        backgroundColor: const Color(0xFF111111),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ── Delivery row data class ─────────────────────────────────────────────────────
class _DeliveryItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  const _DeliveryItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}

// ── Feature chip data class ────────────────────────────────────────────────────
class _FeatureChip {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  const _FeatureChip({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
  });
}

// ── Accordion section data class ──────────────────────────────────────────────
class _AccordionSection {
  final String title;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Widget body;
  const _AccordionSection({
    required this.title,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.body,
  });
}

// ── Review data class ─────────────────────────────────────────────────────────
class _ReviewData {
  final int id;
  final String name;
  final String initials;
  final Color avatarColor;
  final int rating;
  final String date;
  final bool verified;
  final String title;
  final String body;
  final int helpfulCount;
  final bool hasImage;
  const _ReviewData({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.rating,
    required this.date,
    required this.verified,
    required this.title,
    required this.body,
    required this.helpfulCount,
    required this.hasImage,
  });
}

// ── Related product data class ────────────────────────────────────────────────
class _RelatedProduct {
  final String id;
  final String name;
  final String asset;
  final double price;
  final double originalPrice;
  final double rating;
  final int reviews;
  const _RelatedProduct({
    required this.id,
    required this.name,
    required this.asset,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviews,
  });
}
