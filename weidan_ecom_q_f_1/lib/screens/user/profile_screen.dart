import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'order_history_screen.dart';
import '../auth/login_screen.dart';
import 'home_screen.dart';
import 'help_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  _loadUser() async {
    UserModel? user = await _authService.getCurrentUser();
    setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _user == null
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nike-style Header
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Profile Card - Nike Style
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : 'U',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'SF Pro Display',
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _user!.name,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'SF Pro Display',
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _user!.email,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                        fontFamily: 'SF Pro Display',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_user!.role == 'admin') ...[
                            SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Text(
                                'ADMIN',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SF Pro Display',
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 40),
                    
                    // Menu Items - Nike Style
                    _buildNikeMenuItem(
                      title: 'Orders',
                      subtitle: 'View your order history',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OrderHistoryScreen()),
                        );
                      },
                    ),
                    
                    SizedBox(height: 24),
                    
                    _buildNikeMenuItem(
                      title: 'Settings',
                      subtitle: 'Manage your preferences',
                      onTap: () {},
                    ),
                    
                    SizedBox(height: 24),
                    
                    _buildNikeMenuItem(
                      title: 'Help',
                      subtitle: 'Get support and assistance',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HelpScreen()),
                        );
                      },
                    ),
                    
                    SizedBox(height: 24),
                    
                    _buildNikeMenuItem(
                      title: 'About',
                      subtitle: 'Learn more about the app',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AboutScreen()),
                        );
                      },
                    ),
                    
                    SizedBox(height: 60),
                    
                    // Logout Button - Nike Style
                    GestureDetector(
                      onTap: _logout,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.black,
                        ),
                        child: Center(
                          child: Text(
                            'SIGN OUT',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'SF Pro Display',
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNikeMenuItem({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    await _authService.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }
}