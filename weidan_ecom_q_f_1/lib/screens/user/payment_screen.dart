import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import 'home_screen.dart';

class PaymentScreen extends StatefulWidget {
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double tax;
  final double grandTotal;
  final VoidCallback? onOrderSuccess; // clears cart for cart-checkout

  const PaymentScreen({
    Key? key,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.tax,
    required this.grandTotal,
    this.onOrderSuccess,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _AddressData {
  String name;
  String phone;
  String line1;
  String city;
  String pincode;
  _AddressData({
    this.name = '',
    this.phone = '',
    this.line1 = '',
    this.city = '',
    this.pincode = '',
  });
  bool get isComplete =>
      name.isNotEmpty &&
      phone.isNotEmpty &&
      line1.isNotEmpty &&
      city.isNotEmpty &&
      pincode.isNotEmpty;
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _orderService = OrderService();
  final _address = _AddressData();

  int _selectedPayment = 0; // 0=UPI 1=Card 2=COD
  bool _placing = false;

  // ── Coupon state ──────────────────────────────────────────────────────────────────
  static const _kCoupons = {
    'WEIDAN10': 0.10,
    'SPORT20': 0.20,
    'FIRST15': 0.15,
  };
  final _couponCtrl = TextEditingController();
  String? _appliedCoupon;
  double _couponRate = 0.0;
  String? _couponError;
  bool _couponApplying = false;

  double get _couponDiscount => widget.subtotal * _couponRate;
  double get _effectiveTotal => widget.grandTotal - _couponDiscount;

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill name from Firebase Auth display name
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null) _address.name = user!.displayName!;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        appBar: _buildAppBar(),
        body: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad + 100),
          children: [
            _sectionTitle('Delivery Address', Icons.location_on_rounded),
            const SizedBox(height: 12),
            _addressCard(),
            const SizedBox(height: 20),
            _sectionTitle('Payment Method', Icons.payment_rounded),
            const SizedBox(height: 12),
            _paymentCard(),
            const SizedBox(height: 20),
            _sectionTitle('Order Summary', Icons.receipt_long_rounded),
            const SizedBox(height: 12),
            _summaryCard(),
            const SizedBox(height: 20),
            _sectionTitle('Coupons & Offers', Icons.local_offer_rounded),
            const SizedBox(height: 12),
            _couponCard(),
            const SizedBox(height: 20),
            _trustCard(),
          ],
        ),
        bottomNavigationBar: _buildPlaceOrderBar(bottomPad),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: const Color(0xFFF5F6F8),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: Color(0xFF111111)),
          ),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D0D0D),
            fontFamily: 'SF Pro Display',
            letterSpacing: -0.3,
          ),
        ),
      );

  Widget _sectionTitle(String title, IconData icon) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D0D0D),
              fontFamily: 'SF Pro Display',
              letterSpacing: -0.2,
            ),
          ),
        ],
      );

  // ── Saved address card ──────────────────────────────────────────────────────
  Widget _addressCard() {
    final filled = _address.isComplete;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header bar ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF111111),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: Colors.white, size: 15),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Deliver to',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _openAddressSheet(),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          filled ? Icons.edit_rounded : Icons.add_rounded,
                          size: 12,
                          color: const Color(0xFF111111),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          filled ? 'Change' : 'Add',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111111),
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: filled ? _addressBody() : _addressEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _addressBody() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + phone row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _address.name.isNotEmpty
                        ? _address.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111111),
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _address.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0D0D0D),
                        fontFamily: 'SF Pro Display',
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.phone_rounded,
                            size: 11, color: Color(0xFF999999)),
                        const SizedBox(width: 4),
                        Text(
                          _address.phone,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF777777),
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Verified badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 10, color: Color(0xFF2E7D32)),
                    SizedBox(width: 3),
                    Text(
                      'Saved',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Dashed divider
          LayoutBuilder(
            builder: (_, c) {
              const dw = 5.0, gap = 4.0;
              final n = (c.maxWidth / (dw + gap)).floor();
              return Row(
                children: List.generate(
                  n,
                  (_) => Container(
                    width: dw,
                    height: 1.5,
                    margin: const EdgeInsets.only(right: gap),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // Address lines
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.home_rounded,
                    size: 14, color: Color(0xFF555555)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _address.line1,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                        fontFamily: 'SF Pro Display',
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_address.city} – ${_address.pincode}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );

  Widget _addressEmptyState() => GestureDetector(
        onTap: _openAddressSheet,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              style: BorderStyle.solid,
            ),
          ),
          child: const Column(
            children: [
              Icon(Icons.add_location_alt_rounded,
                  size: 28, color: Color(0xFFBBBBBB)),
              SizedBox(height: 8),
              Text(
                'Add a delivery address',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF888888),
                  fontFamily: 'SF Pro Display',
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Tap to enter your address',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFBBBBBB),
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ),
        ),
      );

  // ── Address edit bottom sheet ────────────────────────────────────────────────
  void _openAddressSheet() {
    final nameCtrl = TextEditingController(text: _address.name);
    final phoneCtrl = TextEditingController(text: _address.phone);
    final line1Ctrl = TextEditingController(text: _address.line1);
    final cityCtrl = TextEditingController(text: _address.city);
    final pinCtrl = TextEditingController(text: _address.pincode);
    final sheetFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Form(
              key: sheetFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 10, bottom: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D0D0D),
                      fontFamily: 'SF Pro Display',
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _sheetField(nameCtrl, 'Full Name', Icons.person_outline_rounded)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _sheetField(
                          phoneCtrl, 'Phone', Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              v != null && v.length == 10 ? null : '10 digits',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _sheetField(line1Ctrl, 'Street / Flat / Area', Icons.home_outlined, maxLines: 2),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _sheetField(cityCtrl, 'City', Icons.location_city_outlined)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _sheetField(
                          pinCtrl, 'Pincode', Icons.pin_drop_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v != null && v.length == 6 ? null : '6 digits',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!sheetFormKey.currentState!.validate()) return;
                        setState(() {
                          _address.name = nameCtrl.text.trim();
                          _address.phone = phoneCtrl.text.trim();
                          _address.line1 = line1Ctrl.text.trim();
                          _address.city = cityCtrl.text.trim();
                          _address.pincode = pinCtrl.text.trim();
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111111),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Save Address',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'SF Pro Display',
          color: Color(0xFF0D0D0D),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFFAAAAAA),
              fontFamily: 'SF Pro Display'),
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFF888888)),
          filled: true,
          fillColor: const Color(0xFFF8F8F8),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF111111), width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE53935))),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFE53935), width: 1.5)),
        ),
        validator: validator ??
            (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      );

  // ── Payment method card ─────────────────────────────────────────────────────
  Widget _paymentCard() => Column(
        children: [
          _paymentTile(
            index: 0,
            icon: Icons.account_balance_wallet_rounded,
            iconBg: const Color(0xFFEEF2FF),
            iconColor: const Color(0xFF4F46E5),
            title: 'UPI / Wallets',
            subtitle: 'Instant payment via UPI apps',
            logos: const [_UpiLogo.gpay, _UpiLogo.phonepe, _UpiLogo.paytm],
          ),
          const SizedBox(height: 10),
          _paymentTile(
            index: 1,
            icon: Icons.credit_card_rounded,
            iconBg: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFE65100),
            title: 'Credit / Debit Card',
            subtitle: 'All major cards accepted',
            logos: const [_UpiLogo.visa, _UpiLogo.mastercard],
          ),
          const SizedBox(height: 10),
          _paymentTile(
            index: 2,
            icon: Icons.local_shipping_rounded,
            iconBg: const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF2E7D32),
            title: 'Cash on Delivery',
            subtitle: 'Pay when your order arrives',
            logos: const [],
          ),
        ],
      );

  Widget _paymentTile({
    required int index,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<_UpiLogo> logos,
  }) {
    final selected = _selectedPayment == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPayment = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF111111) : const Color(0xFFEEEEEE),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF111111) : iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: selected ? Colors.white : iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D0D0D),
                          fontFamily: 'SF Pro Display',
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF999999),
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ],
                  ),
                ),
                // Radio indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? const Color(0xFF111111) : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF111111)
                          : const Color(0xFFCCCCCC),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 13)
                      : null,
                ),
              ],
            ),
            // Logo chips — only shown when selected
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: selected && logos.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 1,
                            color: const Color(0xFFF0F0F0),
                            margin: const EdgeInsets.only(bottom: 12),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: logos
                                .map((logo) => _LogoChip(logo: logo))
                                .toList(),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Coupon card ──────────────────────────────────────────────────────────────────
  Widget _couponCard() {
    final applied = _appliedCoupon != null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Input row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: applied
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: applied
                            ? const Color(0xFF2E7D32)
                            : _couponError != null
                                ? const Color(0xFFE53935)
                                : const Color(0xFFEEEEEE),
                        width: applied || _couponError != null ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(
                          applied
                              ? Icons.check_circle_rounded
                              : Icons.confirmation_number_outlined,
                          size: 16,
                          color: applied
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF999999),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _couponCtrl,
                            enabled: !applied,
                            textCapitalization: TextCapitalization.characters,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: applied
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFF0D0D0D),
                              fontFamily: 'SF Pro Display',
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter coupon code',
                              hintStyle: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFBBBBBB),
                                fontFamily: 'SF Pro Display',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 13),
                            ),
                            onChanged: (_) {
                              if (_couponError != null) {
                                setState(() => _couponError = null);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _couponApplying
                      ? null
                      : applied
                          ? _removeCoupon
                          : _applyCoupon,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: applied
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _couponApplying
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              applied ? 'Remove' : 'Apply',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: applied
                                    ? const Color(0xFFE53935)
                                    : Colors.white,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Error message ──────────────────────────────────────────────────
          if (_couponError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 13, color: Color(0xFFE53935)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      _couponError!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE53935),
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Applied savings banner ─────────────────────────────────────────────
          if (applied)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.savings_rounded,
                      size: 15, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'SF Pro Display',
                          color: Color(0xFF2E7D32),
                        ),
                        children: [
                          const TextSpan(
                            text: 'Coupon applied! You save ',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: '₹${_couponDiscount.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text:
                                ' (${(_couponRate * 100).toStringAsFixed(0)}% off)',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Available coupon chips ─────────────────────────────────────────────
          if (!applied) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 14, 14, 8),
              child: Text(
                'AVAILABLE COUPONS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFAAAAAA),
                  fontFamily: 'SF Pro Display',
                  letterSpacing: 0.8,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  _couponChip('WEIDAN10', '10% OFF', 'On all orders'),
                  const SizedBox(width: 8),
                  _couponChip('SPORT20', '20% OFF', 'Sports category'),
                  const SizedBox(width: 8),
                  _couponChip('FIRST15', '15% OFF', 'First order'),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _couponChip(String code, String discount, String desc) =>
      GestureDetector(
        onTap: () {
          _couponCtrl.text = code;
          setState(() => _couponError = null);
          _applyCoupon();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      code,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'SF Pro Display',
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    discount,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D0D0D),
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF999999),
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ),
        ),
      );

  void _applyCoupon() {
    final code = _couponCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _couponError = 'Please enter a coupon code');
      return;
    }
    setState(() {
      _couponApplying = true;
      _couponError = null;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final rate = _kCoupons[code];
      if (rate == null) {
        setState(() {
          _couponError = 'Invalid code. Try WEIDAN10, SPORT20 or FIRST15';
          _couponApplying = false;
        });
      } else {
        HapticFeedback.lightImpact();
        setState(() {
          _appliedCoupon = code;
          _couponRate = rate;
          _couponError = null;
          _couponApplying = false;
        });
      }
    });
  }

  void _removeCoupon() {
    HapticFeedback.selectionClick();
    setState(() {
      _appliedCoupon = null;
      _couponRate = 0.0;
      _couponCtrl.clear();
      _couponError = null;
    });
  }

  // ── Trust card ──────────────────────────────────────────────────────────────────
  Widget _trustCard() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _trustRow(
              icon: Icons.lock_rounded,
              iconBg: const Color(0xFFEEF2FF),
              iconColor: const Color(0xFF4F46E5),
              title: 'Secure Payment',
              subtitle: '256-bit SSL encrypted checkout',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFF2F2F2)),
            ),
            _trustRow(
              icon: Icons.verified_rounded,
              iconBg: const Color(0xFFE8F5E9),
              iconColor: const Color(0xFF2E7D32),
              title: '100% Authentic Products',
              subtitle: 'Sourced directly from brands',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFF2F2F2)),
            ),
            _trustRow(
              icon: Icons.replay_rounded,
              iconBg: const Color(0xFFFFF3E0),
              iconColor: const Color(0xFFE65100),
              title: '7-Day Easy Returns',
              subtitle: 'Hassle-free return & refund policy',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFF2F2F2)),
            ),
            _trustRow(
              icon: Icons.support_agent_rounded,
              iconBg: const Color(0xFFF3E5F5),
              iconColor: const Color(0xFF7B1FA2),
              title: '24/7 Customer Support',
              subtitle: "We're here to help anytime",
            ),
          ],
        ),
      );

  Widget _trustRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) =>
      Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D0D0D),
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: Color(0xFFCCCCCC)),
        ],
      );

  // ── Order summary card ──────────────────────────────────────────────────────
  Widget _summaryCard() {
    final hasSavings = widget.discount > 0;
    final freeShipping = widget.deliveryFee == 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF111111),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded,
                    color: Colors.white, size: 15),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.items.length} ${widget.items.length == 1 ? 'item' : 'items'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── Product rows ───────────────────────────────────────
                ...widget.items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final hasDiscount = item.originalPrice != null &&
                      item.originalPrice! > item.price;
                  return Column(
                    children: [
                      _productRow(item, hasDiscount),
                      if (i < widget.items.length - 1)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                              height: 1,
                              color: Color(0xFFF2F2F2)),
                        )
                      else
                        const SizedBox(height: 16),
                    ],
                  );
                }),

                // ── Dashed divider ─────────────────────────────────────
                _dashedDivider(color: const Color(0xFFE0E0E0)),
                const SizedBox(height: 14),

                // ── Price breakdown ────────────────────────────────────
                _priceRow(
                  label: 'Subtotal',
                  value: '₹${widget.subtotal.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 10),
                _priceRow(
                  label: 'Delivery',
                  value: freeShipping
                      ? 'FREE'
                      : '₹${widget.deliveryFee.toStringAsFixed(0)}',
                  valueColor: freeShipping
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF0D0D0D),
                  valueBold: freeShipping,
                  badge: freeShipping
                      ? _inlineBadge('Free above ₹499',
                          const Color(0xFFE8F5E9), const Color(0xFF2E7D32))
                      : null,
                ),
                if (hasSavings) ...[
                  const SizedBox(height: 10),
                  _priceRow(
                    label: 'Discount',
                    value: '− ₹${widget.discount.toStringAsFixed(0)}',
                    valueColor: const Color(0xFFE53935),
                    leadingIcon: Icons.local_offer_rounded,
                    leadingIconColor: const Color(0xFFE53935),
                  ),
                ],
                const SizedBox(height: 10),
                _priceRow(
                  label: 'Tax (5% GST)',
                  value: '₹${widget.tax.toStringAsFixed(0)}',
                ),

                const SizedBox(height: 14),

                // ── Grand total block ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Payable',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${widget.grandTotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: 'SF Pro Display',
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                      if (hasSavings)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.savings_rounded,
                                  color: Colors.white, size: 13),
                              const SizedBox(width: 5),
                              Text(
                                'Save ₹${widget.discount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'SF Pro Display',
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productRow(OrderItem item, bool hasDiscount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: item.imageUrl != null && item.imageUrl!.isNotEmpty
              ? Image.network(
                  item.imageUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _thumbPlaceholder(),
                )
              : _thumbPlaceholder(),
        ),
        const SizedBox(width: 12),
        // Name + size + qty
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D0D0D),
                  fontFamily: 'SF Pro Display',
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (item.size != null) ...[
                    _metaChip('Size: ${item.size}'),
                    const SizedBox(width: 6),
                  ],
                  _metaChip('Qty: ${item.quantity}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Price column
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${(item.price * item.quantity).toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0D0D0D),
                fontFamily: 'SF Pro Display',
                letterSpacing: -0.2,
              ),
            ),
            if (hasDiscount) ...[
              const SizedBox(height: 2),
              Text(
                '₹${(item.originalPrice! * item.quantity).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFAAAAAA),
                  fontFamily: 'SF Pro Display',
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Color(0xFFAAAAAA),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${(((item.originalPrice! - item.price) / item.originalPrice!) * 100).round()}% off',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE53935),
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _thumbPlaceholder() => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.image_outlined,
            size: 22, color: Color(0xFFCCCCCC)),
      );

  Widget _metaChip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
            fontFamily: 'SF Pro Display',
          ),
        ),
      );

  Widget _priceRow({
    required String label,
    required String value,
    Color valueColor = const Color(0xFF0D0D0D),
    bool valueBold = false,
    IconData? leadingIcon,
    Color? leadingIconColor,
    Widget? badge,
  }) =>
      Row(
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 13, color: leadingIconColor),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF777777),
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w500,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            badge,
          ],
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  valueBold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor,
              fontFamily: 'SF Pro Display',
            ),
          ),
        ],
      );

  Widget _inlineBadge(String text, Color bg, Color fg) => Container(
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

  Widget _dashedDivider({Color color = const Color(0xFFE0E0E0)}) =>
      LayoutBuilder(
        builder: (_, c) {
          const dw = 5.0, gap = 4.0;
          final n = (c.maxWidth / (dw + gap)).floor();
          return Row(
            children: List.generate(
              n,
              (_) => Container(
                width: dw,
                height: 1.5,
                margin: const EdgeInsets.only(right: gap),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          );
        },
      );

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      );

  // ── Place order bottom bar ──────────────────────────────────────────────────
  Widget _buildPlaceOrderBar(double bottomPad) => Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPad + 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                      fontFamily: 'SF Pro Display',
                    )),
                Text(
                  '₹${_effectiveTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0D0D0D),
                    fontFamily: 'SF Pro Display',
                    letterSpacing: -0.4,
                  ),
                ),
                if (_couponDiscount > 0)
                  Text(
                    'Saved ₹${_couponDiscount.toStringAsFixed(0)} with coupon',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: _placing ? null : _placeOrder,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 54,
                  decoration: BoxDecoration(
                    color: _placing
                        ? const Color(0xFF444444)
                        : const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _placing
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.22),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: _placing
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Place Order',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      );

  // ── Place order logic ───────────────────────────────────────────────────────
  Future<void> _placeOrder() async {
    if (!_address.isComplete) {
      _openAddressSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add a delivery address',
              style: TextStyle(fontFamily: 'SF Pro Display')),
          backgroundColor: const Color(0xFF111111),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _placing = true);
    HapticFeedback.mediumImpact();

    try {
      final order = OrderModel(
        id: '',
        userId: user.uid,
        items: widget.items,
        status: 'pending',
        date: DateTime.now(),
        totalPrice: _effectiveTotal,
      );

      await _orderService.createOrder(order);

      // Collect up to 3 product image URLs for the notification thumbnail strip
      final imageUrls = widget.items
          .where((i) => i.imageUrl != null && i.imageUrl!.isNotEmpty)
          .map((i) => i.imageUrl!)
          .take(3)
          .toList();

      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': user.uid,
        'title': 'Order Placed Successfully!',
        'message':
            '${widget.items.length} item${widget.items.length == 1 ? '' : 's'} · '
            'Total ₹${_effectiveTotal.toStringAsFixed(0)}',
        'timestamp': Timestamp.now(),
        'imageUrls': imageUrls,
        'itemCount': widget.items.length,
        'type': 'order_placed',
      });

      widget.onOrderSuccess?.call();

      if (!mounted) return;
      _showSuccessSheet();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}',
              style: const TextStyle(fontFamily: 'SF Pro Display')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 32, 24, MediaQuery.of(context).padding.bottom + 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFF111111),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 38),
            ),
            const SizedBox(height: 20),
            const Text(
              'Order Placed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0D0D0D),
                fontFamily: 'SF Pro Display',
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your order has been placed successfully.\nWe\'ll notify you once it\'s shipped.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF888888),
                fontFamily: 'SF Pro Display',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                    (_) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
}

