import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/responsive.dart';
import 'manage_products_screen.dart';
import 'view_orders_screen.dart';
import 'manage_inventory_screen.dart';
import '../auth/login_screen.dart';

const _kNeon = Color(0xFFB5FF4D);

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ManageProductsScreen(),
    ViewOrdersScreen(),
    ManageInventoryScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.grid_view_rounded, label: 'Products'),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
    _NavItem(icon: Icons.inventory_2_rounded, label: 'Inventory'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: _buildHeader(context),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hp = Responsive.hPadding(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0A0A), Color(0xFF1C1C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hp, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _kNeon, width: 2),
                  color: const Color(0xFF2A2A2A),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded,
                    color: _kNeon, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                              color: _kNeon, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'ADMIN PANEL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _kNeon,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Weidan Sports',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _logout,
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.12), width: 1),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final sw = MediaQuery.of(context).size.width;
    // Cap pill width on tablets so it doesn't stretch edge-to-edge
    final pillW = (sw - 32).clamp(0.0, 480.0);
    return Center(
      child: Container(
        margin: EdgeInsets.fromLTRB(16, 0, 16, 20 + bottomInset),
        width: pillW,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_navItems.length, (i) {
            final selected = _currentIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _currentIndex = i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? _kNeon : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _navItems[i].icon,
                      color: selected ? Colors.black : Colors.grey[500],
                      size: 22,
                    ),
                    if (selected) ...[
                      const SizedBox(width: 7),
                      Text(
                        _navItems[i].label,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void _logout() async {
    await _authService.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
