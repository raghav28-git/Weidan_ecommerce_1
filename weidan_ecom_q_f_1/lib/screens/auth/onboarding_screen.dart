import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'get_started_screen.dart';

// ── Tokens ───────────────────────────────────────────────────────────────────────
const _kNeon  = Color(0xFFB8FF57);
const _kCard  = Color(0xFF0E0E0E);
const _kWhite = Colors.white;
const _kMuted = Color(0xFF9CA3AF);

// ── Slide model ───────────────────────────────────────────────────────────────────
class _Slide {
  final String image;
  final String tag;
  final String headline;
  final String subtitle;
  const _Slide({
    required this.image,
    required this.tag,
    required this.headline,
    required this.subtitle,
  });
}

const _slides = [
  _Slide(
    image:    'assets/onboarding_1.png',
    tag:      'PERFORMANCE',
    headline: 'Elevate Every\nShot',
    subtitle: 'Uncompromising quality gear built\nfor champions at every level.',
  ),
  _Slide(
    image:    'assets/onboarding_2.png',
    tag:      'CRAFTSMANSHIP',
    headline: 'Built for the\nGame',
    subtitle: 'From precision rackets to pro-grade\nshuttlecocks — crafted to perform.',
  ),
  _Slide(
    image:    'assets/onboarding_3.png',
    tag:      'DELIVERY',
    headline: 'Premium Gear,\nYour Doorstep',
    subtitle: 'Fast, reliable delivery so you spend\nless time waiting, more time playing.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // Content fade + slide on page change
  late AnimationController _contentCtrl;
  late Animation<double>   _contentFade;
  late Animation<Offset>   _contentSlide;

  // Ken Burns slow zoom on the active image (6 s matches auto-advance)
  late AnimationController _zoomCtrl;
  late Animation<double>   _zoomAnim;

  @override
  void initState() {
    super.initState();

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _contentFade  = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));

    _zoomCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7), // slightly longer than timer so it never snaps back
    );
    _zoomAnim = Tween<double>(begin: 1.0, end: 1.09).animate(
      CurvedAnimation(parent: _zoomCtrl, curve: Curves.easeInOut),
    );

    _contentCtrl.forward();
    _zoomCtrl.forward();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _contentCtrl.dispose();
    _zoomCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 6), _nextPage);
  }

  void _nextPage() {
    _timer?.cancel();
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      _goGetStarted();
    }
  }

  void _goGetStarted() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => GetStartedScreen(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _contentCtrl.forward(from: 0);
    _zoomCtrl.forward(from: 0);   // restart Ken Burns on each new slide
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final mq          = MediaQuery.of(context);
    final sw          = mq.size.width;
    final isLandscape = mq.orientation == Orientation.landscape;
    final isTablet    = sw >= 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: isLandscape
            ? _LandscapeLayout(
                currentPage:   _currentPage,
                slides:        _slides,
                pageController: _pageController,
                contentFade:   _contentFade,
                contentSlide:  _contentSlide,
                zoomAnim:      _zoomAnim,
                onPageChanged: _onPageChanged,
                onNext:        _nextPage,
                onSkip:        _goGetStarted,
                isTablet:      isTablet,
              )
            : _PortraitLayout(
                currentPage:   _currentPage,
                slides:        _slides,
                pageController: _pageController,
                contentFade:   _contentFade,
                contentSlide:  _contentSlide,
                zoomAnim:      _zoomAnim,
                onPageChanged: _onPageChanged,
                onNext:        _nextPage,
                onSkip:        _goGetStarted,
                isTablet:      isTablet,
              ),
      ),
    );
  }
}

// ── Portrait layout ───────────────────────────────────────────────────────────────
class _PortraitLayout extends StatelessWidget {
  final int currentPage;
  final List<_Slide> slides;
  final PageController pageController;
  final Animation<double> contentFade;
  final Animation<Offset> contentSlide;
  final Animation<double> zoomAnim;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isTablet;