// ── Payment logo enum ──────────────────────────────────────────────────────────
enum _UpiLogo { gpay, phonepe, paytm, visa, mastercard }

// ── Logo chip widget ───────────────────────────────────────────────────────────
class _LogoChip extends StatelessWidget {
  final _UpiLogo logo;
  const _LogoChip({required this.logo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _logoIcon(),
          const SizedBox(width: 6),
          Text(
            _label(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
              fontFamily: 'SF Pro Display',
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  String _label() {
    switch (logo) {
      case _UpiLogo.gpay:       return 'GPay';
      case _UpiLogo.phonepe:    return 'PhonePe';
      case _UpiLogo.paytm:      return 'Paytm';
      case _UpiLogo.visa:       return 'Visa';
      case _UpiLogo.mastercard: return 'Mastercard';
    }
  }

  Widget _logoIcon() {
    switch (logo) {
      case _UpiLogo.gpay:
        return _SvgIcon(
          size: 18,
          child: CustomPaint(painter: _GPayPainter()),
        );
      case _UpiLogo.phonepe:
        return _SvgIcon(
          size: 18,
          child: CustomPaint(painter: _PhonePePainter()),
        );
      case _UpiLogo.paytm:
        return _SvgIcon(
          size: 18,
          child: CustomPaint(painter: _PaytmPainter()),
        );
      case _UpiLogo.visa:
        return _SvgIcon(
          size: 18,
          child: CustomPaint(painter: _VisaPainter()),
        );
      case _UpiLogo.mastercard:
        return _SvgIcon(
          size: 18,
          child: CustomPaint(painter: _MastercardPainter()),
        );
    }
  }
}

class _SvgIcon extends StatelessWidget {
  final double size;
  final Widget child;
  const _SvgIcon({required this.size, required this.child});

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: child);
}

// ── GPay painter (G lettermark in brand colours) ───────────────────────────────
class _GPayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.46;

    // White circle bg
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = Colors.white);
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = const Color(0xFFDDDDDD)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8);

