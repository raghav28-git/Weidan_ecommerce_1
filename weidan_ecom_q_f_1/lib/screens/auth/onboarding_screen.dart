import 'package:flutter/material.dart';
import 'dart:async';
import 'get_started_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  late List<AnimationController> _letterControllers;
  late List<Animation<double>> _letterAnimations;
  late List<Animation<Offset>> _letterSlideAnimations;

  final List<String> _images = [
    'assets/onboarding_1.png',
    'assets/onboarding_2.png', 
    'assets/onboarding_3.png',
  ];

  final List<String> _quotes = [
    'ELEVATE EVERY SHOT WITH UNCOMPROMISING QUALITY.',
    'FROM CRAFTSMANSHIP TO DOORSTEP.',
    'EXPERIENCE PREMIUM QUALITY DELIVERED.',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startKineticAnimation();
    _startTimer();
  }

  void _initializeAnimations() {
    final text = _quotes[_currentPage];
    _letterControllers = List.generate(text.length, (index) => 
      AnimationController(
        duration: Duration(milliseconds: 400),
        vsync: this,
      )
    );
    
    _letterAnimations = _letterControllers.map((controller) => 
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic)
      )
    ).toList();
    
    _letterSlideAnimations = _letterControllers.map((controller) => 
      Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutQuart)
      )
    ).toList();
  }

  void _startKineticAnimation() {
    for (int i = 0; i < _letterControllers.length; i++) {
      _letterControllers[i].reset();
    }
    
    for (int i = 0; i < _letterControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) _letterControllers[i].forward();
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 6), () {
      if (_currentPage < _images.length - 1) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => GetStartedScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  void _nextPage() {
    _timer?.cancel();
    if (_currentPage < _images.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => GetStartedScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 300),
        ),
      );
    }
  }

  void _disposeLetterControllers() {
    if (_letterControllers.isNotEmpty) {
      for (var controller in _letterControllers) {
        controller.dispose();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _disposeLetterControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _disposeLetterControllers();
              _initializeAnimations();
              _startKineticAnimation();
              _startTimer();
            },
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Image.asset(
                    _images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Positioned(
                    left: 20,
                    top: 80,
                    right: 100,
                    child: Wrap(
                      children: _quotes[index].split('').asMap().entries.map((entry) {
                        int letterIndex = entry.key;
                        String letter = entry.value;
                        
                        return AnimatedBuilder(
                          animation: _letterControllers.length > letterIndex ? _letterControllers[letterIndex] : _letterControllers[0],
                          builder: (context, child) {
                            return SlideTransition(
                              position: _letterSlideAnimations.length > letterIndex ? _letterSlideAnimations[letterIndex] : _letterSlideAnimations[0],
                              child: FadeTransition(
                                opacity: _letterAnimations.length > letterIndex ? _letterAnimations[letterIndex] : _letterAnimations[0],
                                child: Transform.scale(
                                  scale: 0.8 + (_letterAnimations.length > letterIndex ? _letterAnimations[letterIndex].value * 0.2 : 0.2),
                                  child: Text(
                                    letter == ' ' ? '\u00A0' : letter,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                      letterSpacing: 1.2,
                                      height: 1.3,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 3,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 50,
            right: 30,
            child: GestureDetector(
              onTap: _nextPage,
              child: Text(
                'Next >',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro Display',
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}