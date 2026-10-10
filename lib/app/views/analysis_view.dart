import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../widgets/app_logo.dart';

class AnalysisView extends StatefulWidget {
  const AnalysisView({super.key});

  @override
  State<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<AnalysisView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    final args = Get.arguments as Map<String, dynamic>?;
    final targetScore = (args?['score'] as int? ?? 75).toDouble();

    _scoreAnimation = Tween<double>(begin: 0.0, end: targetScore).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final fileName = args?['fileName'] as String? ?? 'resume.pdf';
    final category = args?['category'] as String? ?? 'Software Engineering';
    final seniority = args?['seniority'] as String? ?? 'Senior';
    final finalScore = (args?['score'] as int? ?? 75);
    final strengths = (args?['strengths'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final weaknesses = (args?['weaknesses'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final suggestions = (args?['suggestions'] as List?)?.map((e) => e.toString()).toList() ?? [];

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            const AppLogo(size: 28, showGlow: false),
            const SizedBox(width: 10),
            const Text(
              'Analysis Results',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
            icon: const Icon(Icons.home_outlined, size: 18, color: Color(0xFF2563EB)),
            label: const Text('Dashboard', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48 : 20,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // File & Role Header Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.description_outlined, color: Color(0xFF2563EB), size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildTag(category, const Color(0xFF2563EB)),
                                  const SizedBox(width: 8),
                                  _buildTag(seniority, const Color(0xFF0D9488)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Hero Score Gauge Card
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: _getScoreThemeColor(finalScore).withValues(alpha: 0.3),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Animated Radial Gauge
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: AnimatedBuilder(
                            animation: _scoreAnimation,
                            builder: (context, child) {
                              final scoreValue = _scoreAnimation.value;
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: (scoreValue / 100).clamp(0.0, 1.0),
                                    strokeWidth: 10,
                                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getScoreThemeColor(finalScore),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${scoreValue.round()}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const Text(
                                        'SCORE',
                                        style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 24),

                        // Score Status Summary
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getScoreThemeColor(finalScore).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getScoreThemeColor(finalScore).withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  _getScoreTier(finalScore),
                                  style: TextStyle(
                                    color: _getScoreThemeColor(finalScore),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Overall Resume Fitness',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getScoreDescription(finalScore, category, seniority),
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Section: Key Strengths
                  _buildSectionCard(
                    title: 'Key Strengths',
                    subtitle: 'Elements that distinguish your profile for $seniority roles',
                    icon: Icons.check_circle_rounded,
                    accentColor: const Color(0xFF10B981),
                    items: strengths,
                  ),

                  const SizedBox(height: 20),

                  // Section: Areas of Improvement
                  _buildSectionCard(
                    title: 'Areas for Improvement',
                    subtitle: 'Critical gaps or weaknesses detected during AI review',
                    icon: Icons.warning_amber_rounded,
                    accentColor: const Color(0xFFF59E0B),
                    items: weaknesses,
                  ),

                  const SizedBox(height: 20),

                  // Section: Actionable Recommendations
                  _buildSectionCard(
                    title: 'Actionable Suggestions',
                    subtitle: 'Immediate steps to boost recruiter callbacks and score',
                    icon: Icons.rocket_launch_rounded,
                    accentColor: const Color(0xFF2563EB),
                    items: suggestions,
                  ),

                  const SizedBox(height: 36),

                  // Bottom Action Strip
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Back to Upload', style: TextStyle(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0F172A),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF10B981)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
                            icon: const Icon(Icons.dashboard_rounded, size: 18, color: Colors.white),
                            label: const Text(
                              'Go to Dashboard',
                              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          for (int i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[i],
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _getScoreThemeColor(int score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 65) return const Color(0xFF38BDF8);
    return const Color(0xFFF59E0B);
  }

  String _getScoreTier(int score) {
    if (score >= 80) return 'EXCELLENT FIT';
    if (score >= 65) return 'COMPETITIVE CANDIDATE';
    return 'REQUIRES REFINEMENT';
  }

  String _getScoreDescription(int score, String category, String seniority) {
    if (score >= 80) {
      return 'Strong alignment for $seniority $category positions with clear impact.';
    }
    if (score >= 65) {
      return 'Solid foundation. Fine-tuning metrics and role keywords will maximize interview rate.';
    }
    return 'Key sections require restructuring to match expectations for $seniority level.';
  }
}
