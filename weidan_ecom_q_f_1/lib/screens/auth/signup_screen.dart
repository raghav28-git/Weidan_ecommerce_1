import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../user/home_screen.dart';
import '../admin/admin_dashboard.dart';
import 'login_screen.dart';
import 'get_started_screen.dart';

// ── Design tokens ────────────────────────────────────────────────────────────────
const _kBg      = Color(0xFF0B0B0B);
const _kSurface = Color(0xFF141414);
const _kBorder  = Color(0xFF242424);
const _kNeon    = Color(0xFFB8FF57);
const _kWhite   = Colors.white;
const _kMuted   = Color(0xFF6B7280);
const _kError   = Color(0xFFEF4444);

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey            = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading       = false;
  bool _obscurePassword = true;

  // Entrance fade
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Auth handlers (unchanged) ────────────────────────────────────────────────
  _continueWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final email    = _emailController.text.trim();
      final password = _passwordController.text;
      UserModel? user = await _authService.signUp('', email, password);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                user.role == 'admin' ? AdminDashboard() : HomeScreen(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      UserModel? user = await _authService.signInWithGoogle();
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                user.role == 'admin' ? AdminDashboard() : HomeScreen(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign in failed: ${e.toString()}')),
      );
    }
    setState(() => _isLoading = false);
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // Subtle neon radial glow behind the hero
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _kNeon.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // ── Back button ──────────────────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: _BackButton(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => GetStartedScreen()),
                        ),
                      ),
                    ),
                  ),

                  // ── Scrollable form ──────────────────────────────────────
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // ── Hero ─────────────────────────────────
                                _HeroSection(),

                                const SizedBox(height: 28),

                                // ── Google button ─────────────────────────
                                _GlassGoogleButton(
                                  onTap: _isLoading
                                      ? null
                                      : _signInWithGoogle,
                                  isLoading: _isLoading,
                                ),

                                const SizedBox(height: 24),

                                // ── Divider ───────────────────────────────
                                _OrDivider(),

                                const SizedBox(height: 24),

                                // ── Email field ───────────────────────────
                                _FieldLabel('Email'),
                                const SizedBox(height: 8),
                                _NeonField(
                                  controller: _emailController,
                                  hint: 'hello@gmail.com',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Enter your email';
                                    if (!v.contains('@'))
                                      return 'Enter a valid email';
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                // ── Password field ────────────────────────
                                _FieldLabel('Password'),
                                const SizedBox(height: 8),
                                _NeonField(
                                  controller: _passwordController,
                                  hint: 'Min. 6 characters',
                                  obscure: _obscurePassword,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: _kMuted,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Enter a password';
                                    if (v.length < 6)
                                      return 'Password must be at least 6 characters';
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 24),

                                // ── Create Account CTA ────────────────────
                                _NeonCTAButton(
                                  label: 'Create Account',
                                  isLoading: _isLoading,
                                  onTap: _isLoading
                                      ? null
                                      : _continueWithEmail,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Footer ───────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 28, top: 8),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: _kMuted,
                          fontFamily: 'SF Pro Display',
                        ),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => LoginScreen()),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _kNeon,
                                  fontFamily: 'SF Pro Display',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Back button ──────────────────────────────────────────────────────────────────
class _BackButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});
  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: ()  => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _kSurface,
            shape: BoxShape.circle,
            border: Border.all(color: _kBorder),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _kWhite,
            size: 15,
          ),
        ),
      ),
    );
  }
}

