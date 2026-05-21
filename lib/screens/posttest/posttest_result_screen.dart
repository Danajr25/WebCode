import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/app_data.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class PosttestResultScreen extends StatelessWidget {
  const PosttestResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;
    final preScore = user.pretestScore;
    final postScore = user.posttestScore;
    final preMax = pretestQuestions.length * 5;
    final postMax = posttestQuestions.length * 5;
    final improved = postScore / postMax > preScore / preMax;
    final levelUp = provider.levelDisplayName.toLowerCase() != 'beginner' ||
        user.badges.any((b) => b.startsWith('level_up'));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Header
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: improved
                        ? const LinearGradient(
                            colors: [AppColors.success, Color(0xFF2E7D32)])
                        : AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (improved ? AppColors.success : AppColors.primary)
                            .withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      improved ? '🚀' : '💪',
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  improved ? 'Level Up! 🎉' : 'Assessment Complete!',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  improved
                      ? '${_capitalize(_prevLevel(user))} → ${provider.levelDisplayName}'
                      : 'You\'ve completed the full WebCode Quest!',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                // Score Comparison
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Score Comparison'),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 160,
                        child: BarChart(
                          BarChartData(
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: preScore.toDouble(),
                                    color: AppColors.textSecondary,
                                    width: 40,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8)),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: postScore.toDouble(),
                                    gradient: AppColors.primaryGradient,
                                    width: 40,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8)),
                                  ),
                                ],
                              ),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, m) => Text(
                                    v == 0 ? 'Pre-Test' : 'Post-Test',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                            maxY: postMax.toDouble() * 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _scoreChip('Pre', preScore, preMax, AppColors.textSecondary),
                          const Icon(Icons.arrow_forward_rounded,
                              color: AppColors.primary),
                          _scoreChip('Post', postScore, postMax, AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Skill Breakdown comparison
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Skill Breakdown',
                        subtitle: 'Light bar = pre-test',
                      ),
                      const SizedBox(height: 16),
                      ..._buildSkillBars(user),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // AI Guide
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.accent.withOpacity(0.4)),
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
                        child: const Icon(Icons.smart_toy_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Guide',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              provider.getPosttestAIFeedback(),
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
                ),
                const SizedBox(height: 24),
                GradientButton(
                  text: '📊 Back to Dashboard',
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/dashboard'),
                ),
                const SizedBox(height: 12),
                OutlineButton(
                  text: '🗺️ Quest Map',
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/quest-map'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreChip(String label, int score, int max, Color color) {
    return Column(
      children: [
        Text(
          '$score / $max',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  List<Widget> _buildSkillBars(user) {
    final preAnswers = List<int>.from(user.pretestAnswers);
    final postAnswers = List<int>.from(user.posttestAnswers);

    final preSkills = <String, double>{};
    final postSkills = <String, double>{};

    for (int i = 0; i < pretestQuestions.length && i < preAnswers.length; i++) {
      preSkills[pretestQuestions[i].category] = preAnswers[i] / 5.0;
    }
    for (int i = 0; i < posttestQuestions.length && i < postAnswers.length; i++) {
      // Use first occurrence only for matching categories
      final cat = posttestQuestions[i].category;
      if (!postSkills.containsKey(cat)) {
        postSkills[cat] = postAnswers[i] / 5.0;
      }
    }

    final categories = [
      'HTML', 'CSS', 'JavaScript', 'Debugging', 'Problem Solving', 'Confidence'
    ];
    final colors = {
      'HTML': AppColors.htmlColor,
      'CSS': AppColors.cssColor,
      'JavaScript': AppColors.jsColor,
      'Debugging': AppColors.warning,
      'Problem Solving': AppColors.success,
      'Confidence': AppColors.accent,
    };

    return categories.map((cat) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SkillBar(
          label: cat,
          value: postSkills[cat] ?? 0.5,
          preValue: preSkills[cat],
          color: colors[cat] ?? AppColors.primary,
        ),
      );
    }).toList();
  }

  String _prevLevel(user) {
    if (user.badges.contains('level_up_advanced')) return 'intermediate';
    if (user.badges.contains('level_up_intermediate')) return 'beginner';
    return 'beginner';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
