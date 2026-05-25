import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/cart_provider.dart';
import '../../models/order_model.dart';
import '../../widgets/cart_item_card.dart';
import '../../utils/responsive.dart';
import 'home_screen.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Tracks the pixel height of the floating checkout card so the
  // list can add matching bottom padding and nothing is hidden.
  double _checkoutCardHeight = 0;
  final GlobalKey _checkoutKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureCard());
  }

  void _measureCard() {
    final ctx = _checkoutKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final h = box.size.height;
    if (h != _checkoutCardHeight) setState(() => _checkoutCardHeight = h);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        appBar: _buildAppBar(),
        body: Consumer<CartProvider>(
          builder: (context, cart, _) {
            if (cart.items.isEmpty) return _buildEmptyState();

            return Stack(
              children: [
                // ── Scrollable cart list ─────────────────────────────
                ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    16, 16, 16,
                    _checkoutCardHeight + 16,
                  ),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return CartItemCard(
                      cartItem: item,
                      onQuantityChanged: (qty) => cart.updateQuantity(
                        item.productId, qty,
                        size: item.size,
                      ),
                      onRemove: () => cart.removeItem(
                        item.productId,
                        size: item.size,
                      ),
                    );
                  },
                ),

                // ── Sticky floating checkout card ────────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildCheckoutCard(context, cart),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF5F6F8),
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        ),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: Color(0xFF111111)),
        ),
      ),
      title: Consumer<CartProvider>(
        builder: (_, cart, __) => Column(
          children: [
            const Text(
              'My Cart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0D0D0D),
                fontFamily: 'SF Pro Display',
                letterSpacing: -0.3,
              ),
            ),
            Text(
              '${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'items'}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: Color(0xFF111111),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                size: 52, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D0D0D),
              fontFamily: 'SF Pro Display',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items to get started',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF999999),
              fontFamily: 'SF Pro Display',
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Shop Now',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
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

  // ── Sticky floating checkout card ──────────────────────────────────────────
  Widget _buildCheckoutCard(BuildContext context, CartProvider cart) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final sw = MediaQuery.of(context).size.width;

    final subtotal     = cart.totalAmount;
    final discount     = cart.totalDiscount;
    final deliveryFee  = cart.deliveryFee;
    final tax          = cart.tax;
    final grandTotal   = cart.grandTotal;
    final freeDelivery = deliveryFee == 0;

    return Container(
      key: _checkoutKey,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──────────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + Responsive.navBarHeight + Responsive.navBarGap + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section title ──────────────────────────────────────
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0D0D0D),
                    fontFamily: 'SF Pro Display',
                    letterSpacing: -0.2,
                  ),
                ),

                const SizedBox(height: 14),

                // ── Summary line items ─────────────────────────────────
                _summaryRow(
                  label: 'Subtotal',
                  value: '₹${subtotal.toStringAsFixed(0)}',
                  labelColor: const Color(0xFF666666),
                  valueColor: const Color(0xFF0D0D0D),
                ),

                const SizedBox(height: 10),

                _summaryRow(
                  label: 'Delivery',
                  value: freeDelivery ? 'FREE' : '₹${deliveryFee.toStringAsFixed(0)}',
                  labelColor: const Color(0xFF666666),
                  valueColor: freeDelivery
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF0D0D0D),
                  valueBold: freeDelivery,
                  trailing: freeDelivery
                      ? _badge('Free above ₹499',
                          const Color(0xFFE8F5E9), const Color(0xFF2E7D32))
                      : null,
                ),

                if (discount > 0) ...[
                  const SizedBox(height: 10),
                  _summaryRow(
                    label: 'Discount',
                    value: '− ₹${discount.toStringAsFixed(0)}',
                    labelColor: const Color(0xFF666666),
                    valueColor: const Color(0xFFE53935),
                    icon: Icons.local_offer_rounded,
                    iconColor: const Color(0xFFE53935),
                  ),
                ],

                const SizedBox(height: 10),

                _summaryRow(
                  label: 'Tax (5% GST)',
                  value: '₹${tax.toStringAsFixed(0)}',
                  labelColor: const Color(0xFF666666),
                  valueColor: const Color(0xFF0D0D0D),
                ),

                const SizedBox(height: 14),

                // ── Dashed divider ─────────────────────────────────────
                _dashedDivider(),

                const SizedBox(height: 14),

                // ── Grand total row ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF999999),
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${grandTotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0D0D0D),
                            fontFamily: 'SF Pro Display',
                            letterSpacing: -0.5,
                            height: 1.0,
                          ),
                        ),
                        if (discount > 0) ...[
                          const SizedBox(height: 3),
                          Text(
                            'You save ₹${discount.toStringAsFixed(0)} on this order',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                        ],
                      ],
                    ),

                    // ── Checkout CTA ─────────────────────────────────
                    GestureDetector(
                      onTap: () => _checkout(context, cart),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: sw * 0.44,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.22),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                        ),
                        child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.bolt_rounded,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Checkout',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      fontFamily: 'SF Pro Display',
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Trust badges row ───────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _trustBadge(Icons.lock_outline_rounded, 'Secure Payment'),
                    _trustDot(),
                    _trustBadge(Icons.replay_rounded, '7-Day Returns'),
                    _trustDot(),
                    _trustBadge(Icons.verified_outlined, 'Genuine Products'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _summaryRow({
    required String label,
    required String value,
    required Color labelColor,
    required Color valueColor,
    bool valueBold = false,
    IconData? icon,
    Color? iconColor,
    Widget? trailing,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 5),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: labelColor,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing,
        ],
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: valueColor,
            fontFamily: 'SF Pro Display',
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _badge(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: fg,
            fontFamily: 'SF Pro Display',
          ),
        ),
      );

  Widget _dashedDivider() {
    return LayoutBuilder(
      builder: (_, constraints) {
        const dashW = 6.0;
        const gap = 4.0;
        final count = (constraints.maxWidth / (dashW + gap)).floor();
        return Row(
          children: List.generate(
            count,
            (_) => Container(
              width: dashW,
              height: 1.5,
              margin: const EdgeInsets.only(right: gap),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _trustBadge(IconData icon, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF999999)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF999999),
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );

  Widget _trustDot() => Container(
        width: 3,
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          color: Color(0xFFCCCCCC),
          shape: BoxShape.circle,
        ),
      );

  // ── Checkout logic ─────────────────────────────────────────────────────────
  void _checkout(BuildContext context, CartProvider cart) {
    HapticFeedback.mediumImpact();
    final orderItems = cart.items
        .map((item) => OrderItem(
              productId: item.productId,
              productName: item.productName,
              quantity: item.quantity,
              price: item.price,
              originalPrice: item.originalPrice,
              imageUrl: item.imageUrl,
              size: item.size,
            ))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          items: orderItems,
          subtotal: cart.totalAmount,
          discount: cart.totalDiscount,
          deliveryFee: cart.deliveryFee,
          tax: cart.tax,
          grandTotal: cart.grandTotal,
          onOrderSuccess: cart.clearCart,
        ),
      ),
    );
  }
}
