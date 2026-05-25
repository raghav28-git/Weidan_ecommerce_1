import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'order_history_screen.dart';
import '../auth/login_screen.dart';
import 'home_screen.dart';
import 'help_screen.dart';
import 'about_screen.dart';

// ── Design tokens — matches home / cart / categories palette ─────────────────
const _kBg          = Color(0xFFF5F6F8);   // same as CartScreen scaffold bg
const _kSurface     = Colors.white;         // card / appbar surface
const _kCard        = Colors.white;         // menu card bg
const _kBorder      = Color(0xFFEEEEEE);   // subtle divider
const _kAccent      = Color(0xFF111111);   // primary CTA — same as checkout btn
const _kPrimary     = Color(0xFF0D0D0D);   // heading text
const _kSecondary   = Color(0xFF999999);   // secondary text
const _kMuted       = Color(0xFFBBBBBB);   // muted / footer
const _kRed         = Color(0xFFE53935);   // destructive — same as cart discount
const _kRedBg       = Color(0xFFFFF0F0);
const _kRedBorder   = Color(0xFFFFCDD2);

// ── Smooth page route ──────────────────────────────────────────────────────────
Route<T> _fadeSlideRoute<T>(Widget page) => PageRouteBuilder<T>(
      pageBuilder: (_, a, __) => page,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );

// ── Screen ─────────────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  UserModel? _user;

  late final AnimationController _enterCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 540),
    );
    _fadeAnim  = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
    _loadUser();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (!mounted) return;
    setState(() => _user = user);
    _enterCtrl.forward();
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mq     = MediaQuery.of(context);
    final top    = mq.padding.top;
    final bottom = mq.padding.bottom;
    final sw     = mq.size.width;
    // Responsive horizontal padding: 4 % of width, clamped 16–28
    final hPad   = (sw * 0.04).clamp(16.0, 28.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _kBg,
        body: _user == null
            ? const _LoadingView()
            : FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _StickyAppBar(topPad: top, hPad: hPad, onBack: _goHome),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                            hPad, 8, hPad, bottom + 94),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _ProfileCard(user: _user!),
                            const SizedBox(height: 20),
                            _QuickStats(),
                            const SizedBox(height: 28),
                            const _SectionLabel('Account'),
                            const SizedBox(height: 10),
                            _MenuCard(
                              icon: Icons.receipt_long_rounded,
                              iconColor: const Color(0xFF111111),
                              title: 'My Orders',
                              subtitle: 'Track, return or buy again',
                              onTap: () => Navigator.push(
                                  context, _fadeSlideRoute(OrderHistoryScreen())),
                            ),
                            const SizedBox(height: 8),
                            _MenuCard(
                              icon: Icons.tune_rounded,
                              iconColor: const Color(0xFF111111),
                              title: 'Settings',
                              subtitle: 'Notifications, privacy & more',
                              onTap: () {},
                            ),
                            const SizedBox(height: 28),
                            const _SectionLabel('Support'),
                            const SizedBox(height: 10),
                            _MenuCard(
                              icon: Icons.headset_mic_rounded,
                              iconColor: const Color(0xFF111111),
                              title: 'Help Center',
                              subtitle: 'FAQs and customer support',
                              onTap: () => Navigator.push(
                                  context, _fadeSlideRoute(HelpScreen())),
                            ),
                            const SizedBox(height: 8),
                            _MenuCard(
                              icon: Icons.info_outline_rounded,
                              iconColor: const Color(0xFF111111),
                              title: 'About',
                              subtitle: 'App version and legal info',
                              onTap: () => Navigator.push(
                                  context, _fadeSlideRoute(AboutScreen())),
                            ),
                            const SizedBox(height: 32),
                            _SignOutButton(onTap: _logout),
                            const SizedBox(height: 14),
                            const _FooterLabel(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _goHome() => Navigator.pushReplacement(
      context, _fadeSlideRoute(const HomeScreen()));

  Future<void> _logout() async {
    HapticFeedback.mediumImpact();
    await _authService.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      _fadeSlideRoute(LoginScreen()),
      (_) => false,
    );
  }
}

// ── Loading view ───────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(color: _kAccent, strokeWidth: 2),
      );
}

// ── Sticky sliver app bar ──────────────────────────────────────────────────────
class _StickyAppBar extends StatelessWidget {
  final double topPad;
  final double hPad;
  final VoidCallback onBack;
  const _StickyAppBar({required this.topPad, required this.hPad, required this.onBack});

