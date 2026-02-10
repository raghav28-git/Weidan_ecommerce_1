import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';
import '../../constants/app_constants.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'product_detail_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeContent(),
    CategoriesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.055;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        width: iconSize.clamp(40, 55),
        height: iconSize.clamp(40, 55),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.white,
          size: (iconSize * 0.5).clamp(20, 28),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final margin = screenWidth * 0.04;
          final height = screenWidth * 0.15;
          
          return Container(
            margin: EdgeInsets.all(margin.clamp(12, 24)),
            height: height.clamp(60, 80),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(height.clamp(60, 80) / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.home_rounded, 0),
                _buildNavItem(Icons.grid_view_rounded, 1),
                _buildNavItem(Icons.shopping_bag_rounded, 2),
                _buildNavItem(Icons.person_rounded, 3),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ProductService _productService = ProductService();
  String _selectedCategory = 'All';
  final List<String> _categories = AppConstants.categories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final padding = screenWidth * 0.04;
                  final fontSize = screenWidth * 0.035;
                  final iconSize = screenWidth * 0.055;
                  
                  return Container(
                    padding: EdgeInsets.all(padding.clamp(14, 20)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: iconSize.clamp(20, 26)),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Text(
                            'TamilNadu, India',
                            style: TextStyle(
                              fontSize: fontSize.clamp(13, 16),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SF Pro Display',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.notifications_outlined, color: Colors.black, size: iconSize.clamp(20, 24)),
                        ).onTap(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NotificationScreen()),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
              
              // Search Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final padding = screenWidth * 0.04;
                  final fontSize = screenWidth * 0.038;
                  
                  return Container(
                    padding: EdgeInsets.all(padding.clamp(14, 20)),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: padding.clamp(14, 18),
                              vertical: padding.clamp(12, 16),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.grey[600], size: (screenWidth * 0.055).clamp(20, 26)),
                                SizedBox(width: screenWidth * 0.025),
                                Text(
                                  'Search products...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: fontSize.clamp(14, 17),
                                    fontFamily: 'SF Pro Display',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.025),
                        Container(
                          padding: EdgeInsets.all((screenWidth * 0.03).clamp(12, 16)),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black, Colors.grey[800]!],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.tune, color: Colors.white, size: (screenWidth * 0.055).clamp(20, 26)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              SizedBox(height: 20),
              
              // Promotional Banner
              LayoutBuilder(
                builder: (context, constraints) {
                  final bannerHeight = constraints.maxWidth * 0.45;
                  return CarouselSlider(
                    options: CarouselOptions(
                      height: bannerHeight.clamp(160, 240),
                      autoPlay: true,
                      enlargeCenterPage: false,
                      viewportFraction: 1.0,
                      autoPlayInterval: Duration(seconds: 4),
                      autoPlayCurve: Curves.easeInOut,
                    ),
                    items: [
                      _buildPromoBanner('New Collection', 'Discount 50% for the first transaction', Colors.black),
                      _buildPromoBanner('Free Shipping', 'Orders over \$50', Colors.deepPurple),
                      _buildPromoBanner('Summer Sale', 'Up to 70% OFF', Colors.indigo),
                    ],
                  );
                },
              ),
              
              SizedBox(height: 28),
              
              // Category Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display',
                        letterSpacing: -0.5,
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
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
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
              
              SizedBox(height: 18),
              
              // Category Icons
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final iconSize = screenWidth * 0.16;
                  
                  return SizedBox(
                    height: (iconSize * 1.4).clamp(90, 120),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildCategoryIcon(Icons.checkroom, 'T-Shirt', iconSize),
                        _buildCategoryIcon(Icons.sports_tennis, 'Tape', iconSize),
                        _buildCategoryIcon(Icons.sports, 'Socks', iconSize),
                        _buildCategoryIcon(Icons.sports_baseball, 'Shuttle', iconSize),
                      ],
                    ),
                  );
                },
              ),
              
              SizedBox(height: 28),
              
              // Featured Products
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Featured Products',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SF Pro Display',
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              
              SizedBox(height: 18),
              
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

  Widget _buildCategoryIcon(IconData icon, String label, double size) {
    return Padding(
      padding: EdgeInsets.only(right: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size.clamp(65, 85),
            height: size.clamp(65, 85),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: (size * 0.4).clamp(26, 38), color: Colors.black),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: (size * 0.14).clamp(11, 14),
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro Display',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(String title, String subtitle, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final padding = screenWidth * 0.045;
        final titleSize = screenWidth * 0.058;
        final subtitleSize = screenWidth * 0.034;
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoriesScreen()),
            );
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(padding.clamp(16, 28)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleSize.clamp(20, 28),
                      fontWeight: FontWeight.w900,
                      fontFamily: 'SF Pro Display',
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: subtitleSize.clamp(12, 16),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'SF Pro Display',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 14),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: (screenWidth * 0.04).clamp(14, 20),
                      vertical: (screenWidth * 0.02).clamp(8, 12),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Shop Now',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: subtitleSize.clamp(12, 16),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
