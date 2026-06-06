import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';
import '../../widgets/app_nav_bar.dart';
import '../../constants/app_constants.dart';
import '../../utils/responsive.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'product_detail_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeContent(),
    CategoriesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          Positioned(
            left: 0,
            right: 0,
            bottom: Responsive.navBarBottom(context),
            child: Center(
              child: AppNavBar(
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ProductService _productService = ProductService();
  String _selectedCategory = 'All';
  final List<String> _categories = AppConstants.categories;
  String _selectedState = 'Tamil Nadu';
  RangeValues _priceRange = const RangeValues(0, 10000);
  String _sortBy = 'Newest';

  static const _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  ];

  static const _categoryItems = [
    ('assets/icon/T-shirt icon.jpg', 'T-Shirt', 'T-Shirt'),
    ('assets/icon/tape_icon.png',    'Tape',    'Tape'),
    ('assets/icon/socks_icon.png',   'Socks',   'Socks'),
    ('assets/icon/shuttlecock_icon.jpg', 'Shuttle', 'Shuttle'),
  ];

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final mq       = MediaQuery.of(ctx);
          final sheetW   = Responsive.modalWidth(ctx);
          final isWide   = sheetW < mq.size.width;
          final keyboardH = mq.viewInsets.bottom;
          final maxH = (mq.size.height - mq.padding.top - keyboardH - 24)
              .clamp(200.0, double.infinity);
          return Padding(
            padding: EdgeInsets.only(bottom: keyboardH),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: sheetW, maxHeight: maxH),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(20),
                      bottom: isWide ? const Radius.circular(20) : Radius.zero,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Header ───────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Filters',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SF Pro Display',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ),
                      // ── Scrollable body ───────────────────────────────
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Category',
                                  style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600,
                                    fontFamily: 'SF Pro Display',
                                  )),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8, runSpacing: 8,
                                children: _categories.map((c) => ChoiceChip(
                                  label: Text(c),
                                  selected: _selectedCategory == c,
                                  onSelected: (_) => setModalState(() =>
                                      setState(() => _selectedCategory = c)),
                                  selectedColor: Colors.black,
                                  labelStyle: TextStyle(
                                    color: _selectedCategory == c
                                        ? Colors.white : Colors.black,
                                    fontFamily: 'SF Pro Display',
                                  ),
                                )).toList(),
                              ),
                              const SizedBox(height: 24),
                              const Text('Price Range',
                                  style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600,
                                    fontFamily: 'SF Pro Display',
                                  )),
                              const SizedBox(height: 8),
                              RangeSlider(
                                values: _priceRange,
                                min: 0, max: 10000, divisions: 100,
                                activeColor: Colors.black,
                                labels: RangeLabels(
                                  '₹${_priceRange.start.round()}',
                                  '₹${_priceRange.end.round()}',
                                ),
                                onChanged: (v) => setModalState(() =>
                                    setState(() => _priceRange = v)),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('₹${_priceRange.start.round()}',
                                      style: const TextStyle(fontFamily: 'SF Pro Display')),
                                  Text('₹${_priceRange.end.round()}',
                                      style: const TextStyle(fontFamily: 'SF Pro Display')),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Text('Sort By',
                                  style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600,
                                    fontFamily: 'SF Pro Display',
                                  )),
                              const SizedBox(height: 12),
                              for (final sort in [
                                'Newest', 'Price: Low to High',
                                'Price: High to Low', 'Popular',
                              ])
                                RadioListTile<String>(
                                  title: Text(sort,
                                      style: const TextStyle(fontFamily: 'SF Pro Display')),
                                  value: sort, groupValue: _sortBy,
                                  activeColor: Colors.black,
                                  onChanged: (v) => setModalState(() =>
                                      setState(() => _sortBy = v!)),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // ── Footer buttons ────────────────────────────────
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey[200]!)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setModalState(() => setState(() {
                                  _selectedCategory = 'All';
                                  _priceRange = const RangeValues(0, 10000);
                                  _sortBy = 'Newest';
                                })),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(color: Colors.black),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Reset',
                                    style: TextStyle(
                                      color: Colors.black, fontWeight: FontWeight.w600,
                                      fontFamily: 'SF Pro Display',
                                    )),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Apply',
                                    style: TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.w600,
                                      fontFamily: 'SF Pro Display',
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmall  = Responsive.isSmallPhone(context);
    final vs       = Responsive.vSpacing(context);
    final hp       = Responsive.hPadding(context);
    final titleFs  = Responsive.fontSize(context, 20, min: 16, max: 26);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header ─────────────────────────────────────────────
              _PremiumHeader(
                selectedState: _selectedState,
                onStateChanged: (v) => setState(() => _selectedState = v),
                onNotificationTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => NotificationScreen())),
                onFilterTap: _showFilterDialog,
              ),

              SizedBox(height: vs),

              // ── Banner ─────────────────────────────────────────────
              LayoutBuilder(
                builder: (ctx, constraints) => _CinematicBanner(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => CategoriesScreen())),
                  availableWidth: constraints.maxWidth,
                ),
              ),

              SizedBox(height: vs),

              // ── Categories heading ──────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hp),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: titleFs, fontWeight: FontWeight.w700,
                          fontFamily: 'SF Pro Display',
                          letterSpacing: -0.5, color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => CategoriesScreen())),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 10 : 14,
                          vertical: isSmall ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'See All',
                          style: TextStyle(
                            fontSize: isSmall ? 11.0 : 13.0,
                            color: Colors.white, fontWeight: FontWeight.w600,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: vs),

              // ── Category icons ──────────────────────────────────────
              _CategoryIconRow(
                selectedCategory: _selectedCategory,
                items: _categoryItems,
                onTap: (category) {
                  setState(() => _selectedCategory = category);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => CategoriesScreen(selectedCategory: category)));
                },
              ),

              SizedBox(height: vs),

              // ── Featured Products heading ───────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hp),
                child: Text(
                  'Featured Products',
                  style: TextStyle(
                    fontSize: titleFs, fontWeight: FontWeight.w700,
                    fontFamily: 'SF Pro Display',
                    letterSpacing: -0.5, color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: vs),

              // ── Products Grid ───────────────────────────────────────
              StreamBuilder<List<ProductModel>>(
                stream: _productService.getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: EdgeInsets.all(isSmall ? 24 : 40),
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2.5),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(isSmall ? 24 : 40),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: isSmall ? 44 : 60,
                                color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No products available',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isSmall ? 14.0 : 16.0,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final products = snapshot.data!.take(6).toList();
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: hp),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: Responsive.productGridDelegate(context),
                      itemCount: products.length,
                      itemBuilder: (context, index) => ProductCard(
                        product: products[index],
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                              ProductDetailScreen(product: products[index]))),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: Responsive.navBarClearance(context)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category icon row — extracted widget to isolate layout ─────────────────────
class _CategoryIconRow extends StatelessWidget {
  final String selectedCategory;
  final List<(String, String, String)> items;
  final ValueChanged<String> onTap;

