import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hp      = Responsive.hPadding(context);
    final vs      = Responsive.vSpacing(context);
    final isSmall = Responsive.isSmallPhone(context);
    final sw      = Responsive.screenWidth(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Back button ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hp * 0.5, vertical: isSmall ? 4 : 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    iconSize: isSmall ? 20 : 24,
                  ),
                ),
              ),

              // ── Logo Section ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(vertical: isSmall ? 24 : 40),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/Logo1.png',
                      width:  (sw * 0.28).clamp(80.0, 140.0),
                      height: (sw * 0.28).clamp(80.0, 140.0),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: vs),
                    Text(
                      'WEIDAN',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 32, min: 24, max: 42),
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'SF Pro Display',
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BADMINTON GEAR',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 14, min: 11, max: 18),
                        color: Colors.grey[400],
                        fontFamily: 'SF Pro Display',
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Mission Section ─────────────────────────────────────────
              Container(
                margin:  EdgeInsets.symmetric(horizontal: hp),
                padding: EdgeInsets.all(isSmall ? 20 : 28),
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
                        fontSize: Responsive.fontSize(context, 22, min: 18, max: 28),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    SizedBox(height: isSmall ? 10 : 16),
                    Text(
                      'Where Passion Meets Performance. We provide premium badminton equipment to help players at every level achieve their best game.',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 15, min: 13, max: 18),
                        color: Colors.grey[700],
                        fontFamily: 'SF Pro Display',
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: vs),

              // ── Features Grid ───────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hp),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: Responsive.gridColumns(context).clamp(2, 4),
                  crossAxisSpacing: Responsive.gridSpacing(context),
                  mainAxisSpacing:  Responsive.gridSpacing(context),
                  childAspectRatio: isSmall ? 1.05 : 1.15,
                  children: [
                    _buildFeatureCard(context,
                      icon: Icons.verified,
                      title: 'Premium Quality',
                      description: 'Professional grade equipment',
                    ),
                    _buildFeatureCard(context,
                      icon: Icons.local_shipping,
                      title: 'Fast Delivery',
                      description: 'Quick & secure shipping',
                    ),
                    _buildFeatureCard(context,
                      icon: Icons.support_agent,
                      title: '24/7 Support',
                      description: 'Always here to help',
                    ),
                    _buildFeatureCard(context,
                      icon: Icons.star,
                      title: 'Top Brands',
                      description: 'Trusted by professionals',
                    ),
                  ],
                ),
              ),

              SizedBox(height: vs),

              // ── Stats Section ───────────────────────────────────────────
              Container(
                margin:  EdgeInsets.symmetric(horizontal: hp),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 16 : 24,
                  vertical:   isSmall ? 20 : 28,
                ),
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
                    _buildStatItem(context, '1000+', 'Products'),
                    _buildStatDivider(),
                    _buildStatItem(context, '50K+', 'Customers'),
                    _buildStatDivider(),
                    _buildStatItem(context, '99%', 'Satisfaction'),
                  ],
                ),
              ),

              SizedBox(height: vs),

              // ── Contact Section ─────────────────────────────────────────
              Container(
                margin:  EdgeInsets.symmetric(horizontal: hp),
                padding: EdgeInsets.all(isSmall ? 20 : 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Get in Touch',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 22, min: 18, max: 28),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    SizedBox(height: isSmall ? 14 : 20),
                    _buildContactItem(context, Icons.email,       'harishraghav928@gmail.com'),
                    _buildContactItem(context, Icons.phone,       '+91 6380120787'),
                    _buildContactItem(context, Icons.location_on, 'TamilNadu, India'),
                  ],
                ),
              ),

              SizedBox(height: vs),

              // ── Footer ──────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(hp, 0, hp, vs),
                child: Column(
                  children: [
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 13, min: 11, max: 15),
                        color: Colors.grey[600],
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '© 2024 Weidan. All rights reserved.',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 12, min: 10, max: 14),
                        color: Colors.grey[600],
                        fontFamily: 'SF Pro Display',
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

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSmall = Responsive.isSmallPhone(context);
    final iconSize = isSmall ? 26.0 : 32.0;
    return Container(
      padding: EdgeInsets.all(isSmall ? 10 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: Colors.black),
          SizedBox(height: isSmall ? 6 : 8),
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 13, min: 11, max: 16),
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'SF Pro Display',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmall ? 2 : 4),
          Text(
            description,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 10, min: 9, max: 13),
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

  Widget _buildStatItem(BuildContext context, String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 22, min: 17, max: 30),
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'SF Pro Display',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 12, min: 10, max: 15),
            color: Colors.grey[400],
            fontFamily: 'SF Pro Display',
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() => Container(
        width: 1,
        height: 36,
        color: Colors.grey[700],
      );

  Widget _buildContactItem(BuildContext context, IconData icon, String text) {
    final isSmall = Responsive.isSmallPhone(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 6 : 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: isSmall ? 18 : 20),
          SizedBox(width: isSmall ? 12 : 16),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14, min: 12, max: 17),
                color: Colors.grey[700],
                fontFamily: 'SF Pro Display',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