    // "G" arc segments — blue top, red left, yellow bottom, green right
    final arcRect =
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.68);
    final segPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round;

    segPaint.color = const Color(0xFF4285F4);
    canvas.drawArc(arcRect, -1.2, 1.6, false, segPaint);
    segPaint.color = const Color(0xFFEA4335);
    canvas.drawArc(arcRect, 0.4, 1.2, false, segPaint);
    segPaint.color = const Color(0xFFFBBC05);
    canvas.drawArc(arcRect, 1.6, 1.2, false, segPaint);
    segPaint.color = const Color(0xFF34A853);
    canvas.drawArc(arcRect, 2.8, 1.0, false, segPaint);

    // Horizontal bar of G
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r * 0.62, cy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── PhonePe painter (purple circle with P) ─────────────────────────────────────
class _PhonePePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.46;

    canvas.drawCircle(
        Offset(cx, cy), r, Paint()..color = const Color(0xFF5F259F));

    final tp = TextPainter(
      text: const TextSpan(
        text: 'P',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          fontFamily: 'SF Pro Display',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Paytm painter (blue circle with pay text) ─────────────────────────────────
class _PaytmPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.46;

    // Top half blue, bottom half dark blue
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, cy));
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = const Color(0xFF00BAF2));
    canvas.restore();
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, cy, size.width, size.height));
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = const Color(0xFF002970));
    canvas.restore();
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = const Color(0xFFCCCCCC)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5);

    final tp = TextPainter(
      text: const TextSpan(
        text: '₱',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Visa painter (blue rect with VISA text) ────────────────────────────────────
class _VisaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.15, size.width, size.height * 0.7),
      const Radius.circular(3),
    );
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF1A1F71));

    final tp = TextPainter(
      text: const TextSpan(
        text: 'VISA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 6.5,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        size.width / 2 - tp.width / 2,
        size.height / 2 - tp.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Mastercard painter (two overlapping circles) ───────────────────────────────
class _MastercardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final r = size.height * 0.38;
    final gap = size.width * 0.14;
    final leftCx = size.width / 2 - gap;
    final rightCx = size.width / 2 + gap;

    canvas.drawCircle(
        Offset(leftCx, cy), r, Paint()..color = const Color(0xFFEB001B));
    canvas.drawCircle(
        Offset(rightCx, cy), r,
        Paint()
          ..color = const Color(0xFFF79E1B)
          ..blendMode = BlendMode.srcOver);

    // Overlap blend — orange tint in intersection
    final path = Path()
      ..addOval(Rect.fromCircle(center: Offset(leftCx, cy), radius: r));
    canvas.save();
    canvas.clipPath(path);
    canvas.drawCircle(
        Offset(rightCx, cy), r,
        Paint()
          ..color = const Color(0xFFFF5F00).withOpacity(0.85));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_) => false;
}
