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
    final hp      = Responsive.hPadding(context);
    final vs      = Responsive.vSpacing(context);
    final keyboardH = MediaQuery.of(context).viewInsets.bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(),
        body: Consumer<CartProvider>(
          builder: (context, cart, _) {
            if (cart.items.isEmpty) return _buildEmptyState();
            return Stack(
              children: [
                ListView.builder(
                  padding: EdgeInsets.fromLTRB(hp, vs, hp, _checkoutCardHeight + vs),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return CartItemCard(
                      cartItem: item,
                      onQuantityChanged: (qty) => cart.updateQuantity(item.productId, qty, size: item.size),
                      onRemove: () => cart.removeItem(item.productId, size: item.size),
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  // Shift checkout card up by keyboard height so it's never buried
                  bottom: keyboardH,
                  child: _buildCheckoutCard(context, cart),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    final isSmall = Responsive.isSmallPhone(context);
    return AppBar(
      backgroundColor: const Color(0xFFF5F6F8),
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen())),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF111111)),
        ),
      ),
      title: Consumer<CartProvider>(
        builder: (_, cart, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'My Cart',
              style: TextStyle(
                fontSize: isSmall ? 16.0 : 18.0,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0D0D0D),
                fontFamily: 'SF Pro Display',
                letterSpacing: -0.3,
              ),
            ),
            Text(
              '${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'items'}',
              style: TextStyle(
                fontSize: isSmall ? 11.0 : 12.0,
                color: const Color(0xFF999999),
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    final sw = MediaQuery.of(context).size.width;
    final iconSize = (sw * 0.28).clamp(90.0, 120.0);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.hPadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: const BoxDecoration(color: Color(0xFF111111), shape: BoxShape.circle),
              child: Icon(Icons.shopping_bag_outlined, size: iconSize * 0.46, color: Colors.white),
            ),
            SizedBox(height: Responsive.vSpacing(context)),
            Text(
              'Your cart is empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 20, min: 16, max: 22),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0D0D0D),
                fontFamily: 'SF Pro Display',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14, min: 13, max: 16),
                color: const Color(0xFF999999),
                fontFamily: 'SF Pro Display',
              ),
            ),
            SizedBox(height: Responsive.vSpacing(context) * 2),
            GestureDetector(
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen())),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.hPadding(context) + 8,
                  vertical: Responsive.isSmallPhone(context) ? 12 : 14,
                ),
                decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(14)),
                child: Text(
                  'Shop Now',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 14, min: 13, max: 16),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sticky floating checkout card ───────────────────────────────────────────
  Widget _buildCheckoutCard(BuildContext context, CartProvider cart) {
    final isSmall   = Responsive.isSmallPhone(context);
    final sw        = MediaQuery.of(context).size.width;
    final hPad      = Responsive.hPadding(context);
    // navBarClearance already includes safe-area bottom + nav bar height + gap
    final bottomPad = Responsive.navBarClearance(context);
    final labelFs   = isSmall ? 12.0 : 13.0;
    final titleFs   = Responsive.fontSize(context, 16, min: 13, max: 18);
    final btnHeight = (sw * 0.13).clamp(44.0, 54.0);
    final vs        = isSmall ? 10.0 : 14.0;
    final vsSmall   = isSmall ? 8.0 : 10.0;

    final subtotal    = cart.totalAmount;
    final discount    = cart.totalDiscount;
    final deliveryFee = cart.deliveryFee;
    final tax         = cart.tax;
    final grandTotal  = cart.grandTotal;
    final freeDelivery = deliveryFee == 0;

    return Container(
      key: _checkoutKey,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 28, spreadRadius: 0, offset: const Offset(0, -6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, bottomPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // section title
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: titleFs,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0D0D0D),
                    fontFamily: 'SF Pro Display',
                    letterSpacing: -0.2,
                  ),
                ),

                SizedBox(height: vs),

                _summaryRow(label: 'Subtotal', value: '\u20b9${subtotal.toStringAsFixed(0)}', labelColor: const Color(0xFF666666), valueColor: const Color(0xFF0D0D0D), fontSize: labelFs),
                SizedBox(height: vsSmall),
                _summaryRow(
                  label: 'Delivery',
                  value: freeDelivery ? 'FREE' : '\u20b9${deliveryFee.toStringAsFixed(0)}',
                  labelColor: const Color(0xFF666666),
                  valueColor: freeDelivery ? const Color(0xFF2E7D32) : const Color(0xFF0D0D0D),
                  valueBold: freeDelivery,
                  trailing: freeDelivery ? _badge('Free above \u20b9499', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)) : null,
                  fontSize: labelFs,
                ),

                if (discount > 0) ...[
                  SizedBox(height: vsSmall),
                  _summaryRow(
                    label: 'Discount',
                    value: '\u2212 \u20b9${discount.toStringAsFixed(0)}',
                    labelColor: const Color(0xFF666666),
                    valueColor: const Color(0xFFE53935),
                    icon: Icons.local_offer_rounded,
                    iconColor: const Color(0xFFE53935),
                    fontSize: labelFs,
                  ),
                ],

                SizedBox(height: vsSmall),
                _summaryRow(label: 'Tax (5% GST)', value: '\u20b9${tax.toStringAsFixed(0)}', labelColor: const Color(0xFF666666), valueColor: const Color(0xFF0D0D0D), fontSize: labelFs),

                SizedBox(height: vs),
                _dashedDivider(),
                SizedBox(height: vs),

                // grand total + checkout button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Total column — Expanded so it takes all remaining space
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: isSmall ? 10.0 : 11.0,
                              color: const Color(0xFF999999),
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\u20b9${grandTotal.toStringAsFixed(0)}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 24, min: 18, max: 26),
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0D0D0D),
                              fontFamily: 'SF Pro Display',
                              letterSpacing: -0.5,
                              height: 1.0,
                            ),
                          ),
                          if (discount > 0) ...[
                            const SizedBox(height: 3),
                            Text(
                              'You save \u20b9${discount.toStringAsFixed(0)}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isSmall ? 10.0 : 11.0,
                                color: const Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Checkout button — intrinsic width via padding, never squeezes total column
                    GestureDetector(
                      onTap: () => _checkout(context, cart),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: btnHeight,
                        padding: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 22),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 14, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt_rounded, color: Colors.white, size: isSmall ? 15 : 17),
                            SizedBox(width: isSmall ? 4 : 6),
                            Text(
                              'Checkout',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 14, min: 12, max: 16),
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

                SizedBox(height: vs),

                // trust badges — Wrap so they reflow on narrow screens
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: isSmall ? 6 : 8,
                  runSpacing: 4,
                  children: [
                    _trustBadge(Icons.lock_outline_rounded, 'Secure Payment'),
                    _trustBadge(Icons.replay_rounded, '7-Day Returns'),
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

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _summaryRow({
    required String label,
    required String value,
    required Color labelColor,
    required Color valueColor,
    bool valueBold = false,
    IconData? icon,
    Color? iconColor,
    Widget? trailing,
    double fontSize = 13,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: fontSize, color: labelColor, fontFamily: 'SF Pro Display', fontWeight: FontWeight.w500),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          trailing,
        ],
        const Spacer(),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(fontSize: fontSize, color: valueColor, fontFamily: 'SF Pro Display', fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600),
        ),
      ],
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    final isSmall = Responsive.isSmallPhone(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 5 : 7, vertical: isSmall ? 2 : 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: isSmall ? 9.0 : 10.0, fontWeight: FontWeight.w700, color: fg, fontFamily: 'SF Pro Display')),
    );
  }

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
              width: dashW, height: 1.5,
              margin: const EdgeInsets.only(right: gap),
              decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(1)),
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
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF999999), fontFamily: 'SF Pro Display', fontWeight: FontWeight.w500)),
        ],
      );

  // ── Checkout logic ──────────────────────────────────────────────────────────
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
