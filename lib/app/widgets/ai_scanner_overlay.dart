import 'dart:async';
import 'package:flutter/material.dart';

class AiScannerOverlay extends StatefulWidget {
  final bool isScanning;
  final String fileName;
  final String category;
  final String seniority;
  final Widget child;

  const AiScannerOverlay({
    super.key,
    required this.isScanning,
    required this.fileName,
    required this.category,
    required this.seniority,
    required this.child,
  });

  @override
  State<AiScannerOverlay> createState() => _AiScannerOverlayState();
}

class _AiScannerOverlayState extends State<AiScannerOverlay>
    with TickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _currentStepIndex = 0;
  Timer? _stepTimer;

  final List<String> _steps = [
    '📄 Parsing document structure & formatting...',
    '🧠 Extracting tech stack, skills & metrics...',
    '📊 Benchmarking against industry standards...',
    '✨ Generating Gemini AI recommendations...',
  ];

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isScanning) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _laserController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _currentStepIndex = 0;
    _stepTimer?.cancel();
    _stepTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (mounted) {
        setState(() {
          _currentStepIndex = (_currentStepIndex + 1) % _steps.length;
        });
      }
    });
  }

  void _stopAnimation() {
    _stepTimer?.cancel();
    _laserController.stop();
    _pulseController.stop();
  }

  @override
  void didUpdateWidget(AiScannerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning != oldWidget.isScanning) {
      if (widget.isScanning) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _laserController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isScanning)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.78),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                            blurRadius: 36,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            blurRadius: 24,
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Scanner Target Card with Sweeping Laser Line
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: child,
                              );
                            },
                            child: Container(
                              width: 150,
                              height: 180,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Fake resume skeleton lines
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                size: 18,
                                                color: Color(0xFF38BDF8),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 7,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white70,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    height: 5,
                                                    width: 35,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white38,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        for (int i = 0; i < 4; i++) ...[
                                          Container(
                                            height: 5,
                                            width: i % 2 == 0 ? 100 : 80,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.25),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                        ],
                                        const Spacer(),
                                        Container(
                                          height: 18,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'GEMINI 3.X AI',
                                            style: TextStyle(
                                              color: Color(0xFF10B981),
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Sweeping Laser Beam
                                  AnimatedBuilder(
                                    animation: _laserAnimation,
                                    builder: (context, child) {
                                      return Positioned(
                                        top: _laserAnimation.value * 168,
                                        left: 0,
                                        right: 0,
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 3,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF38BDF8),
                                                    Color(0xFF10B981),
                                                    Color(0xFF38BDF8),
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF38BDF8),
                                                    blurRadius: 12,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 16,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    const Color(0xFF38BDF8).withValues(alpha: 0.35),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Heading
                          const Text(
                            'AI Neural Analysis Active',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Evaluating for ${widget.seniority} ${widget.category}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Dynamic Step Indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                _steps[_currentStepIndex],
                                key: ValueKey(_currentStepIndex),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Animated Linear Progress bar
                          SizedBox(
                            width: 220,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: const LinearProgressIndicator(
                                minHeight: 4,
                                backgroundColor: Color(0xFF1E293B),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF10B981),
                                ),
                              ),
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
      ],
    );
  }
}
