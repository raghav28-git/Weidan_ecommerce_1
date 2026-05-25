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
    final mq              = MediaQuery.of(context);
    final navbarClearance  = Responsive.navBarClearance(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
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
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final hPad = Responsive.hPadding(context);
                        return GridView.builder(
                          padding: EdgeInsets.fromLTRB(
                              hPad, 20, hPad, navbarClearance),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              Responsive.productGridDelegate(context),
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
    final topPad = MediaQuery.of(context).padding.top;
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
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 15, color: Colors.white),
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Shop',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'SF Pro Display',
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'by Category',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF888888),
                  fontFamily: 'SF Pro Display',
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Chip row
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat      = categories[index];
                final isActive = cat == selectedCategory;
                return _CategoryChip(
                  label: cat,
                  isActive: isActive,
                  onTap: () => onCategoryChanged(cat),
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

  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                fontSize: 13,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFE8E9EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_outlined,
                size: 32, color: Color(0xFF999999)),
          ),
          const SizedBox(height: 16),
          Text(
            'No products in "$category"',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF888888),
              fontFamily: 'SF Pro Display',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try selecting a different category',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFAAAAAA),
              fontFamily: 'SF Pro Display',
            ),
          ),
        ],
      ),
    );
  }
}
