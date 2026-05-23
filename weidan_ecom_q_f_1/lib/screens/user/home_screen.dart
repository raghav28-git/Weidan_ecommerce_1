import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';
import '../../widgets/app_nav_bar.dart';
import '../../constants/app_constants.dart';
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

  // Screens are kept alive via AutomaticKeepAliveClientMixin on each child,
  // but using IndexedStack here preserves state across tab switches.
  final List<Widget> _screens = const [
    HomeContent(),
    CategoriesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      // No bottomNavigationBar — navbar floats inside a Stack overlay
      body: Stack(
        children: [
          // ── Page content fills the full screen ──────────────────────────
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          // ── Floating navbar — centred, 24px from each side, 20px above
          //    the home indicator (or 20px from the physical bottom edge) ──
          Positioned(
            left: 24,
            right: 24,
            bottom: (bottomPad > 0 ? bottomPad : 0) + 20,
            child: AppNavBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  String _selectedCategory = 'All';
  final List<String> _categories = AppConstants.categories;
  String _selectedState = 'Tamil Nadu';
  RangeValues _priceRange = RangeValues(0, 10000);
  String _sortBy = 'Newest';

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }
  
  final List<String> _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  ];

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((category) {
                          return ChoiceChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setModalState(() {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              });
                            },
                            selectedColor: Colors.black,
                            labelStyle: TextStyle(
                              color: _selectedCategory == category ? Colors.white : Colors.black,
                              fontFamily: 'SF Pro Display',
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Price Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                      SizedBox(height: 8),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 10000,
                        divisions: 100,
                        activeColor: Colors.black,
                        labels: RangeLabels(
                          '₹${_priceRange.start.round()}',
                          '₹${_priceRange.end.round()}',
                        ),
                        onChanged: (values) {
                          setModalState(() {
                            setState(() {
                              _priceRange = values;
                            });
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('₹${_priceRange.start.round()}', style: TextStyle(fontFamily: 'SF Pro Display')),
                          Text('₹${_priceRange.end.round()}', style: TextStyle(fontFamily: 'SF Pro Display')),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Sort By',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                      SizedBox(height: 12),
                      ...[for (final sort in ['Newest', 'Price: Low to High', 'Price: High to Low', 'Popular'])
                        RadioListTile<String>(
                          title: Text(sort, style: TextStyle(fontFamily: 'SF Pro Display')),
                          value: sort,
                          groupValue: _sortBy,
                          activeColor: Colors.black,
                          onChanged: (value) {
                            setModalState(() {
                              setState(() {
                                _sortBy = value!;
                              });
                            });
                          },
                        )],
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setModalState(() {
                            setState(() {
                              _selectedCategory = 'All';
                              _priceRange = RangeValues(0, 10000);
                              _sortBy = 'Newest';
                            });
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Apply',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Premium Header ───────────────────────────────────────────
              _PremiumHeader(
                selectedState: _selectedState,
                indianStates: _indianStates,
                onStateChanged: (v) => setState(() => _selectedState = v),
                onNotificationTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NotificationScreen()),
                ),
                onFilterTap: _showFilterDialog,
              ),

              const SizedBox(height: 20),

              // ── Cinematic Banner ─────────────────────────────────────────
              _CinematicBanner(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CategoriesScreen()),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Category Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'SF Pro Display',
                        letterSpacing: -0.5,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CategoriesScreen()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Category Icons
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final iconSize = screenWidth * 0.16;
                  
                  return SizedBox(
                    height: (iconSize * 1.4).clamp(95, 125),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      children: [
                        _buildCategoryIcon('assets/icon/T-shirt icon.jpg', 'T-Shirt', iconSize, 'T-Shirt'),
                        _buildCategoryIcon('assets/icon/tape_icon.png', 'Tape', iconSize, 'Tape'),
                        _buildCategoryIcon('assets/icon/socks_icon.png', 'Socks', iconSize, 'Socks'),
                        _buildCategoryIcon('assets/icon/shuttlecock_icon.jpg', 'Shuttle', iconSize, 'Shuttle'),
                      ],
                    ),
                  );
                },
              ),
              
              SizedBox(height: 24),
              
              // Featured Products
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  'Featured Products',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SF Pro Display',
                    letterSpacing: -0.5,
                    color: Colors.black87,
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Products Grid
              StreamBuilder<List<ProductModel>>(
                stream: _productService.getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                      ),
                    );
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
                            SizedBox(height: 12),
                            Text(
                              'No products available',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  List<ProductModel> products = snapshot.data!.take(6).toList();
                  
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final crossAxisCount = screenWidth > 600 ? 3 : 2;
                      final spacing = screenWidth * 0.03;
                      
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: spacing.clamp(12, 18),
                            mainAxisSpacing: spacing.clamp(12, 18),
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return ProductCard(
                              product: products[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(product: products[index]),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
              
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String imagePath, String label, double size, String category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoriesScreen(selectedCategory: category),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size.clamp(68, 88),
              height: size.clamp(68, 88),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: EdgeInsets.all((size * 0.15).clamp(10, 13)),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: (size * 0.14).clamp(12, 15),
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro Display',
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

}

// ── Premium Header ─────────────────────────────────────────────────────────────
class _PremiumHeader extends StatelessWidget {
  final String selectedState;
  final List<String> indianStates;
  final ValueChanged<String> onStateChanged;
  final VoidCallback onNotificationTap;
  final VoidCallback onFilterTap;

  const _PremiumHeader({
    required this.selectedState,
    required this.indianStates,
    required this.onStateChanged,
    required this.onNotificationTap,
    required this.onFilterTap,
  });

  // Derive a time-of-day greeting
  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'GOOD MORNING';
    if (h < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Dark header zone — continuous with the outer 0xFF0A0A0A scaffold
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: greeting label + icon buttons ────────────────────────
          Row(
            children: [
              // Neon greeting chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB8FF57),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _greeting,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB8FF57),
                        fontFamily: 'SF Pro Display',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Notification button
              _HeaderIconButton(
                icon: Icons.notifications_outlined,
                onTap: onNotificationTap,
              ),
              const SizedBox(width: 10),
              // Filter button
              _HeaderIconButton(
                icon: Icons.tune_rounded,
                onTap: onFilterTap,
                accent: true,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Row 2: location pin + state dropdown ───────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.place_rounded,
                color: Color(0xFFB8FF57),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Delivering to',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.45),
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedState,
                    isDense: true,
                    dropdownColor: const Color(0xFF1A1A1A),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SF Pro Display',
                      color: Colors.white,
                    ),
                    onChanged: (v) { if (v != null) onStateChanged(v); },
                    items: indianStates.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s),
                    )).toList(),
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

// ── Small icon button used in the header ────────────────────────────────────────
class _HeaderIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool accent;
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.accent = false,
  });
  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final bg = widget.accent ? const Color(0xFFB8FF57) : const Color(0xFF1A1A1A);
    final iconColor = widget.accent ? const Color(0xFF0A0A0A) : Colors.white;
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: ()  => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.accent
                  ? Colors.transparent
                  : const Color(0xFF2A2A2A),
              width: 1,
            ),
            boxShadow: widget.accent
                ? [
                    BoxShadow(
                      color: const Color(0xFFB8FF57).withValues(alpha: 0.30),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ]
                : [],
          ),
          child: Icon(widget.icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}

// ── Cinematic Banner ────────────────────────────────────────────────────────────
class _CinematicBanner extends StatefulWidget {
  final VoidCallback onTap;
  const _CinematicBanner({required this.onTap});
  @override
  State<_CinematicBanner> createState() => _CinematicBannerState();
}

class _CinematicBannerState extends State<_CinematicBanner> {
  int _current = 0;

  static const _banners = [
    _BannerData(
      image: 'assets/banners/banner 1.png',
      tag:   'LIMITED OFFER',
      headline: 'FLAT 50% OFF\nTOP COLLECTIONS',
      cta:   'SHOP NOW',
    ),
    _BannerData(
      image: 'assets/banners/banner 2.png',
      tag:   'PERFORMANCE GEAR',
      headline: 'HIGH PERFORMANCE.\nLOW PRICES.',
      cta:   'EXPLORE',
    ),
    _BannerData(
      image: 'assets/banners/banner 3.png',
      tag:   'MEGA SALE',
      headline: 'SPORTS SALE\nLIVE NOW',
      cta:   'GRAB DEAL',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final bannerH = (sw * 0.52).clamp(190.0, 260.0);

    return Column(
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
          items: _banners.map((b) => _BannerSlide(data: b, onTap: widget.onTap)).toList(),
        ),
        const SizedBox(height: 12),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width:  active ? 20 : 6,
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
  final String image;
  final String tag;
  final String headline;
  final String cta;
  const _BannerData({
    required this.image,
    required this.tag,
    required this.headline,
    required this.cta,
  });
}

class _BannerSlide extends StatelessWidget {
  final _BannerData data;
  final VoidCallback onTap;
  const _BannerSlide({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Padding(
      // Side margins so the banner floats off the edges
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo
              Image.asset(data.image, fit: BoxFit.cover),

              // Cinematic multi-stop gradient
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

              // Text content
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tag chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8FF57),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data.tag,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A0A0A),
                          fontFamily: 'SF Pro Display',
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Bold headline
                    Text(
                      data.headline,
                      style: TextStyle(
                        fontSize: (sw * 0.056).clamp(20.0, 26.0),
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'SF Pro Display',
                        letterSpacing: -0.5,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // CTA pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            data.cta,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'SF Pro Display',
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 12,
                            color: Colors.white,
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
      ),
    );
  }
}

extension WidgetExtension on Widget {
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: this,
    );
  }
}
