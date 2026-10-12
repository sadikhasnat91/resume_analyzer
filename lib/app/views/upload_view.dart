import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/upload_controller.dart';
import '../widgets/ai_scanner_overlay.dart';
import '../widgets/app_logo.dart';

class UploadView extends StatelessWidget {
  const UploadView({super.key});

  UploadController get controller => Get.isRegistered<UploadController>()
      ? Get.find<UploadController>()
      : Get.put(UploadController(), permanent: true);

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Obx(
      () => AiScannerOverlay(
        isScanning: controller.isLoading.value,
        fileName: controller.fileName.value.isNotEmpty
            ? controller.fileName.value
            : 'Resume Document',
        category: controller.selectedCategory.value,
        seniority: controller.selectedSeniority.value,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 48 : 20,
                  24,
                  isDesktop ? 48 : 20,
                  100,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with AppLogo & Title
                      Row(
                        children: [
                          const AppLogo(size: 48, showGlow: true),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'AI Resume Analysis',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Powered by Google Gemini 3.x Deep Evaluation',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blueGrey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Upload Card Zone
                      Obx(
                        () => controller.selectedFile.value == null
                            ? _buildUploadDropzone(context)
                            : _buildSelectedFileCard(context),
                      ),

                      const SizedBox(height: 28),

                      // Configuration Options Card
                      Container(
                        padding: const EdgeInsets.all(24),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.tune_rounded,
                                  size: 20,
                                  color: Color(0xFF2563EB),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Target Role Alignment',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Job Category Dropdown
                            const Text(
                              'Target Industry / Category',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(
                              () => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: controller.selectedCategory.value,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color(0xFF2563EB),
                                    ),
                                    items: controller.categories
                                        .map(
                                          (cat) => DropdownMenuItem(
                                            value: cat,
                                            child: Text(
                                              cat,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        controller.selectedCategory.value = val;
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Seniority Level Dropdown
                            const Text(
                              'Target Seniority Level',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(
                              () => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: controller.selectedSeniority.value,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color(0xFF2563EB),
                                    ),
                                    items: controller.seniorities
                                        .map(
                                          (level) => DropdownMenuItem(
                                            value: level,
                                            child: Text(
                                              level,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        controller.selectedSeniority.value = val;
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Action Button
                      Obx(
                        () {
                          final hasFile = controller.selectedFile.value != null;
                          return Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: hasFile
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF2563EB),
                                            Color(0xFF10B981),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        )
                                      : null,
                                  color: hasFile ? null : const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: hasFile
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF2563EB)
                                                .withValues(alpha: 0.35),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: ElevatedButton(
                                  onPressed: hasFile && !controller.isLoading.value
                                      ? controller.analyze
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 20,
                                        color: hasFile
                                            ? Colors.white
                                            : const Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Launch AI Resume Analysis',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: hasFile
                                              ? Colors.white
                                              : const Color(0xFF94A3B8),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!hasFile) ...[
                                const SizedBox(height: 10),
                                const Center(
                                  child: Text(
                                    'Please select a PDF or Word document above to proceed',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadDropzone(BuildContext context) {
    return GestureDetector(
      onTap: controller.pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.08),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Floating Center Logo
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.18),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: const AppLogo(
                size: 76,
                animate: true,
                showGlow: true,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Upload Your Resume',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Click to browse or drop your document here',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),

            // Supported Format Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFormatBadge('PDF', const Color(0xFFEF4444)),
                const SizedBox(width: 8),
                _buildFormatBadge('DOCX', const Color(0xFF2563EB)),
                const SizedBox(width: 8),
                _buildFormatBadge('DOC', const Color(0xFF0D9488)),
                const SizedBox(width: 12),
                Text(
                  'Max 5MB',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFileCard(BuildContext context) {
    final file = controller.selectedFile.value!;
    final sizeKb = (file.size / 1024).toStringAsFixed(1);
    final ext = (file.extension ?? 'PDF').toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.6),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Icon(
              Icons.description_rounded,
              size: 28,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
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
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ext,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$sizeKb KB',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.clearFile,
            tooltip: 'Remove File',
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class RoundedRectangleCross extends RoundedRectangleBorder {
  const RoundedRectangleCross({super.borderRadius});
}