  const _CategoryIconRow({
    required this.selectedCategory,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = Responsive.isSmallPhone(context);
    final hp      = Responsive.hPadding(context);
    final sw      = MediaQuery.of(context).size.width;

    // Icon circle size: proportion of screen width, clamped
    final iconSize  = (sw * (isSmall ? 0.155 : 0.165)).clamp(46.0, 82.0);
    // Label font proportional to icon
    final labelFs   = (iconSize * 0.195).clamp(10.0, 14.0);
    // Gap between label and icon
    final iconTextGap = (iconSize * 0.10).clamp(5.0, 9.0);
    // Total item height with generous buffer to prevent clipping
    final itemH = iconSize + iconTextGap + (labelFs * 2.2);

    // On screens wide enough, show all 4 icons in an evenly-spaced Row
    final useRow = sw >= 400;

    if (useRow) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: hp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((e) => _CategoryIconItem(
                    imagePath: e.$1,
                    label: e.$2,
                    category: e.$3,
                    iconSize: iconSize,
                    labelFs: labelFs,
                    iconTextGap: iconTextGap,
                    isSelected: selectedCategory == e.$3,
                    onTap: onTap,
                  ))
              .toList(),
        ),
      );
    }

    // Narrower screens: horizontal scroll
    final itemGap = (sw * 0.045).clamp(10.0, 22.0);
    return SizedBox(
      height: itemH,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: hp),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: itemGap),
        itemBuilder: (_, i) => _CategoryIconItem(
          imagePath: items[i].$1,
          label: items[i].$2,
          category: items[i].$3,
          iconSize: iconSize,
          labelFs: labelFs,
          iconTextGap: iconTextGap,
          isSelected: selectedCategory == items[i].$3,
          onTap: onTap,
        ),
      ),
    );
  }
}

