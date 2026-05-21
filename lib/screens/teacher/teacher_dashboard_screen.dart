import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/app_data.dart';
import '../../models/user_model.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final students = provider.studentUsers;

    final avgXp = students.isEmpty
        ? 0
        : (students.fold(0, (a, b) => a + b.xp) / students.length).round();

    final avgAccuracy = students.isEmpty
        ? 0
        : (students.fold(0, (a, b) => a + b.accuracy) / students.length).round();

    final atRisk = students.where((s) => s.accuracy < 50 && s.xp < 200).toList();
    final topPerformers = List<UserModel>.from(students)
      ..sort((a, b) => b.xp.compareTo(a.xp));

    final levelDistribution = _getLevelDistribution(students);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, provider),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _buildOverviewCards(students.length, avgAccuracy, atRisk.length),
                    const SizedBox(height: 12),
                    _buildLevelDistributionChart(levelDistribution),
                    const SizedBox(height: 12),
                    if (atRisk.isNotEmpty) _buildAtRiskSection(atRisk),
                    if (atRisk.isNotEmpty) const SizedBox(height: 12),
                    _buildTopPerformers(topPerformers.take(5).toList()),
                    const SizedBox(height: 12),
                    _buildAIInsight(atRisk.length, students.length, avgAccuracy),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            text: '💬 Message Class',
                            onPressed: () => _showMessageDialog(context),
                            height: 44,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlineButton(
                            text: '📤 Export Report',
                            onPressed: () => _showExportDialog(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teacher Dashboard',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'WebCode Quest · Class Overview',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            onPressed: () async {
              await provider.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(int total, int avgAccuracy, int atRiskCount) {
    return Row(
      children: [
        Expanded(
          child: _overviewCard(
            icon: Icons.people_rounded,
            color: AppColors.primary,
            value: '$total',
            label: 'Students',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _overviewCard(
            icon: Icons.gps_fixed_rounded,
            color: AppColors.success,
            value: '$avgAccuracy%',
            label: 'Avg. Accuracy',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _overviewCard(
            icon: Icons.warning_amber_rounded,
            color: AppColors.error,
            value: '$atRiskCount',
            label: 'At Risk',
          ),
        ),
      ],
    );
  }

  Widget _overviewCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      borderColor: color.withOpacity(0.3),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelDistributionChart(Map<String, int> distribution) {
    final total = distribution.values.fold(0, (a, b) => a + b);
    final colors = {
      'beginner': AppColors.primary,
      'intermediate': AppColors.secondary,
      'advanced': AppColors.success,
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Level Distribution'),
          const SizedBox(height: 16),
          if (total == 0)
            const Text(
              'No student data yet.',
              style: TextStyle(color: AppColors.textHint),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sections: distribution.entries.where((e) => e.value > 0).map((e) {
                        return PieChartSectionData(
                          color: colors[e.key] ?? AppColors.primary,
                          value: e.value.toDouble(),
                          title: '${((e.value / total) * 100).round()}%',
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          radius: 50,
                        );
                      }).toList(),
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: distribution.entries.map((e) {
                      final color = colors[e.key] ?? AppColors.primary;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _capitalize(e.key),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${e.value}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAtRiskSection(List<UserModel> students) {
    return AppCard(
      borderColor: AppColors.error.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: SectionHeader(
                  title: 'Needs Extra Attention',
                  subtitle: 'Low XP & accuracy — may need help',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...students.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        s.username[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.username,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${s.xp} XP · ${s.accuracy}% accuracy · ${_capitalize(s.level)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'At Risk',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformers(List<UserModel> students) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Top Performers'),
          const SizedBox(height: 12),
          if (students.isEmpty)
            const Text(
              'No student data yet.',
              style: TextStyle(color: AppColors.textHint),
            )
          else
            ...students.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: e.key == 0
                                ? AppColors.goldGradient
                                : e.key == 1
                                    ? const LinearGradient(
                                        colors: [Color(0xFFC0C0C0), Color(0xFF888888)])
                                    : const LinearGradient(
                                        colors: [Color(0xFFCD7F32), Color(0xFF8B4513)]),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '#${e.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.value.username,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${e.value.completedLevels.length} levels · ${e.value.streak} day streak',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        XpBadge(xp: e.value.xp, fontSize: 11),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildAIInsight(int atRisk, int total, int avgAccuracy) {
    String insight;
    if (total == 0) {
      insight = 'No students have registered yet. Share the app with your students to get started!';
    } else if (atRisk > total * 0.3) {
      insight = '⚠️ More than 30% of students are at risk. Consider scheduling a review session focusing on HTML fundamentals and encourage students to retry quiz challenges.';
    } else if (avgAccuracy > 75) {
      insight = '✨ Excellent class performance! The majority of students are performing above 75% accuracy. Consider introducing bonus challenges to keep top performers engaged.';
    } else {
      insight = '📊 Class is progressing steadily. Monitor students who haven\'t completed HTML Village yet and provide additional support for those with accuracy below 60%.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Insight',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  insight,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getLevelDistribution(List<UserModel> students) {
    final dist = {'beginner': 0, 'intermediate': 0, 'advanced': 0};
    for (final s in students) {
      dist[s.level] = (dist[s.level] ?? 0) + 1;
    }
    return dist;
  }

  void _showMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Message Class',
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          maxLines: 4,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Write a message to all students...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Message sent to all students!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Send', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Export Report',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Class report will be exported. In production, this would generate a PDF or CSV file.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report exported successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child:
                const Text('Export', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
