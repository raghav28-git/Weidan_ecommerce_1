import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

// ── Tokens ───────────────────────────────────────────────────────────────────────
const _kNeon  = Color(0xFFB8FF57);
const _kCard  = Color(0xFF111111);
const _kWhite = Colors.white;
const _kMuted = Color(0xFF9CA3AF);

class GetStartedScreen extends StatefulWidget {
  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with TickerProviderStateMixin {
  // Card entrance: fade + slide up
  late AnimationController _cardCtrl;
  late Animation<double>   _cardFade;
  late Animation<Offset>   _cardSlide;

  // Hero image fade-in (slightly ahead of card)
  late AnimationController _imgCtrl;
  late Animation<double>   _imgFade;

  @override
  void initState() {
    super.initState();

    _imgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _imgFade = CurvedAnimation(parent: _imgCtrl, curve: Curves.easeOut);

    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );
    _cardFade  = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));

    // Image fades in first, card follows 180ms later
    _imgCtrl.forward();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _cardCtrl.forward();
    });
  }

  @override
  void dispose() {
    _imgCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  // ── Navigation (unchanged) ───────────────────────────────────────────────────
  void _goSignUp() => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => SignUpScreen(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 420),
        ),
      );

  void _goLogin() => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => LoginScreen(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 420),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final mq         = MediaQuery.of(context);
    final sw         = mq.size.width;
    final sh         = mq.size.height;
    final bottomPad  = mq.padding.bottom;
    final isLandscape = mq.orientation == Orientation.landscape;
    final isTablet   = sw >= 600;

    // ── Responsive values ──────────────────────────────────────────────────────
    final hPad        = (sw * 0.07).clamp(20.0, 40.0);
    final cardTopPad  = (sh * 0.034).clamp(20.0, 36.0);
    final headlineSz  = (sw * 0.082).clamp(24.0, 42.0);
    final subtitleSz  = (sw * 0.034).clamp(12.0, 17.0);
    final btnHeight   = (sh * 0.068).clamp(48.0, 60.0);
    final cardBottomPad = bottomPad > 0 ? bottomPad + 20 : 32.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [

            // ── Hero image with fade-in ────────────────────────────────────
            Positioned.fill(
              child: FadeTransition(
                opacity: _imgFade,
                child: Image.asset(
                  'assets/getstarted.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),

            // ── Cinematic gradient overlay ─────────────────────────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.10),
                      Colors.black.withValues(alpha: 0.30),
                      Colors.black.withValues(alpha: 0.72),
                      Colors.black.withValues(alpha: 0.96),
                    ],
                    stops: const [0.0, 0.38, 0.65, 1.0],
                  ),
                ),
              ),
            ),

            // ── Floating bottom card ───────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              // On tablets: centre-constrain the card
              child: isTablet
                  ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: _buildCard(
                          hPad: hPad,
                          cardTopPad: cardTopPad,
                          cardBottomPad: cardBottomPad,
                          headlineSz: headlineSz,
                          subtitleSz: subtitleSz,
                          btnHeight: btnHeight,
                          isLandscape: isLandscape,
                          sh: sh,
                        ),
                      ),
                    )
                  : _buildCard(
                      hPad: hPad,
                      cardTopPad: cardTopPad,
                      cardBottomPad: cardBottomPad,
                      headlineSz: headlineSz,
                      subtitleSz: subtitleSz,
                      btnHeight: btnHeight,
                      isLandscape: isLandscape,
                      sh: sh,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required double hPad,
    required double cardTopPad,
    required double cardBottomPad,
    required double headlineSz,
    required double subtitleSz,
    required double btnHeight,
    required bool isLandscape,
    required double sh,
  }) {
    return FadeTransition(
      opacity: _cardFade,
      child: SlideTransition(
        position: _cardSlide,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.60),
                blurRadius: 40,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          // On short screens (landscape phones) make the card scrollable
          child: isLandscape && sh < 500
              ? SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                      hPad, cardTopPad, hPad, cardBottomPad),
                  child: _buildCardContent(
                    headlineSz: headlineSz,
                    subtitleSz: subtitleSz,
                    btnHeight: btnHeight,
                  ),
                )
              : Padding(
                  padding: EdgeInsets.fromLTRB(
                      hPad, cardTopPad, hPad, cardBottomPad),
                  child: _buildCardContent(
                    headlineSz: headlineSz,
                    subtitleSz: subtitleSz,
                    btnHeight: btnHeight,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCardContent({
    required double headlineSz,
    required double subtitleSz,
    required double btnHeight,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Sport tag chip
        _SportChip(),

        SizedBox(height: headlineSz * 0.44),

        // Headline
        Text(
          'Where Passion\nMeets Performance',
          style: TextStyle(
            fontSize: headlineSz,
            fontWeight: FontWeight.w900,
            color: _kWhite,
            fontFamily: 'SF Pro Display',
            height: 1.10,
            letterSpacing: -1.0,
          ),
        ),

        SizedBox(height: subtitleSz * 0.85),

        // Subtitle
        Text(
          'Shop premium badminton gear.\nOwn every smash.',
          style: TextStyle(
            fontSize: subtitleSz,
            color: _kMuted,
            fontFamily: 'SF Pro Display',
            height: 1.55,
            fontWeight: FontWeight.w400,
          ),
        ),

        SizedBox(height: btnHeight * 0.52),

        // CTA button
        _NeonButton(
          label: 'Get Started',
          height: btnHeight,
          onTap: _goSignUp,
        ),

        SizedBox(height: btnHeight * 0.34),

        // Sign in link
        Center(
          child: GestureDetector(
            onTap: _goLogin,
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: subtitleSz,
                  fontFamily: 'SF Pro Display',
                  color: _kMuted,
                ),
                children: const [
                  TextSpan(text: 'Already a member? '),
                  TextSpan(
                    text: 'Sign In',
                    style: TextStyle(
                      color: _kNeon,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sport tag chip ────────────────────────────────────────────────────────────────
class _SportChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kNeon.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _kNeon.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: _kNeon,
              shape: BoxShape.circle,
            ),
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
    );
  }
}

// ── Neon CTA button ───────────────────────────────────────────────────────────────
class _NeonButton extends StatefulWidget {
  final String label;
  final double height;
  final VoidCallback onTap;

  const _NeonButton({
    required this.label,
    required this.height,
    required this.onTap,
  });

  @override
  State<_NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<_NeonButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: ()  => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: _pressed ? _kNeon.withValues(alpha: 0.85) : _kNeon,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _pressed
                ? []
                : [
                    BoxShadow(
                      color: _kNeon.withValues(alpha: 0.45),
                      blurRadius: 24,
                      spreadRadius: -4,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: _kNeon.withValues(alpha: 0.20),
                      blurRadius: 48,
                      spreadRadius: -2,
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 16,
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