// ── Single category icon tile ───────────────────────────────────────────────────
class _CategoryIconItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final String category;
  final double iconSize;
  final double labelFs;
  final double iconTextGap;
  final bool isSelected;
  final ValueChanged<String> onTap;

  const _CategoryIconItem({
    required this.imagePath,
    required this.label,
    required this.category,
    required this.iconSize,
    required this.labelFs,
    required this.iconTextGap,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(category),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? Colors.black.withValues(alpha: 0.20)
                      : Colors.black.withValues(alpha: 0.07),
                  blurRadius: isSelected ? 16 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Padding(
                padding: EdgeInsets.all((iconSize * 0.18).clamp(8.0, 15.0)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  color: isSelected ? Colors.white : null,
                  colorBlendMode: isSelected ? BlendMode.srcIn : null,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.category_outlined,
                    size: iconSize * 0.44,
                    color: isSelected ? Colors.white : Colors.black38,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: iconTextGap),
          SizedBox(
            // Label slightly wider than icon so it never clips on normal fonts
            width: iconSize + 12,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: labelFs,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'SF Pro Display',
                color: isSelected ? Colors.black87 : Colors.black45,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Premium Header ──────────────────────────────────────────────────────────────
class _PremiumHeader extends StatelessWidget {
  final String selectedState;
  final ValueChanged<String> onStateChanged;
  final VoidCallback onNotificationTap;
  final VoidCallback onFilterTap;

  const _PremiumHeader({
    required this.selectedState,
    required this.onStateChanged,
    required this.onNotificationTap,
    required this.onFilterTap,
  });

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'GOOD MORNING';
    if (h < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  @override
  Widget build(BuildContext context) {
    final isSmall  = Responsive.isSmallPhone(context);
    final rowGap   = isSmall ? 6.0 : 10.0;
    final innerGap = isSmall ? 10.0 : 14.0;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Color(0x22000000), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      padding: Responsive.headerPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Row 1: greeting + icon buttons ───────────────────────────
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 8 : 10,
                    vertical: isSmall ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8FF57).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFB8FF57).withValues(alpha: 0.30),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isSmall ? 5 : 6,
                        height: isSmall ? 5 : 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFB8FF57), shape: BoxShape.circle),
                      ),
                      SizedBox(width: isSmall ? 4 : 6),
                      Flexible(
                        child: Text(
                          _greeting,
                          style: TextStyle(
                            fontSize: isSmall ? 9.0 : 10.0,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFB8FF57),
                            fontFamily: 'SF Pro Display',
                            letterSpacing: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: rowGap),
              _HeaderIconButton(
                icon: Icons.notifications_outlined,
                onTap: onNotificationTap,
                small: isSmall,
              ),
              SizedBox(width: rowGap),
              _HeaderIconButton(
                icon: Icons.tune_rounded,
                onTap: onFilterTap,
                accent: true,
                small: isSmall,
              ),
            ],
          ),

          SizedBox(height: innerGap),

          // ── Row 2: location + dropdown ────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.place_rounded, color: Color(0xFFB8FF57), size: 18),
              const SizedBox(width: 6),
              Flexible(
                flex: 2,
                child: Text(
                  'Delivering to',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.45),
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 5,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedState,
                    isDense: true,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A1A1A),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white, size: 18),
                    style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      fontFamily: 'SF Pro Display', color: Colors.white,
                    ),
                    onChanged: (v) { if (v != null) onStateChanged(v); },
                    items: _HomeContentState._indianStates
                        .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s, overflow: TextOverflow.ellipsis)))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Header icon button ───────────────────────────────────────────────────────────
class _HeaderIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool accent;
  final bool small;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.accent = false,
    this.small = false,
  });

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg        = widget.accent ? const Color(0xFFB8FF57) : const Color(0xFF1A1A1A);
    final iconColor = widget.accent ? const Color(0xFF0A0A0A) : Colors.white;
    final size      = widget.small ? 34.0 : 40.0;
    final iconSize  = widget.small ? 16.0 : 18.0;

    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: ()  => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: size, height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.accent ? Colors.transparent : const Color(0xFF2A2A2A),
              width: 1,
            ),
            boxShadow: widget.accent
                ? [BoxShadow(
                    color: const Color(0xFFB8FF57).withValues(alpha: 0.30),
                    blurRadius: 12, spreadRadius: -2)]
                : [],
          ),
          child: Icon(widget.icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}

