import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/upload_controller.dart';
import 'home_view.dart';
import 'upload_view.dart';
import 'history_view.dart';
import 'profile_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    if (!Get.isRegistered<UploadController>()) {
      Get.put(UploadController());
    }

    final pages = const [
      HomeView(),
      UploadView(),
      HistoryView(),
      ProfileView(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Obx(
        () => pages[controller.selectedIndex.value],
      ),
      bottomNavigationBar: Container(
        height: 84,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        alignment: Alignment.center,
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(33),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF176D8D).withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _ModernNavItem(
                  index: 0,
                  label: 'Home',
                  icon: Icons.home_rounded,
                  outlinedIcon: Icons.home_outlined,
                  controller: controller,
                ),
                _ModernNavItem(
                  index: 1,
                  label: 'Upload',
                  icon: Icons.cloud_upload_rounded,
                  outlinedIcon: Icons.cloud_upload_outlined,
                  controller: controller,
                ),
                _ModernNavItem(
                  index: 2,
                  label: 'History',
                  icon: Icons.analytics_rounded,
                  outlinedIcon: Icons.analytics_outlined,
                  controller: controller,
                ),
                _ModernNavItem(
                  index: 3,
                  label: 'Profile',
                  icon: Icons.person_rounded,
                  outlinedIcon: Icons.person_outline_rounded,
                  controller: controller,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernNavItem extends StatelessWidget {
  const _ModernNavItem({
    required this.index,
    required this.label,
    required this.icon,
    required this.outlinedIcon,
    required this.controller,
  });

  final int index;
  final String label;
  final IconData icon;
  final IconData outlinedIcon;
  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedIndex.value == index;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: () => controller.changePage(index),
            splashColor: const Color(0xFF176D8D).withValues(alpha: 0.1),
            highlightColor: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          const Color(0xFF176D8D).withValues(alpha: 0.14),
                          const Color(0xFF00B4D8).withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      isSelected ? icon : outlinedIcon,
                      size: 22,
                      color: isSelected
                          ? const Color(0xFF176D8D)
                          : const Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 3),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF176D8D)
                          : const Color(0xFF718096),
                      letterSpacing: isSelected ? 0.2 : 0,
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