  @override
  Widget build(BuildContext context) => SliverAppBar(
        backgroundColor: _kBg,
        elevation: 0,
        pinned: true,
        toolbarHeight: 56,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: _CircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _kPrimary,
            fontFamily: 'SF Pro Display',
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      );
}

// ── Circle icon button ─────────────────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _kSurface,
            shape: BoxShape.circle,
            border: Border.all(color: _kBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 15, color: _kPrimary),
        ),
      );
}

// ── Profile card ───────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final UserModel user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final initials    = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';
    final isAdmin     = user.role == 'admin';
    final memberSince = user.createdAt.year.toString();
    final sw          = MediaQuery.of(context).size.width;
    final avatarSize  = (sw * 0.155).clamp(52.0, 72.0);
    final nameSz      = (sw * 0.048).clamp(15.0, 20.0);
    final emailSz     = (sw * 0.030).clamp(11.0, 13.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _kAccent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: avatarSize * 0.38,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0D0D0D),
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: nameSz,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'SF Pro Display',
                        letterSpacing: -0.4,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: emailSz,
                        color: Colors.white.withValues(alpha: 0.65),
                        fontFamily: 'SF Pro Display',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: [
                        _Badge(
                          label: isAdmin ? '⚡ ADMIN' : '★ PREMIUM',
                          bg: Colors.white.withValues(alpha: 0.15),
                          fg: Colors.white,
                        ),
                        _Badge(
                          label: 'Since $memberSince',
                          bg: Colors.white.withValues(alpha: 0.10),
                          fg: Colors.white.withValues(alpha: 0.75),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'SF Pro Display',
                  letterSpacing: 0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_rounded, size: 13, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Badge chip ─────────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Badge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: fg,
            fontFamily: 'SF Pro Display',
            letterSpacing: 0.3,
          ),
        ),
      );
}

// ── Quick stats ────────────────────────────────────────────────────────────────
class _QuickStats extends StatelessWidget {
  // ignore: unused_element
  const _QuickStats();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            _StatItem(value: '12',  label: 'Orders',  icon: Icons.shopping_bag_rounded),
            _vDivider(),
            _StatItem(value: '5',   label: 'Wishlist', icon: Icons.favorite_rounded),
            _vDivider(),
            _StatItem(value: '3',   label: 'Coupons',  icon: Icons.local_offer_rounded),
            _vDivider(),
            _StatItem(value: '840', label: 'Points',   icon: Icons.bolt_rounded),
          ],
        ),
      );

  Widget _vDivider() => Container(width: 1, height: 36, color: _kBorder);
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatItem({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: _kAccent),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _kPrimary,
                  fontFamily: 'SF Pro Display',
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: _kSecondary,
                fontFamily: 'SF Pro Display',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
}

// ── Section label ──────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _kMuted,
          fontFamily: 'SF Pro Display',
          letterSpacing: 1.5,
        ),
      );
}

// ── Menu card ──────────────────────────────────────────────────────────────────
class _MenuCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown:   (_) => setState(() => _pressed = true),
        onTapUp:     (_) => setState(() => _pressed = false),
        onTapCancel: ()  => setState(() => _pressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: _pressed ? const Color(0xFFF5F5F5) : _kCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _pressed ? 0.04 : 0.06),
                  blurRadius: _pressed ? 4 : 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, size: 19, color: widget.iconColor),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _kPrimary,
                          fontFamily: 'SF Pro Display',
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _kSecondary,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _kBorder),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: _kSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// ── Sign out button ────────────────────────────────────────────────────────────
class _SignOutButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SignOutButton({required this.onTap});

  @override
  State<_SignOutButton> createState() => _SignOutButtonState();
}

class _SignOutButtonState extends State<_SignOutButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown:   (_) => setState(() => _pressed = true),
        onTapUp:     (_) => setState(() => _pressed = false),
        onTapCancel: ()  => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _pressed ? const Color(0xFFFFEBEE) : _kRedBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kRedBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.logout_rounded, size: 15, color: _kRed),
                SizedBox(width: 8),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kRed,
                    fontFamily: 'SF Pro Display',
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// ── Footer ─────────────────────────────────────────────────────────────────────
class _FooterLabel extends StatelessWidget {
  const _FooterLabel();
  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          'Weidan © 2025',
          style: const TextStyle(
            fontSize: 11,
            color: _kMuted,
            fontFamily: 'SF Pro Display',
            letterSpacing: 0.5,
          ),
        ),
      );
}
