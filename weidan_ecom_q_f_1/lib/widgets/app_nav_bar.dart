import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Nav item model ──────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

// ── Palette ─────────────────────────────────────────────────────────────────────
const _kNeon  = Color(0xFFB8FF57);  // lime-green accent
const _kGlass = Color(0xE8181C20);  // 91% opaque dark charcoal

// ── Dimensions ──────────────────────────────────────────────────────────────────
const _pillH   = 58.0;
const _activeH = 38.0;
const _activeW = 54.0;

const _items = [
  _NavItem(icon: Icons.home_outlined,          activeIcon: Icons.home_rounded,         label: 'Home'),
  _NavItem(icon: Icons.grid_view_outlined,     activeIcon: Icons.grid_view_rounded,    label: 'Shop'),
  _NavItem(icon: Icons.shopping_bag_outlined,  activeIcon: Icons.shopping_bag_rounded, label: 'Cart'),
  _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,       label: 'Profile'),
];

class AppNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<AppNavBar> createState() => _AppNavBarState();
}

class _AppNavBarState extends State<AppNavBar> with TickerProviderStateMixin {
  late AnimationController _pillCtrl;
  late Animation<double>   _pillAnim;

  late AnimationController _squishCtrl;
  late Animation<double>   _squishAnim;

  late AnimationController _entranceCtrl;
  late Animation<double>   _entranceAnim;

  late AnimationController _bobCtrl;
  late Animation<double>   _bobAnim;

  late AnimationController _glowCtrl;
  late Animation<double>   _glowAnim;

  late List<AnimationController> _pressCtrl;
  late List<Animation<double>>   _pressAnim;

  int _prevIndex = 0;

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.currentIndex;

    _pillCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 340));
    _pillAnim = CurvedAnimation(parent: _pillCtrl, curve: Curves.easeOutCubic);

    _squishCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 340));
    _squishAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.28), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.28, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _squishCtrl, curve: Curves.easeInOutCubic));

    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
    _entranceAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutBack);
    _entranceCtrl.forward();

    _bobCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _bobAnim = Tween<double>(begin: 0, end: -3).animate(
      CurvedAnimation(parent: _bobCtrl, curve: Curves.easeOutBack),
    );
    _bobCtrl.forward();

    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.45, end: 0.75).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _pressCtrl = List.generate(
      _items.length,
      (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 100)),
    );
    _pressAnim = _pressCtrl.map((c) =>
      Tween<double>(begin: 1.0, end: 0.82).animate(
        CurvedAnimation(parent: c, curve: Curves.easeOut),
      ),
    ).toList();
  }

  @override
  void didUpdateWidget(AppNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _prevIndex = old.currentIndex;
      _pillCtrl.forward(from: 0);
      _squishCtrl.forward(from: 0);
      _bobCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pillCtrl.dispose();
    _squishCtrl.dispose();
    _entranceCtrl.dispose();
    _bobCtrl.dispose();
    _glowCtrl.dispose();
    for (final c in _pressCtrl) c.dispose();
    super.dispose();
  }

  void _onTapDown(int i) => _pressCtrl[i].forward();
  void _onTapUp(int i)   => _pressCtrl[i].reverse();

  void _onTap(int i) {
    if (widget.currentIndex == i) return;
    HapticFeedback.selectionClick();
    widget.onTap(i);
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    // Pill width: full width minus 48px total side margin (24px each side)
    final pillW = (screenW - 48).clamp(280.0, 400.0);
    final itemW = pillW / _items.length;

    return AnimatedBuilder(
      animation: _entranceAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, 32 * (1 - _entranceAnim.value)),
        child: Opacity(opacity: _entranceAnim.value.clamp(0.0, 1.0), child: child),
      ),
      child: SizedBox(
        height: _pillH,
        width: pillW,
        child: Stack(
          clipBehavior: Clip.none,
          children: [

            // ── Dark charcoal glassmorphism shell ──────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(_pillH / 2),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: _pillH,
                  decoration: BoxDecoration(
                    color: _kGlass,
                    borderRadius: BorderRadius.circular(_pillH / 2),
                    border: Border.all(
                      // Thin white rim — premium edge definition on dark glass
                      color: Colors.white.withValues(alpha: 0.10),
                      width: 1,
                    ),
                    boxShadow: [
                      // Deep ambient shadow — primary floating depth
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.55),
                        blurRadius: 36,
                        spreadRadius: -4,
                        offset: const Offset(0, 14),
                      ),
                      // Tight contact shadow — secondary depth layer
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 10,
                        spreadRadius: -2,
                        offset: const Offset(0, 4),
                      ),
                      // Neon ambient upward bleed
                      BoxShadow(
                        color: _kNeon.withValues(alpha: 0.07),
                        blurRadius: 44,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Sliding + squishing neon active pill ───────────────────────
            AnimatedBuilder(
              animation: Listenable.merge([_pillAnim, _squishAnim, _glowAnim]),
              builder: (_, __) {
                final fromX  = _prevIndex * itemW + (itemW - _activeW) / 2;
                final toX    = widget.currentIndex * itemW + (itemW - _activeW) / 2;
                final x      = _lerpDouble(fromX, toX, _pillAnim.value);
                final top    = (_pillH - _activeH) / 2;
                final scaleX = _squishAnim.value;
                final glow   = _glowAnim.value;

                return Positioned(
                  left: x,
                  top: top,
                  child: Transform.scale(
                    scaleX: scaleX,
                    scaleY: 1.0,
                    child: Container(
                      width: _activeW,
                      height: _activeH,
                      decoration: BoxDecoration(
                        color: _kNeon,
                        borderRadius: BorderRadius.circular(_activeH / 2),
                        boxShadow: [
                          BoxShadow(
                            color: _kNeon.withValues(alpha: glow),
                            blurRadius: 16,
                            spreadRadius: -1,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: _kNeon.withValues(alpha: glow * 0.40),
                            blurRadius: 30,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── Icons with press + bob ─────────────────────────────────────
            Row(
              children: List.generate(_items.length, (i) {
                final isActive = widget.currentIndex == i;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown:   (_) => _onTapDown(i),
                    onTapUp:     (_) { _onTapUp(i); _onTap(i); },
                    onTapCancel: ()  => _onTapUp(i),
                    child: SizedBox(
                      height: _pillH,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_pressAnim[i], _bobAnim]),
                        builder: (_, __) {
                          final press = _pressAnim[i].value;
                          final bobY  = isActive ? _bobAnim.value : 0.0;
                          return Transform.translate(
                            offset: Offset(0, bobY),
                            child: Transform.scale(
                              scale: press,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, anim) => ScaleTransition(
                                  scale: Tween<double>(begin: 0.75, end: 1.0).animate(
                                    CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                                  ),
                                  child: FadeTransition(opacity: anim, child: child),
                                ),
                                child: Icon(
                                  isActive ? _items[i].activeIcon : _items[i].icon,
                                  key: ValueKey(isActive),
                                  size: 24,
                                  color: isActive
                                      ? const Color(0xFF0D0D0D)   // deep charcoal on neon pill
                                      : const Color(0xFF6B7280),  // soft cool-gray on dark glass
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              }),
            ),

          ],
        ),
      ),
    );
  }
}

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