  const _PortraitLayout({
    required this.currentPage,
    required this.slides,
    required this.pageController,
    required this.contentFade,
    required this.contentSlide,
    required this.zoomAnim,
    required this.onPageChanged,
    required this.onNext,
    required this.onSkip,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final mq   = MediaQuery.of(context);
    final sw   = mq.size.width;
    final top  = mq.padding.top;
    final bot  = mq.padding.bottom;
    final hPad = (sw * 0.07).clamp(20.0, 36.0);

    final headlineSz = (sw * 0.092).clamp(28.0, 46.0);
    final subtitleSz = (sw * 0.036).clamp(13.0, 18.0);
    final tagSz      = (sw * 0.026).clamp(9.0, 12.0);

    return Stack(
      children: [
        // Full-screen paged images with Ken Burns zoom
        PageView.builder(
          controller: pageController,
          onPageChanged: onPageChanged,
          itemCount: slides.length,
          itemBuilder: (_, i) => _ZoomImage(
            key: ValueKey(i),
            imagePath: slides[i].image,
            zoomAnim: i == currentPage ? zoomAnim : null,
          ),
        ),

        // Cinematic gradient
        Positioned.fill(child: _CinematicGradient()),

        // Skip button
        if (currentPage < slides.length - 1)
          Positioned(
            top: top + 16,
            right: hPad,
            child: _SkipButton(onTap: onSkip),
          ),

        // Content + bottom card in a Column so positioning is flow-based
        Positioned.fill(
          child: Column(
            children: [
              // Pushes content down — takes up the top ~55% of screen
              const Spacer(flex: 55),

              // Slide content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: FadeTransition(
                  opacity: contentFade,
                  child: SlideTransition(
                    position: contentSlide,
                    child: _SlideContent(
                      slide: slides[currentPage],
                      headlineSz: headlineSz,
                      subtitleSz: subtitleSz,
                      tagSz: tagSz,
                    ),
                  ),
                ),
              ),

              // Gap between content and card
              const Spacer(flex: 5),

              // Bottom card — tablet: constrained + centred
              isTablet
                  ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: _BottomCard(
                          currentPage: currentPage,
                          total: slides.length,
                          isLast: currentPage == slides.length - 1,
                          hPad: hPad,
                          botPad: bot,
                          onNext: onNext,
                        ),
                      ),
                    )
                  : _BottomCard(
                      currentPage: currentPage,
                      total: slides.length,
                      isLast: currentPage == slides.length - 1,
                      hPad: hPad,
                      botPad: bot,
                      onNext: onNext,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Landscape layout ──────────────────────────────────────────────────────────────
class _LandscapeLayout extends StatelessWidget {
  final int currentPage;
  final List<_Slide> slides;
  final PageController pageController;
  final Animation<double> contentFade;
  final Animation<Offset> contentSlide;
  final Animation<double> zoomAnim;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isTablet;

  const _LandscapeLayout({
    required this.currentPage,
    required this.slides,
    required this.pageController,
    required this.contentFade,
    required this.contentSlide,
    required this.zoomAnim,
    required this.onPageChanged,
    required this.onNext,
    required this.onSkip,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final mq   = MediaQuery.of(context);
    final sw   = mq.size.width;
    final sh   = mq.size.height;
    final top  = mq.padding.top;
    final bot  = mq.padding.bottom;
    final hPad = (sw * 0.05).clamp(16.0, 32.0);

    final headlineSz = (sh * 0.13).clamp(22.0, 38.0);
    final subtitleSz = (sh * 0.048).clamp(11.0, 16.0);
    final tagSz      = (sh * 0.034).clamp(8.0, 11.0);

    return Row(
      children: [
        // Left: image (60% width)
        Expanded(
          flex: 60,
          child: Stack(
            children: [
              PageView.builder(
                controller: pageController,
                onPageChanged: onPageChanged,
                itemCount: slides.length,
                itemBuilder: (_, i) => _ZoomImage(
                  key: ValueKey(i),
                  imagePath: slides[i].image,
                  zoomAnim: i == currentPage ? zoomAnim : null,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),
              // Skip
              if (currentPage < slides.length - 1)
                Positioned(
                  top: top + 12,
                  right: 16,
                  child: _SkipButton(onTap: onSkip),
                ),
            ],
          ),
        ),

        // Right: content + controls (40% width)
        Expanded(
          flex: 40,
          child: Container(
            color: _kCard,
            padding: EdgeInsets.fromLTRB(
                hPad, top + 20, hPad, bot > 0 ? bot + 12 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content
                Expanded(
                  child: Center(
                    child: FadeTransition(
                      opacity: contentFade,
                      child: SlideTransition(
                        position: contentSlide,
                        child: _SlideContent(
                          slide: slides[currentPage],
                          headlineSz: headlineSz,
                          subtitleSz: subtitleSz,
                          tagSz: tagSz,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Controls row
                Row(
                  children: [
                    _ProgressDots(
                        current: currentPage, total: slides.length),
                    const Spacer(),
                    _NextButton(
                      isLast: currentPage == slides.length - 1,
                      onTap: onNext,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Ken Burns zoom image ──────────────────────────────────────────────────────────
class _ZoomImage extends StatelessWidget {
  final String imagePath;
  final Animation<double>? zoomAnim; // null = static (non-active pages)

  const _ZoomImage({
    super.key,
    required this.imagePath,
    required this.zoomAnim,
  });

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );

    if (zoomAnim == null) return img;

    return AnimatedBuilder(
      animation: zoomAnim!,
      builder: (_, child) => Transform.scale(
        scale: zoomAnim!.value,
        child: child,
      ),
      child: img,
    );
  }
}

// ── Cinematic gradient overlay ────────────────────────────────────────────────────
class _CinematicGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.08),
            Colors.black.withValues(alpha: 0.20),
            Colors.black.withValues(alpha: 0.65),
            Colors.black.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.35, 0.62, 1.0],
        ),
      ),
    );
  }
}

// ── Skip button ───────────────────────────────────────────────────────────────────
class _SkipButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SkipButton({required this.onTap});
  @override
  State<_SkipButton> createState() => _SkipButtonState();
}

class _SkipButtonState extends State<_SkipButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: ()  => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.55 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: const Text(
            'Skip',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kWhite,
              fontFamily: 'SF Pro Display',
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Slide content ─────────────────────────────────────────────────────────────────
class _SlideContent extends StatelessWidget {
  final _Slide slide;
  final double headlineSz;
  final double subtitleSz;
  final double tagSz;

  const _SlideContent({
    required this.slide,
    required this.headlineSz,
    required this.subtitleSz,
    required this.tagSz,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Neon tag chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _kNeon.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _kNeon.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: _kNeon,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                slide.tag,
                style: TextStyle(
                  fontSize: tagSz,
                  fontWeight: FontWeight.w700,
                  color: _kNeon,
                  fontFamily: 'SF Pro Display',
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: headlineSz * 0.38),

        Text(
          slide.headline,
          style: TextStyle(
            fontSize: headlineSz,
            fontWeight: FontWeight.w900,
            color: _kWhite,
            fontFamily: 'SF Pro Display',
            height: 1.08,
            letterSpacing: -1.0,
          ),
        ),

        SizedBox(height: subtitleSz * 0.75),

        Text(
          slide.subtitle,
          style: TextStyle(
            fontSize: subtitleSz,
            color: _kMuted,
            fontFamily: 'SF Pro Display',
            height: 1.55,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ── Bottom control card (portrait) ───────────────────────────────────────────────
class _BottomCard extends StatelessWidget {
  final int currentPage;
  final int total;
  final bool isLast;
  final double hPad;
  final double botPad;
  final VoidCallback onNext;

  const _BottomCard({
    required this.currentPage,
    required this.total,
    required this.isLast,
    required this.hPad,
    required this.botPad,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = botPad > 0 ? botPad + 16 : 28.0;
    return Container(
      padding: EdgeInsets.fromLTRB(hPad, 22, hPad, bottomInset),
      decoration: BoxDecoration(
        color: _kCard.withValues(alpha: 0.93),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.07),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _ProgressDots(current: currentPage, total: total),
          const Spacer(),
          _NextButton(isLast: isLast, onTap: onNext),
        ],
      ),
    );
  }
}

// ── Animated progress dots ────────────────────────────────────────────────────────
class _ProgressDots extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 7),
          width:  active ? 24 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active
                ? _kNeon
                : Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(4),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _kNeon.withValues(alpha: 0.50),
                      blurRadius: 8,
                      spreadRadius: -1,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }
}

// ── Next / Get Started button ─────────────────────────────────────────────────────
class _NextButton extends StatefulWidget {
  final bool isLast;
  final VoidCallback onTap;
  const _NextButton({required this.isLast, required this.onTap});
  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: ()  => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isLast ? 22 : 18,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: _pressed ? _kNeon.withValues(alpha: 0.82) : _kNeon,
            borderRadius: BorderRadius.circular(50),
            boxShadow: _pressed
                ? []
                : [
                    BoxShadow(
                      color: _kNeon.withValues(alpha: 0.45),
                      blurRadius: 18,
                      spreadRadius: -3,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Text(
                  widget.isLast ? 'Get Started' : 'Next',
                  key: ValueKey(widget.isLast),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A0A0A),
                    fontFamily: 'SF Pro Display',
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: Color(0xFF0A0A0A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
