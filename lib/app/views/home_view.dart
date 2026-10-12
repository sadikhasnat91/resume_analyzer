import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../controllers/history_controller.dart';
import '../models/resume_item.dart';
import '../services/supabase_service.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_builder.dart';
import '../widgets/app_logo.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());
    final historyController = Get.isRegistered<HistoryController>()
        ? Get.find<HistoryController>()
        : Get.put(HistoryController());
    if (historyController.resumes.isEmpty && !historyController.isLoading.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        historyController.fetchHistory();
      });
    }
    final user = SupabaseService.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'there';

    return ResponsiveBuilder(
      builder: (context, isDesktop, isTablet, isMobile) {
        final isWide = isDesktop || isTablet;

        return Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEAF4FB), Color(0xFFF7FAFC)],
              ),
            ),
            child: SafeArea(
              child: Obx(() {
                final resumes = historyController.resumes.toList();
                final totalAnalyses = resumes.length;
                final scores = resumes
                    .map((item) => _parseScore(item.score))
                    .toList();
                final averageScore = scores.isEmpty
                    ? 0
                    : (scores.reduce((a, b) => a + b) / scores.length).round();
                final topScore = scores.isEmpty
                    ? 0
                    : scores.reduce((a, b) => a > b ? a : b);
                final latestResume = resumes.isEmpty ? null : resumes.first;
                final focusMessage = _buildFocusMessage(
                  totalAnalyses: totalAnalyses,
                  averageScore: averageScore,
                  topScore: topScore,
                );

                return SingleChildScrollView(
                  padding: Responsive.responsivePaddingHorizontal.add(
                    EdgeInsets.symmetric(
                      vertical: Responsive.blockSizeVertical * 2,
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 1120 : 860,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TopBar(userName: userName),
                          SizedBox(height: Responsive.blockSizeVertical * 2.4),
                          _HeroSection(
                            userName: userName,
                            latestResume: latestResume,
                            totalAnalyses: totalAnalyses,
                            averageScore: averageScore,
                            isWide: isWide,
                            onUpload: () => dashboardController.changePage(1),
                            onHistory: () => dashboardController.changePage(2),
                          ),
                          SizedBox(height: Responsive.blockSizeVertical * 2.4),
                          const _SectionLabel(
                            title: 'Your overview',
                            subtitle:
                                'A quick read on current progress and what to do next.',
                          ),
                          SizedBox(height: Responsive.blockSizeVertical * 1.5),
                          _MetricsGrid(
                            metrics: [
                              _MetricData(
                                label: 'Total analyses',
                                value: '$totalAnalyses',
                                caption: totalAnalyses == 0
                                    ? 'Start with your first upload'
                                    : 'Across all saved resumes',
                                color: const Color(0xFF176D8D),
                                icon: Icons.stacked_bar_chart_rounded,
                              ),
                              _MetricData(
                                label: 'Average score',
                                value: totalAnalyses == 0
                                    ? '--'
                                    : '$averageScore%',
                                caption: totalAnalyses == 0
                                    ? 'No analysis yet'
                                    : _scoreBandLabel(averageScore),
                                color: const Color(0xFF0EA5A4),
                                icon: Icons.insights_rounded,
                              ),
                              _MetricData(
                                label: 'Best score',
                                value: totalAnalyses == 0 ? '--' : '$topScore%',
                                caption: totalAnalyses == 0
                                    ? 'Upload to benchmark quality'
                                    : 'Highest-performing resume',
                                color: const Color(0xFFF59E0B),
                                icon: Icons.workspace_premium_outlined,
                              ),
                              _MetricData(
                                label: 'Last activity',
                                value: latestResume?.date ?? 'Waiting',
                                caption: latestResume == null
                                    ? 'No saved analysis'
                                    : latestResume.name,
                                color: const Color(0xFFEF6C5B),
                                icon: Icons.schedule_rounded,
                              ),
                            ],
                            isWide: isWide,
                          ),
                          SizedBox(height: Responsive.blockSizeVertical * 2.4),
                          isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 7,
                                      child: _RecentActivitySection(
                                        resumes: resumes,
                                        onViewAll: () =>
                                            dashboardController.changePage(2),
                                      ),
                                    ),
                                    SizedBox(
                                      width: Responsive.blockSizeHorizontal * 3,
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: _FocusPanel(
                                        message: focusMessage,
                                        totalAnalyses: totalAnalyses,
                                        onUpload: () =>
                                            dashboardController.changePage(1),
                                        onProfile: () =>
                                            dashboardController.changePage(3),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _RecentActivitySection(
                                      resumes: resumes,
                                      onViewAll: () =>
                                          dashboardController.changePage(2),
                                    ),
                                    SizedBox(
                                      height: Responsive.blockSizeVertical * 2,
                                    ),
                                    _FocusPanel(
                                      message: focusMessage,
                                      totalAnalyses: totalAnalyses,
                                      onUpload: () =>
                                          dashboardController.changePage(1),
                                      onProfile: () =>
                                          dashboardController.changePage(3),
                                    ),
                                  ],
                                ),
                          SizedBox(height: Responsive.blockSizeVertical * 2.4),
                          const _SectionLabel(
                            title: 'Quick routes',
                            subtitle:
                                'Main actions are kept visible without turning the home page into a long list.',
                          ),
                          SizedBox(height: Responsive.blockSizeVertical * 1.5),
                          _ActionStrip(
                            isWide: isWide,
                            actions: [
                              _ActionData(
                                icon: Icons.upload_file_rounded,
                                title: 'New review',
                                description: 'Upload a fresh resume.',
                                color: const Color(0xFF176D8D),
                                onTap: () => dashboardController.changePage(1),
                              ),
                              _ActionData(
                                icon: Icons.history_toggle_off_rounded,
                                title: 'Compare runs',
                                description: 'Check previous results.',
                                color: const Color(0xFF0EA5A4),
                                onTap: () => dashboardController.changePage(2),
                              ),
                              _ActionData(
                                icon: Icons.manage_accounts_outlined,
                                title: 'Profile',
                                description: 'Update account settings.',
                                color: const Color(0xFFF59E0B),
                                onTap: () => dashboardController.changePage(3),
                              ),
                              _ActionData(
                                icon: Icons.tips_and_updates_outlined,
                                title: 'Improve',
                                description: 'Use insights to revise.',
                                color: const Color(0xFFEF6C5B),
                                onTap: () => dashboardController.changePage(2),
                              ),
                            ],
                          ),
                          SizedBox(height: Responsive.blockSizeVertical * 3),
                          const SizedBox(height: 70), // clearance for floating dock
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      );
  }

  int _parseScore(String score) {
    return int.tryParse(score.replaceAll('%', '')) ?? 0;
  }

  String _scoreBandLabel(int score) {
    if (score >= 85) return 'Strong and competitive';
    if (score >= 70) return 'Solid, with room to sharpen';
    if (score >= 50) return 'Needs targeted revisions';
    return 'Baseline only';
  }

  String _buildFocusMessage({
    required int totalAnalyses,
    required int averageScore,
    required int topScore,
  }) {
    if (totalAnalyses == 0) {
      return 'Upload the first resume to generate a baseline score, reveal weak sections, and give this dashboard something real to track.';
    }

    if (averageScore < 70) {
      return 'Your current average suggests the resumes need stronger structure or keyword alignment. Start with the weakest draft and iterate from the latest feedback.';
    }

    if (topScore >= 85) {
      return 'You already have a high-performing version. Use history to compare edits and avoid drifting away from what is already working.';
    }

    return 'You have momentum. One more revision focused on clarity, impact statements, and role-specific keywords should move the score further.';
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFD6E5F1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: 26, showGlow: false),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'ResumeAI workspace',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Responsive.responsiveFontSize(12),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF14313E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(18, 56, 76, 0.08),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF176D8D).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF176D8D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                userName,
                style: TextStyle(
                  fontSize: Responsive.responsiveFontSize(13),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF14313E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.userName,
    required this.latestResume,
    required this.totalAnalyses,
    required this.averageScore,
    required this.isWide,
    required this.onUpload,
    required this.onHistory,
  });

  final String userName;
  final ResumeItem? latestResume;
  final int totalAnalyses;
  final int averageScore;
  final bool isWide;
  final VoidCallback onUpload;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final summaryCard = _HeroSummaryCard(
      latestResume: latestResume,
      averageScore: averageScore,
      totalAnalyses: totalAnalyses,
      onHistory: onHistory,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isWide
            ? Responsive.blockSizeHorizontal * 3.2
            : Responsive.blockSizeHorizontal * 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF12384C), Color(0xFF176D8D), Color(0xFF2C8DA4)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(23, 109, 141, 0.22),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _HeroCopy(
                        userName: userName,
                        onUpload: onUpload,
                        onHistory: onHistory,
                      ),
                    ),
                    SizedBox(width: Responsive.blockSizeHorizontal * 3),
                    Expanded(flex: 4, child: summaryCard),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCopy(
                      userName: userName,
                      onUpload: onUpload,
                      onHistory: onHistory,
                    ),
                    SizedBox(height: Responsive.blockSizeVertical * 1.8),
                    summaryCard,
                  ],
                ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.userName,
    required this.onUpload,
    required this.onHistory,
  });

  final String userName;
  final VoidCallback onUpload;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(size: 20, showGlow: false),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Intelligent Resume Analysis & Optimization',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Responsive.responsiveFontSize(12),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Responsive.blockSizeVertical * 1.5),
        Text(
          'Welcome back, $userName',
          style: TextStyle(
            fontSize: Responsive.responsiveFontSize(15),
            color: Colors.white.withValues(alpha: 0.86),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Responsive.blockSizeVertical * 0.7),
        Text(
          'Build stronger resumes with a home page that shows direction, not noise.',
          style: TextStyle(
            fontSize: Responsive.responsiveFontSize(26),
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: Responsive.blockSizeVertical * 1.3),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Upload a resume, review the latest performance, and pick up exactly where the last improvement cycle stopped.',
            style: TextStyle(
              fontSize: Responsive.responsiveFontSize(13),
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ),
        SizedBox(height: Responsive.blockSizeVertical * 1.8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              height: Responsive.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: onUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF12384C),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text(
                  'Upload Resume',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SizedBox(
              height: Responsive.buttonHeight,
              child: OutlinedButton.icon(
                onPressed: onHistory,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.38)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.history_rounded),
                label: const Text(
                  'View History',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroSummaryCard extends StatelessWidget {
  const _HeroSummaryCard({
    required this.latestResume,
    required this.averageScore,
    required this.totalAnalyses,
    required this.onHistory,
  });

  final ResumeItem? latestResume;
  final int averageScore;
  final int totalAnalyses;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.radar_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Current snapshot',
                  style: TextStyle(
                    fontSize: Responsive.responsiveFontSize(16),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _HeroSummaryRow(
            label: 'Latest file',
            value: latestResume?.name ?? 'No resume yet',
          ),
          const SizedBox(height: 10),
          _HeroSummaryRow(label: 'Saved analyses', value: '$totalAnalyses'),
          const SizedBox(height: 10),
          _HeroSummaryRow(
            label: 'Average result',
            value: totalAnalyses == 0 ? '--' : '$averageScore%',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onHistory,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.1),
              ),
              child: const Text(
                'Open analysis history',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSummaryRow extends StatelessWidget {
  const _HeroSummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: Responsive.responsiveFontSize(12),
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: Responsive.responsiveFontSize(13),
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: Responsive.responsiveFontSize(20),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF12384C),
          ),
        ),
        SizedBox(height: Responsive.blockSizeVertical * 0.6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: Responsive.responsiveFontSize(13),
            color: const Color(0xFF5E7280),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.metrics, required this.isWide});

  final List<_MetricData> metrics;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        children: metrics
            .asMap()
            .entries
            .map(
              (entry) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: entry.key == metrics.length - 1
                        ? 0
                        : Responsive.blockSizeHorizontal * 2,
                  ),
                  child: _MetricCard(data: entry.value),
                ),
              ),
            )
            .toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Responsive.blockSizeHorizontal * 3,
        mainAxisSpacing: Responsive.blockSizeVertical * 1.4,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        return _MetricCard(data: metrics[index], compact: true);
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data, this.compact = false});

  final _MetricData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2ECF3)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(18, 56, 76, 0.04),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 38 : 44,
            height: compact ? 38 : 44,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: data.color, size: compact ? 18 : 22),
          ),
          SizedBox(height: compact ? 12 : 16),
          Text(
            data.value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: Responsive.responsiveFontSize(compact ? 20 : 24),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF14313E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: TextStyle(
              fontSize: Responsive.responsiveFontSize(compact ? 12 : 13),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF45606D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: Responsive.responsiveFontSize(compact ? 11 : 12),
              color: const Color(0xFF6E818D),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({
    required this.resumes,
    required this.onViewAll,
  });

  final List<ResumeItem> resumes;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2ECF3)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(18, 56, 76, 0.04),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent activity',
                      style: TextStyle(
                        fontSize: Responsive.responsiveFontSize(18),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF12384C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Latest saved resume analyses, ready to revisit.',
                      style: TextStyle(
                        fontSize: Responsive.responsiveFontSize(12),
                        color: const Color(0xFF6E818D),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: onViewAll, child: const Text('View all')),
            ],
          ),
          const SizedBox(height: 16),
          if (resumes.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9FC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'No activity yet. Upload a resume to start building a useful history.',
                style: TextStyle(
                  fontSize: Responsive.responsiveFontSize(13),
                  color: const Color(0xFF5E7280),
                  height: 1.6,
                ),
              ),
            )
          else
            Column(
              children: resumes
                  .take(3)
                  .map(
                    (resume) =>
                        _RecentResumeCard(resume: resume, onTap: onViewAll),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _RecentResumeCard extends StatelessWidget {
  const _RecentResumeCard({required this.resume, required this.onTap});

  final ResumeItem resume;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final score = int.tryParse(resume.score.replaceAll('%', '')) ?? 0;
    final scoreColor = _scoreColor(score);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FBFD),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE4EEF4)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF176D8D).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF176D8D),
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
                      style: TextStyle(
                        fontSize: Responsive.responsiveFontSize(14),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF14313E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resume.date,
                      style: TextStyle(
                        fontSize: Responsive.responsiveFontSize(12),
                        color: const Color(0xFF6E818D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  resume.score,
                  style: TextStyle(
                    fontSize: Responsive.responsiveFontSize(12),
                    fontWeight: FontWeight.w800,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF0EA5A4);
    if (score >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF6C5B);
  }
}

class _FocusPanel extends StatelessWidget {
  const _FocusPanel({
    required this.message,
    required this.totalAnalyses,
    required this.onUpload,
    required this.onProfile,
  });

  final String message;
  final int totalAnalyses;
  final VoidCallback onUpload;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF12384C),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(18, 56, 76, 0.14),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Focus for now',
            style: TextStyle(
              fontSize: Responsive.responsiveFontSize(18),
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              fontSize: Responsive.responsiveFontSize(13),
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    totalAnalyses == 0
                        ? 'No baseline yet'
                        : 'Tracking $totalAnalyses saved analysis${totalAnalyses == 1 ? '' : 'es'}',
                    style: TextStyle(
                      fontSize: Responsive.responsiveFontSize(13),
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: onUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF12384C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'New upload',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: onProfile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.32),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Profile settings',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionStrip extends StatelessWidget {
  const _ActionStrip({required this.actions, required this.isWide});

  final List<_ActionData> actions;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        children: actions
            .asMap()
            .entries
            .map(
              (entry) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: entry.key == actions.length - 1
                        ? 0
                        : Responsive.blockSizeHorizontal * 2,
                  ),
                  child: _ActionCard(data: entry.value),
                ),
              ),
            )
            .toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Responsive.blockSizeHorizontal * 3,
        mainAxisSpacing: Responsive.blockSizeVertical * 1.4,
        childAspectRatio: 1.02,
      ),
      itemBuilder: (context, index) {
        return _ActionCard(data: actions[index], compact: true);
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.data, this.compact = false});

  final _ActionData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: EdgeInsets.all(compact ? 12 : 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2ECF3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 36 : 46,
              height: compact ? 36 : 46,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                data.icon,
                color: data.color,
                size: compact ? 18 : 24,
              ),
            ),
            SizedBox(height: compact ? 8 : 14),
            Text(
              data.title,
              style: TextStyle(
                fontSize: Responsive.responsiveFontSize(compact ? 12 : 15),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF14313E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.description,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: Responsive.responsiveFontSize(compact ? 10 : 12),
                color: const Color(0xFF6E818D),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.caption,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final String caption;
  final Color color;
  final IconData icon;
}

class _ActionData {
  const _ActionData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
}
