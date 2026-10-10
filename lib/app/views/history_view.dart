import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/history_controller.dart';
import '../models/resume_item.dart';
import '../routes/app_routes.dart';
import '../widgets/app_logo.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final HistoryController controller =
        Get.isRegistered<HistoryController>()
            ? Get.find<HistoryController>()
            : Get.put(HistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Resumes',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF102A43),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(
                        () => Text(
                          '${controller.resumes.length} analyzed documents',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Color(0xFF176D8D),
                      ),
                      tooltip: 'Refresh',
                      onPressed: () => controller.fetchHistory(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.resumes.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF176D8D),
                      ),
                    );
                  }

                  if (controller.resumes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppLogo(size: 80),
                          const SizedBox(height: 18),
                          const Text(
                            'No Saved Resumes Yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF102A43),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload and analyze your resume to get\ncomprehensive AI feedback & scores.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blueGrey.shade500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (Get.isRegistered<DashboardController>()) {
                                Get.find<DashboardController>().changePage(1);
                              }
                            },
                            icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                            label: const Text('Scan Resume Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF176D8D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.resumes.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final resume = controller.resumes[index];
                      return Dismissible(
                        key: Key(
                          resume.id ??
                              '${resume.name}_${resume.date}_$index',
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => controller.deleteResume(index),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        child: _ResumeCard(resume: resume),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Tap to view detail • Swipe left to delete',
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ),
              const SizedBox(height: 80), // padding above floating bar
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({required this.resume});

  final ResumeItem resume;

  Color _scoreColor(String scoreStr) {
    final clean = scoreStr.replaceAll('%', '').trim();
    final val = int.tryParse(clean) ?? 70;
    if (val >= 80) return const Color(0xFF10B981);
    if (val >= 65) return const Color(0xFF0284C7);
    return const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _scoreColor(resume.score);

    return InkWell(
      onTap:
          () => Get.toNamed(AppRoutes.analysis, arguments: resume.toJson()),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF176D8D).withValues(alpha: 0.12),
                    const Color(0xFF00B4D8).withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: Color(0xFF176D8D),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resume.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF102A43),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          resume.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        resume.date,
                        style: TextStyle(
                          color: Colors.blueGrey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: badgeColor.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 14,
                    color: badgeColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    resume.score,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
