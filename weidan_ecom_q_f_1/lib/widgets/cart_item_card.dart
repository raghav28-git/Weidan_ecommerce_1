import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cart_model.dart';

const _kImageMap = {
  '2.0 air shuttle':       'assets/products_image/2.0 Air Shuttle.jpg',
  'flight wing 350':       'assets/products_image/Flight Wing 350.jpg',
  'kinesiology tape':      'assets/products_image/kinesiology Tape.jpg',
  'mult 2 feather shuttle':'assets/products_image/MULT 2 Feather shuttle.jpg',
  'weidan t-shirt':        'assets/products_image/Weidan T-Shirt.jpg',
};

String? _resolveAsset(String name) => _kImageMap[name.trim().toLowerCase()];

class CartItemCard extends StatefulWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _removeCtrl;
  late final Animation<double> _removeFade;

  @override
  void initState() {
    super.initState();
    _removeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: 1,
    );
    _removeFade = CurvedAnimation(parent: _removeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _removeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRemove() async {
    HapticFeedback.lightImpact();
    await _removeCtrl.reverse();
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final imgSize = (sw * 0.26).clamp(96.0, 120.0);

    return FadeTransition(
      opacity: _removeFade,
      child: SizeTransition(
        sizeFactor: _removeFade,
        axisAlignment: -1,
        child: Padding(
          // 8pt bottom margin
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000), // 5% black — very soft
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildTopRow(imgSize),
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF2F2F2)),
                  const SizedBox(height: 12),
                  _buildBottomRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Top row: image + info ──────────────────────────────────────────────────
  Widget _buildTopRow(double imgSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImage(imgSize),
        const SizedBox(width: 12),
        Expanded(child: _buildInfo()),
      ],
    );
  }

  // ── Product image ──────────────────────────────────────────────────────────
  Widget _buildImage(double size) {
    final assetPath = _resolveAsset(widget.cartItem.productName);
    final Widget img = assetPath != null
        ? Image.asset(assetPath, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder())
        : CachedNetworkImage(
            imageUrl: widget.cartItem.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => _placeholder(),
            errorWidget: (_, __, ___) => _placeholder(),
          );

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: img,
          ),
        ),
        if (widget.cartItem.hasDiscount)
          Positioned(
            top: 6,
            left: 6,
            child: _pill(
              '${widget.cartItem.discountPercent}% OFF',
              const Color(0xFFFF3B30),
              Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _placeholder() => const ColoredBox(
        color: Color(0xFFF0F1F3),
        child: Center(
          child: Icon(Icons.image_outlined, color: Color(0xFFD0D0D0), size: 28),
        ),
      );

  // ── Info column ────────────────────────────────────────────────────────────
  Widget _buildInfo() {
    final item = widget.cartItem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name + delete
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                  fontFamily: 'SF Pro Display',
                  height: 1.35,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _DeleteButton(onTap: _handleRemove),
          ],
        ),

        const SizedBox(height: 6),

        // Brand + rating
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFA000), size: 12),
            const SizedBox(width: 3),
            Text(
              item.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF555555),
                fontFamily: 'SF Pro Display',
              ),
            ),
            const SizedBox(width: 6),
            Container(width: 1, height: 10, color: const Color(0xFFE0E0E0)),
            const SizedBox(width: 6),
            const Text(
              'Weidan Sports',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFFAAAAAA),
                fontFamily: 'SF Pro Display',
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Size chip — only when present
        if (item.size != null) ...[
          _pill('Size  ${item.size}', const Color(0xFFF2F2F2), const Color(0xFF444444),
              fontSize: 11, fontWeight: FontWeight.w600),
          const SizedBox(height: 8),
        ],

        // Price row
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '₹${item.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111111),
                fontFamily: 'SF Pro Display',
                height: 1.0,
              ),
            ),
            if (item.hasDiscount) ...[
              const SizedBox(width: 6),
              Text(
                '₹${item.originalPrice!.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFBBBBBB),
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Color(0xFFBBBBBB),
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ── Bottom row: qty + total ────────────────────────────────────────────────
  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _QtySelector(
          quantity: widget.cartItem.quantity,
          onChanged: (q) {
            HapticFeedback.selectionClick();
            widget.onQuantityChanged(q);
          },
        ),
        _buildTotalBlock(),
      ],
    );
  }

  Widget _buildTotalBlock() {
    final item = widget.cartItem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '₹${item.totalPrice.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111111),
            fontFamily: 'SF Pro Display',
            height: 1.0,
          ),
        ),
        if (item.hasDiscount) ...[
          const SizedBox(height: 4),
          _pill(
            'Save ₹${item.totalSavings.toStringAsFixed(0)}',
            const Color(0xFFE8F5E9),
            const Color(0xFF2E7D32),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ],
      ],
    );
  }

  // ── Shared pill badge ──────────────────────────────────────────────────────
  Widget _pill(
    String text,
    Color bg,
    Color fg, {
    double fontSize = 9,
    FontWeight fontWeight = FontWeight.w800,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: fg,
            fontFamily: 'SF Pro Display',
            letterSpacing: 0.1,
          ),
        ),
      );
}

// ── Animated delete button ─────────────────────────────────────────────────
class _DeleteButton extends StatefulWidget {
  final VoidCallback onTap;
  const _DeleteButton({required this.onTap});

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFFE53935),
            size: 15,
          ),
        ),
      ),
    );
  }
}

// ── Quantity selector ──────────────────────────────────────────────────────
class _QtySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  const _QtySelector({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(
            icon: quantity == 1
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            color: quantity == 1
                ? const Color(0xFFE53935)
                : const Color(0xFF333333),
            onTap: () => onChanged(quantity - 1),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: SizedBox(
              key: ValueKey(quantity),
              width: 32,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111),
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),
          ),
          _Btn(
            icon: Icons.add_rounded,
            color: const Color(0xFF333333),
            onTap: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.color, required this.onTap});

  @override
  State<_Btn> createState() => _BtnState();
}

class _BtnState extends State<_Btn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(widget.icon, size: 16, color: widget.color),
        ),
      ),
    );
  }
}
