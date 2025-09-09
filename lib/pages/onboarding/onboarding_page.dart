import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../core/constants.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  
  bool _showFork = false;
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimation();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Constants.introAnimationDuration,
      vsync: this,
    );

    // Scale animation: 0.85 → 1.0 (0.0-0.5s)
    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Fade animation: 0 → 1 (0.0-0.5s)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Bounce animation: 1.0 → 0.96 → 1.0 (0.9-1.6s)
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.96),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.96, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.9, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.addListener(() {
      // Show fork at 0.5s
      if (_animationController.value >= 0.5 && !_showFork) {
        setState(() {
          _showFork = true;
        });
      }
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_animationComplete) {
        setState(() {
          _animationComplete = true;
        });
        _navigateToHome();
      }
    });
  }

  void _startAnimation() {
    _animationController.forward();
  }

  void _navigateToHome() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryOrange,
              AppTheme.secondaryLime,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _showFork 
                    ? _bounceAnimation.value 
                    : _scaleAnimation.value,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildLogo(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Main logo container
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Link icon (shown initially)
              if (!_showFork)
                AnimatedOpacity(
                  opacity: _showFork ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.link,
                    size: 48,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              
              // Fork icon (shown after 0.5s)
              if (_showFork)
                AnimatedOpacity(
                  opacity: _showFork ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.restaurant,
                    size: 48,
                    color: AppTheme.primaryOrange,
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // App title
        Text(
          'TastyLink',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          'Extrage rețete din link-uri',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.9),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
