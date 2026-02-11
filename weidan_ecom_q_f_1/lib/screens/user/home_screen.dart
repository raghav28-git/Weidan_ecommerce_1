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
              color: Colors.black.withOpacity(0.9),
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
  String _selectedState = 'Tamil Nadu';
  RangeValues _priceRange = RangeValues(0, 10000);
  String _sortBy = 'Newest';
  
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
                      ...['Newest', 'Price: Low to High', 'Price: High to Low', 'Popular'].map((sort) {
                        return RadioListTile<String>(
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
                        );
                      }).toList(),
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
                    padding: EdgeInsets.all(padding.clamp(16, 22)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Color(0xFFFF5252), size: iconSize.clamp(22, 28)),
                        SizedBox(width: screenWidth * 0.015),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedState,
                            icon: Icon(Icons.arrow_drop_down, color: Colors.black87, size: iconSize.clamp(22, 28)),
                            style: TextStyle(
                              fontSize: fontSize.clamp(13, 16),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SF Pro Display',
                              color: Colors.black87,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedState = newValue!;
                              });
                            },
                            items: _indianStates.map<DropdownMenuItem<String>>((String state) {
                              return DropdownMenuItem<String>(
                                value: state,
                                child: Text(state),
                              );
                            }).toList(),
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.notifications_outlined, color: Colors.black87, size: iconSize.clamp(20, 24)),
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
                    padding: EdgeInsets.only(
                      left: padding.clamp(16, 22),
                      right: padding.clamp(16, 22),
                      top: padding.clamp(12, 16),
                      bottom: padding.clamp(16, 22),
                    ),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: padding.clamp(16, 20),
                              vertical: padding.clamp(14, 18),
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Color(0xFFEEEEEE)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.grey[500], size: (screenWidth * 0.055).clamp(22, 28)),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  'Search products...',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: fontSize.clamp(14, 17),
                                    fontFamily: 'SF Pro Display',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        GestureDetector(
                          onTap: _showFilterDialog,
                          child: Container(
                            padding: EdgeInsets.all((screenWidth * 0.035).clamp(14, 18)),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(Icons.tune, color: Colors.white, size: (screenWidth * 0.055).clamp(22, 28)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              SizedBox(height: 16),
              
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
                    color: Colors.black.withOpacity(0.06),
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
