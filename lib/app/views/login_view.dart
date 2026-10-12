import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../widgets/app_logo.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  late AuthController controller;
  bool _obscurePassword = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      backgroundColor: isDesktop ? const Color(0xFFF1F5F9) : Colors.white,
      body: Stack(
        children: [
          // Background Gradient Mesh Orbs (Desktop only)
          if (isDesktop) ...[
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2563EB).withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -80,
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF10B981).withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Main Scrollable Area
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48 : 0,
                  vertical: isDesktop ? 24 : 12,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 460 : double.infinity,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(isDesktop ? 36 : 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: isDesktop
                              ? BorderRadius.circular(32)
                              : BorderRadius.zero,
                          border: isDesktop
                              ? Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                )
                              : null,
                          boxShadow: isDesktop
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A)
                                        .withValues(alpha: 0.08),
                                    blurRadius: 36,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 14),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF2563EB)
                                        .withValues(alpha: 0.06),
                                    blurRadius: 18,
                                    spreadRadius: -4,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 3D Logo Header with Animation
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB)
                                          .withValues(alpha: 0.22),
                                      blurRadius: 28,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const AppLogo(
                                  size: 88,
                                  animate: true,
                                  showGlow: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Header Text
                            const Text(
                              'ResumeAI',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sign in to analyze and optimize your resume',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Form Fields
                            Form(
                              key: controller.loginFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Email Field
                                  const Text(
                                    'Email Address',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    onChanged: (value) =>
                                        controller.email.value = value,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      prefixIcon: const Icon(
                                        Icons.mail_outline_rounded,
                                        color: Color(0xFF2563EB),
                                        size: 20,
                                      ),
                                      hintText: 'Enter your email',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 14,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF2563EB),
                                          width: 1.8,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      final val = value?.trim() ?? '';
                                      if (val.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!GetUtils.isEmail(val)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Password Field
                                  const Text(
                                    'Password',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    onChanged: (value) =>
                                        controller.password.value = value,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        color: Color(0xFF2563EB),
                                        size: 20,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: const Color(0xFF64748B),
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      hintText: 'Enter your password',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 14,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF2563EB),
                                          width: 1.8,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      final val = value?.trim() ?? '';
                                      if (val.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (val.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // Forgot Password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: controller.forgotPassword,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Forgot password?',
                                        style: TextStyle(
                                          color: Color(0xFF2563EB),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Submit Button with Gradient & Animation
                                  Obx(
                                    () => SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF2563EB),
                                              Color(0xFF1D4ED8),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF2563EB)
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 18,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: controller.isLoading.value
                                              ? null
                                              : controller.login,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: controller.isLoading.value
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Login',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      size: 18,
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Switch to Sign Up
                            Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Don’t have an account? ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Get.toNamed(AppRoutes.signup),
                                    child: const Text(
                                      'Create one',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2563EB),
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
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
