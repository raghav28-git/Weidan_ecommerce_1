import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';
import '../../constants/app_constants.dart';
import '../../utils/responsive.dart';
import 'product_detail_screen.dart';

// ── Design tokens ────────────────────────────────────────────────────────────────
const _kNeon = Color(0xFFB8FF57);
const _kBg   = Color(0xFFF2F3F5);
const _kDark = Color(0xFF0F0F0F);

class CategoriesScreen extends StatefulWidget {
  final String? selectedCategory;
  const CategoriesScreen({super.key, this.selectedCategory});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ProductService _productService = ProductService();
  late String _selectedCategory;
  final List<String> _categories = AppConstants.categoriesWithAll;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    final hPad            = Responsive.hPadding(context);
    final gridTopPad      = Responsive.vSpacing(context);
    final navbarClearance = Responsive.navBarClearance(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [

            // ── Dark header + chips ────────────────────────────────────────
            _CategoriesHeader(
              selectedCategory: _selectedCategory,
              categories: _categories,
              onCategoryChanged: (c) {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = c);
              },
              onBack: () => Navigator.maybePop(context),
            ),

            // ── Product grid with fade on category switch ──────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve:  Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: StreamBuilder<List<ProductModel>>(
                  key: ValueKey(_selectedCategory),
                  stream: _selectedCategory == 'All'
                      ? _productService.getProducts()
                      : _productService.getProductsByCategory(_selectedCategory),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: _kDark, strokeWidth: 2),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _EmptyState(category: _selectedCategory);
                    }
                    final products = snapshot.data!;
                    return GridView.builder(
                      padding: EdgeInsets.fromLTRB(
                          hPad, gridTopPad, hPad, navbarClearance),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: Responsive.productGridDelegate(context),
                      itemCount: products.length,
                      itemBuilder: (context, index) => ProductCard(
                        product: products[index],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                                product: products[index]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Premium dark header ──────────────────────────────────────────────────────────
class _CategoriesHeader extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onBack;

  const _CategoriesHeader({
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final mq        = MediaQuery.of(context);
    final isSmall   = Responsive.isSmallPhone(context);
    final topPad    = mq.padding.top;
    // Use Responsive helpers — no duplicated clamp logic
    final hPad      = Responsive.hPadding(context);
    final vPad      = Responsive.vSpacing(context);
    final titleSize = Responsive.fontSize(context, 22, min: 17, max: 26);
    final btnSize   = isSmall ? 34.0 : 38.0;
    final chipH     = isSmall ? 34.0 : 38.0;

    return Container(
      decoration: const BoxDecoration(
        color: _kDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(hPad, topPad + vPad, hPad, vPad + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button — fixed square with alignment so icon is centred
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: btnSize,
                  height: btnSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: isSmall ? 13 : 15, color: Colors.white),
                ),
              ),
              SizedBox(width: isSmall ? 10 : 14),
              // Title — Flexible so it never overflows on narrow screens
              Flexible(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Shop ',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'SF Pro Display',
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: 'by Category',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF888888),
                          fontFamily: 'SF Pro Display',
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.vSpacingSmall(context)),
          // Chip row — height derived from chipH so it never clips text
          SizedBox(
            height: chipH,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (_, __) => SizedBox(width: isSmall ? 6 : 8),
              itemBuilder: (context, index) {
                final cat      = categories[index];
                final isActive = cat == selectedCategory;
                return _CategoryChip(
                  label: cat,
                  isActive: isActive,
                  onTap: () => onCategoryChanged(cat),
                  small: isSmall,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category chip ────────────────────────────────────────────────────────────────
class _CategoryChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool small;

  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.small = false,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final hPad    = widget.small ? 12.0 : 16.0;
    final fontSize = widget.small ? 12.0 : 13.0;
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: ()  => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          // Let height be driven by the parent SizedBox, not intrinsic text height
          padding: EdgeInsets.symmetric(horizontal: hPad),
          decoration: BoxDecoration(
            color: widget.isActive ? _kNeon : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: widget.isActive ? _kNeon : const Color(0xFF2E2E2E),
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: _kNeon.withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: -2,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro Display',
                color: widget.isActive
                    ? const Color(0xFF0A0A0A)
                    : const Color(0xFF999999),
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String category;
  const _EmptyState({required this.category});

  @override
  Widget build(BuildContext context) {
    final isSmall  = Responsive.isSmallPhone(context);
    final iconBox  = isSmall ? 56.0 : 72.0;
    final iconSize = isSmall ? 24.0 : 32.0;
    final fs1      = isSmall ? 13.0 : 15.0;
    final fs2      = isSmall ? 11.0 : 13.0;
    return Center(
      child: Padding(
        // Side padding prevents text from touching screen edges on narrow phones
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.hPadding(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconBox,
              height: iconBox,
              decoration: const BoxDecoration(
                color: Color(0xFFE8E9EB),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inventory_2_outlined,
                  size: iconSize, color: const Color(0xFF999999)),
            ),
            SizedBox(height: isSmall ? 12 : 16),
            Text(
              'No products in "$category"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fs1,
                color: const Color(0xFF888888),
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try selecting a different category',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fs2,
                color: const Color(0xFFAAAAAA),
                fontFamily: 'SF Pro Display',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
