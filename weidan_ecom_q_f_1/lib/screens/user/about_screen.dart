import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Logo Section
              Container(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/Logo1.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'WEIDAN',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'SF Pro Display',
                        letterSpacing: 4,
                      ),
                    ),
                    Text(
                      'BADMINTON GEAR',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                        fontFamily: 'SF Pro Display',
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Mission Section
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Mission',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Where Passion Meets Performance. We provide premium badminton equipment to help players at every level achieve their best game.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontFamily: 'SF Pro Display',
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Features Grid
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildFeatureCard(
                      icon: Icons.verified,
                      title: 'Premium Quality',
                      description: 'Professional grade equipment',
                    ),
                    _buildFeatureCard(
                      icon: Icons.local_shipping,
                      title: 'Fast Delivery',
                      description: 'Quick & secure shipping',
                    ),
                    _buildFeatureCard(
                      icon: Icons.support_agent,
                      title: '24/7 Support',
                      description: 'Always here to help',
                    ),
                    _buildFeatureCard(
                      icon: Icons.star,
                      title: 'Top Brands',
                      description: 'Trusted by professionals',
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 40),
              
              // Stats Section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[900]!, Colors.black],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('1000+', 'Products'),
                    _buildStatItem('50K+', 'Customers'),
                    _buildStatItem('99%', 'Satisfaction'),
                  ],
                ),
              ),
              
              SizedBox(height: 40),
              
              // Contact Section
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Get in Touch',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildContactItem(Icons.email, 'harishraghav928@gmail.com'),
                    _buildContactItem(Icons.phone, '+91 6380120787'),
                    _buildContactItem(Icons.location_on, 'TamilNadu, India'),
                  ],
                ),
              ),
              
              SizedBox(height: 40),
              
              // Footer
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '© 2024 Weidan. All rights reserved.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'SF Pro Display',
                        fontSize: 12,
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: Colors.black),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'SF Pro Display',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontFamily: 'SF Pro Display',
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'SF Pro Display',
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
            fontFamily: 'SF Pro Display',
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 20),
          SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontFamily: 'SF Pro Display',
            ),
          ),
        ],
      ),
    );
  }
}