// ── Cinematic Banner ─────────────────────────────────────────────────────────────
class _CinematicBanner extends StatefulWidget {
  final VoidCallback onTap;
  final double availableWidth;

  const _CinematicBanner({required this.onTap, required this.availableWidth});

  @override
  State<_CinematicBanner> createState() => _CinematicBannerState();
}

class _CinematicBannerState extends State<_CinematicBanner> {
  int _current = 0;

  static const _banners = [
    _BannerData(
      image: 'assets/banners/banner 1.png', tag: 'LIMITED OFFER',
      headline: 'FLAT 50% OFF\nTOP COLLECTIONS', cta: 'SHOP NOW',
    ),
    _BannerData(
      image: 'assets/banners/banner 2.png', tag: 'PERFORMANCE GEAR',
      headline: 'HIGH PERFORMANCE.\nLOW PRICES.', cta: 'EXPLORE',
    ),
    _BannerData(
      image: 'assets/banners/banner 3.png', tag: 'MEGA SALE',
      headline: 'SPORTS SALE\nLIVE NOW', cta: 'GRAB DEAL',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLandscape = Responsive.isLandscape(context);
    final mq          = MediaQuery.of(context);
    final bannerH = isLandscape
        ? (mq.size.height * 0.55).clamp(140.0, 220.0)
        : (widget.availableWidth * 0.50).clamp(150.0, 250.0);
    final dotGap = Responsive.isSmallPhone(context) ? 8.0 : 12.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: bannerH,
            autoPlay: true,
            enlargeCenterPage: false,
            viewportFraction: 1.0,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayCurve: Curves.easeInOut,
            onPageChanged: (i, _) => setState(() => _current = i),
          ),
          items: _banners
              .map((b) => _BannerSlide(
                    data: b,
                    onTap: widget.onTap,
                    availableWidth: widget.availableWidth,
                  ))
              .toList(),
        ),
        SizedBox(height: dotGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFFB8FF57)
                    : const Color(0xFFCCCCCC).withValues(alpha: 0.40),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerData {
  final String image, tag, headline, cta;
  const _BannerData({
    required this.image, required this.tag,
    required this.headline, required this.cta,
  });
}

class _BannerSlide extends StatelessWidget {
  final _BannerData data;
  final VoidCallback onTap;
  final double availableWidth;

  const _BannerSlide({
    required this.data, required this.onTap, required this.availableWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall        = Responsive.isSmallPhone(context);
    final hPad           = (availableWidth * 0.045).clamp(12.0, 18.0);
    final headlineFs     = (availableWidth * 0.056).clamp(isSmall ? 14.0 : 16.0, 26.0);
    final bottomAnchor   = isSmall ? 10.0 : 14.0;
    final innerGap       = isSmall ? 4.0 : 5.0;
    final ctaGap         = isSmall ? 6.0 : 8.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(data.image, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFF1A1A1A))),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.20),
                      Colors.black.withValues(alpha: 0.82),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: hPad, right: hPad, bottom: bottomAnchor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.65,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 6 : 8,
                          vertical: isSmall ? 2 : 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8FF57),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          data.tag,
                          style: TextStyle(
                            fontSize: isSmall ? 8.0 : 9.0,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0A0A0A),
                            fontFamily: 'SF Pro Display',
                            letterSpacing: 1.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: innerGap),
                    Text(
                      data.headline,
                      style: TextStyle(
                        fontSize: headlineFs, fontWeight: FontWeight.w900,
                        color: Colors.white, fontFamily: 'SF Pro Display',
                        letterSpacing: -0.5, height: 1.15,
                      ),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ctaGap),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmall ? 10 : 12,
                              vertical: isSmall ? 4 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    data.cta,
                                    style: TextStyle(
                                      fontSize: isSmall ? 10.0 : 11.0,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontFamily: 'SF Pro Display',
                                      letterSpacing: 0.8,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 12, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension WidgetExtension on Widget {
  Widget onTap(VoidCallback onTap) => GestureDetector(onTap: onTap, child: this);
}