// ── Hero section ─────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Neon sport tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _kNeon.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _kNeon.withValues(alpha: 0.30), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: _kNeon, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              const Text(
                'WEIDAN SPORTS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _kNeon,
                  fontFamily: 'SF Pro Display',
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Main headline
        const Text(
          'Create your\nfree account',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: _kWhite,
            fontFamily: 'SF Pro Display',
            letterSpacing: -0.8,
            height: 1.15,
          ),
        ),

        const SizedBox(height: 10),

        // Subtitle
        const Text(
          'Join thousands of athletes. Shop premium\nbadminton gear delivered to your door.',
          style: TextStyle(
            fontSize: 13,
            color: _kMuted,
            fontFamily: 'SF Pro Display',
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

// ── Glassmorphism Google button ───────────────────────────────────────────────────
class _GlassGoogleButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  const _GlassGoogleButton({required this.onTap, this.isLoading = false});
  @override
  State<_GlassGoogleButton> createState() => _GlassGoogleButtonState();
}

class _GlassGoogleButtonState extends State<_GlassGoogleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap?.call(); },
      onTapCancel: ()  => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.40),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: widget.isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white54),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CustomPaint(
                            painter: _GooglePainter(
                                bgColor: const Color(0xFF1C1C1C)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _kWhite,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── OR divider ───────────────────────────────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: _kBorder),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 11,
              color: _kMuted.withValues(alpha: 0.70),
              fontFamily: 'SF Pro Display',
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: _kBorder),
        ),
      ],
    );
  }
}

// ── Field label ──────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFFD1D5DB),
          fontFamily: 'SF Pro Display',
          letterSpacing: 0.1,
        ),
      );
}

// ── Neon-glow text field ──────────────────────────────────────────────────────────
class _NeonField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _NeonField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  @override
  State<_NeonField> createState() => _NeonFieldState();
}

class _NeonFieldState extends State<_NeonField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: _kNeon.withValues(alpha: 0.18),
                  blurRadius: 16,
                  spreadRadius: -2,
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focus,
        obscureText: widget.obscure,
        keyboardType: widget.keyboardType,
        style: const TextStyle(
          color: _kWhite,
          fontSize: 15,
          fontFamily: 'SF Pro Display',
        ),
        validator: widget.validator,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: _kMuted.withValues(alpha: 0.60),
            fontSize: 15,
            fontFamily: 'SF Pro Display',
          ),
          filled: true,
          fillColor: _kSurface,
          suffixIcon: widget.suffix,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: _kNeon.withValues(alpha: 0.70), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kError),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kError, width: 1.5),
          ),
          errorStyle: const TextStyle(
              color: _kError, fontFamily: 'SF Pro Display'),
        ),
      ),
    );
  }
}

// ── Neon CTA button ───────────────────────────────────────────────────────────────
class _NeonCTAButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;
  const _NeonCTAButton(
      {required this.label, required this.isLoading, required this.onTap});
  @override
  State<_NeonCTAButton> createState() => _NeonCTAButtonState();
}

class _NeonCTAButtonState extends State<_NeonCTAButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap?.call(); },
      onTapCancel: ()  => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: widget.isLoading
                ? _kNeon.withValues(alpha: 0.55)
                : _kNeon,
            borderRadius: BorderRadius.circular(14),
            boxShadow: widget.isLoading
                ? []
                : [
                    BoxShadow(
                      color: _kNeon.withValues(alpha: 0.40),
                      blurRadius: 20,
                      spreadRadius: -4,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: _kNeon.withValues(alpha: 0.20),
                      blurRadius: 40,
                      spreadRadius: -2,
                    ),
                  ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Color(0xFF0A0A0A)),
                  )
                : const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0A0A),
                      fontFamily: 'SF Pro Display',
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Google icon painter ───────────────────────────────────────────────────────────
class _GooglePainter extends CustomPainter {
  final Color bgColor;
  const _GooglePainter({required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;

    final segments = [
      [0.0,  1.57, const Color(0xFF4285F4)],
      [1.57, 3.14, const Color(0xFF34A853)],
      [3.14, 4.71, const Color(0xFFFBBC05)],
      [4.71, 6.28, const Color(0xFFEA4335)],
    ];

    for (final seg in segments) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.72),
        seg[0] as double,
        (seg[1] as double) - (seg[0] as double),
        false,
        Paint()
          ..color = seg[2] as Color
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.18,
      );
    }

    canvas.drawRect(
      Rect.fromLTWH(cx, cy - size.height * 0.18, r, size.height * 0.36),
      Paint()..color = bgColor..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - size.height * 0.12, r * 0.85, size.height * 0.24),
      Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
