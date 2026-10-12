import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../services/supabase_service.dart';
import '../widgets/app_logo.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  String _statusText = 'Initializing AI Engine...';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.85, curve: Curves.easeIn),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animController.forward();

    // Staged status messages
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _statusText = 'Connecting to Neural Cloud...');
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _statusText = 'Preparing Your Workspace...');
    });

    _timer = Timer(const Duration(milliseconds: 2300), _navigateNext);
  }

  void _navigateNext() {
    if (!mounted) return;
    
    // If the URL has a PKCE code, wait for Supabase to handle the deep link.
    // The global auth listener in main.dart will route us to the correct page.
    if (Uri.base.queryParameters.containsKey('code')) {
      return;
    }

    final isLoggedIn =
        SupabaseService.isReady && SupabaseService.currentUser != null;
    if (isLoggedIn) {
      Get.offNamed(AppRoutes.dashboard);
    } else {
      Get.offNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep Slate Navy
      body: Stack(
        children: [
          // Animated Background Ambient Glowing Orbs
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.15,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2563EB).withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.15,
            child: Container(
              width: size.width * 0.65,
              height: size.width * 0.65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Central Content
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo Container
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _animController.isCompleted
                              ? _pulseAnimation.value
                              : 1.0,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.25),
                              blurRadius: 30,
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: const AppLogo(
                          size: 110,
                          animate: true,
                          showGlow: false,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Brand Name with Gradient Shader
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFBAE6FD),
                          Color(0xFF6EE7B7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'ResumeAI',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Subtitle
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: const Text(
                        'AI-Powered Career & Resume Intelligence',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Progress & Status Indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 140,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: const LinearProgressIndicator(
                              minHeight: 3,
                              backgroundColor: Color(0xFF1E293B),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF38BDF8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _statusText,
                            key: ValueKey(_statusText),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Skip button at top right
          Positioned(
            top: 48,
            right: 24,
            child: TextButton(
              onPressed: _navigateNext,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF94A3B8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Skip', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded, size: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
