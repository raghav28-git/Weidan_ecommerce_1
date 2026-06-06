import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cart_model.dart';
import '../utils/responsive.dart';

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
    final sw      = MediaQuery.of(context).size.width;
    final imgSize = (sw * 0.26).clamp(88.0, 120.0);
    final isSmall = Responsive.isSmallPhone(context);
    final cardPad = isSmall ? 10.0 : 12.0;

    return FadeTransition(
      opacity: _removeFade,
      child: SizeTransition(
        sizeFactor: _removeFade,
        axisAlignment: -1,
        child: Padding(
          padding: EdgeInsets.only(bottom: isSmall ? 10 : 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(cardPad),
              child: Column(
                children: [
                  _buildTopRow(imgSize, isSmall),
                  SizedBox(height: isSmall ? 10 : 12),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF2F2F2)),
                  SizedBox(height: isSmall ? 10 : 12),
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
  Widget _buildTopRow(double imgSize, bool isSmall) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImage(imgSize),
        SizedBox(width: isSmall ? 10 : 12),
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
    final sw   = MediaQuery.of(context).size.width;
    final nameFs  = (sw * 0.036).clamp(12.0, 14.0);
    final priceFs = (sw * 0.042).clamp(14.0, 16.0);
    final metaFs  = (sw * 0.028).clamp(10.0, 11.0);
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
                style: TextStyle(
                  fontSize: nameFs,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111111),
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
            Icon(Icons.star_rounded, color: const Color(0xFFFFA000), size: metaFs + 1),
            const SizedBox(width: 3),
            Text(
              item.rating.toStringAsFixed(1),
              style: TextStyle(fontSize: metaFs, fontWeight: FontWeight.w700, color: const Color(0xFF555555), fontFamily: 'SF Pro Display'),
            ),
            const SizedBox(width: 6),
            Container(width: 1, height: 10, color: const Color(0xFFE0E0E0)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Weidan Sports',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: metaFs, color: const Color(0xFFAAAAAA), fontFamily: 'SF Pro Display'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Size chip
        if (item.size != null) ...[
          _pill('Size  ${item.size}', const Color(0xFFF2F2F2), const Color(0xFF444444),
              fontSize: metaFs, fontWeight: FontWeight.w600),
          const SizedBox(height: 8),
        ],

        // Price row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                '₹${item.price.toStringAsFixed(0)}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: priceFs, fontWeight: FontWeight.w800, color: const Color(0xFF111111), fontFamily: 'SF Pro Display', height: 1.0),
              ),
            ),
            if (item.hasDiscount) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '₹${item.originalPrice!.toStringAsFixed(0)}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: metaFs + 1, color: const Color(0xFFBBBBBB), decoration: TextDecoration.lineThrough, decorationColor: const Color(0xFFBBBBBB), fontFamily: 'SF Pro Display'),
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
          style: TextStyle(
            fontSize: (MediaQuery.of(context).size.width * 0.045).clamp(15.0, 20.0),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111111),
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
    final size = Responsive.isSmallPhone(context) ? 28.0 : 32.0;
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
          width: size,
          height: size,
          alignment: Alignment.center,
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
    final sw      = MediaQuery.of(context).size.width;
    final btnSize = (sw * 0.095).clamp(34.0, 44.0);
    final qtyFs   = (sw * 0.034).clamp(12.0, 14.0);
    final iconSz  = (sw * 0.04).clamp(14.0, 16.0);
    return Container(
      height: btnSize,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(
            icon: quantity == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
            color: quantity == 1 ? const Color(0xFFE53935) : const Color(0xFF333333),
            size: btnSize,
            iconSize: iconSz,
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
              width: btnSize * 0.85,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: qtyFs,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111111),
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),
          ),
          _Btn(
            icon: Icons.add_rounded,
            color: const Color(0xFF333333),
            size: btnSize,
            iconSize: iconSz,
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
  final double size;
  final double iconSize;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.color, required this.size, required this.iconSize, required this.onTap});

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
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
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
          child: Icon(widget.icon, size: widget.iconSize, color: widget.color),
        ),
      ),
    );
  }
}
