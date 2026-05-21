import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/app_data.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class PretestResultScreen extends StatelessWidget {
  const PretestResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;
    final level = provider.levelDisplayName;
    final score = user.pretestScore;
    final maxScore = pretestQuestions.length * 5;
    final startLevel = questLevels[user.currentLevelIndex];

    final skillValues = _buildSkillValues(user.pretestAnswers);
    final levelColor = _levelColor(user.level);
    final levelIcon = _levelIcon(user.level);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Level badge
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [levelColor, levelColor.withOpacity(0.6)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: levelColor.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(levelIcon, style: const TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Level',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [levelColor, levelColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    level.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Score: $score / $maxScore',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                // Skills breakdown
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Skill Breakdown'),
                      const SizedBox(height: 16),
                      ...skillValues.entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SkillBar(
                            label: e.key,
                            value: e.value,
                            color: _skillColor(e.key),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // AI Recommendation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_awesome, color: AppColors.accent, size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AI Recommendation',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        provider.pretestRecommendation,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  text: 'Start ${startLevel.name}',
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/quest-map'),
                  icon: Text(startLevel.icon, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, double> _buildSkillValues(List<int> answers) {
    if (answers.length < pretestQuestions.length) {
      return {
        'HTML': 0.5,
        'CSS': 0.5,
        'JavaScript': 0.5,
        'Debugging': 0.5,
        'Problem Solving': 0.5,
        'Confidence': 0.5,
      };
    }
    final result = <String, double>{};
    for (int i = 0; i < pretestQuestions.length; i++) {
      result[pretestQuestions[i].category] = answers[i] / 5.0;
    }
    return result;
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'intermediate':
        return AppColors.secondary;
      case 'advanced':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  String _levelIcon(String level) {
    switch (level) {
      case 'intermediate':
        return '⚔️';
      case 'advanced':
        return '👑';
      default:
        return '🛡️';
    }
  }

  Color _skillColor(String skill) {
    switch (skill) {
      case 'HTML':
        return AppColors.htmlColor;
      case 'CSS':
        return AppColors.cssColor;
      case 'JavaScript':
        return AppColors.jsColor;
      case 'Debugging':
        return AppColors.warning;
      case 'Problem Solving':
        return AppColors.success;
      default:
        return AppColors.accent;
    }
  }
}
