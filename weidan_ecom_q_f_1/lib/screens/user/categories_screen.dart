import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';
import '../../constants/app_constants.dart';
import 'product_detail_screen.dart';
import 'home_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final String? selectedCategory;
  
  const CategoriesScreen({Key? key, this.selectedCategory}) : super(key: key);
  
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          'Categories',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Category Header
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final padding = screenWidth * 0.045;
              final fontSize = screenWidth * 0.042;
              final pillHeight = screenWidth * 0.11;
              
              return Container(
                padding: EdgeInsets.all(padding.clamp(16, 24)),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shop by Category',
                      style: TextStyle(
                        fontSize: fontSize.clamp(16, 20),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.035),
                    // Category Tabs
                    Container(
                      height: pillHeight.clamp(45, 55),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          String category = _categories[index];
                          bool isSelected = _selectedCategory == category;
                          
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = category),
                            child: Container(
                              margin: EdgeInsets.only(right: screenWidth * 0.025),
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.045,
                                vertical: screenWidth * 0.025,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: isSelected ? Colors.black : Colors.grey[300]!,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                    fontSize: (fontSize * 0.85).clamp(13, 16),
                                    fontFamily: 'SF Pro Display',
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Products Grid
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _selectedCategory == 'All'
                  ? _productService.getProducts()
                  : _productService.getProductsByCategory(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No products in this category',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                List<ProductModel> products = snapshot.data!;
                
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final crossAxisCount = screenWidth > 600 ? 3 : 2;
                    final spacing = screenWidth * 0.035;
                    final padding = screenWidth * 0.045;
                    
                    return GridView.builder(
                      padding: EdgeInsets.all(padding.clamp(16, 24)),
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}