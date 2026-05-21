import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/app_data.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;
    final maxXp = 2500;
    final allComplete = user.completedLevels.length >= questLevels.length;

    return Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, user, provider),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _buildXpCard(user, maxXp),
                    const SizedBox(height: 12),
                    _buildStatsRow(user),
                    const SizedBox(height: 12),
                    _buildBadgesSection(user),
                    const SizedBox(height: 12),
                    _buildVillageProgress(context, user),
                    const SizedBox(height: 12),
                    _buildRecentActivity(user),
                    const SizedBox(height: 12),
                    _buildWeeklyChart(user),
                    const SizedBox(height: 12),
                    if (allComplete && !user.hasCompletedPosttest) ...[
                      GradientButton(
                        text: '📋 Take Post-Test Assessment',
                        onPressed: () => Navigator.pushNamed(context, '/posttest'),
                        gradient: const LinearGradient(
                          colors: [AppColors.success, Color(0xFF2E7D32)],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildHeader(BuildContext context, user, AppProvider provider) {
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
            child: Center(
              child: Text(
                user.username.isNotEmpty
                    ? user.username[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, ${user.username}! 👋',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  provider.levelDisplayName,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
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

  Widget _buildXpCard(user, int maxXp) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${user.xp} / $maxXp XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (user.xp / maxXp).clamp(0.0, 1.0),
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${maxXp - user.xp} XP to max level',
            style: const TextStyle(color: AppColors.textHint, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(user) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.local_fire_department,
            iconColor: Colors.orange,
            value: '${user.streak}',
            label: 'Day Streak',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.gps_fixed_rounded,
            iconColor: AppColors.success,
            value: '${user.accuracy}%',
            label: 'Accuracy',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.emoji_events_rounded,
            iconColor: AppColors.gold,
            value: '${user.badges.length}',
            label: 'Badges',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
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

  Widget _buildBadgesSection(user) {
    final badgeData = {
      'html_complete': {'icon': '🏘️', 'label': 'HTML Master'},
      'css_complete': {'icon': '🌲', 'label': 'CSS Artist'},
      'js_complete': {'icon': '⚡', 'label': 'JS Wizard'},
      'level_up_intermediate': {'icon': '⚔️', 'label': 'Level Up!'},
      'level_up_advanced': {'icon': '👑', 'label': 'Advanced!'},
    };

    final earned = List<String>.from(
        user.badges.where((b) => badgeData.containsKey(b)));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Badges',
            subtitle: '${earned.length} earned',
          ),
          const SizedBox(height: 12),
          if (earned.isEmpty)
            const Text(
              'Complete levels to earn badges!',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: earned.map<Widget>((b) {
                final data = badgeData[b]!;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(data['icon']!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        data['label']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildVillageProgress(BuildContext context, user) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Village Progress'),
          const SizedBox(height: 14),
          ...questLevels.asMap().entries.map<Widget>((e) {
            final idx = e.key;
            final level = e.value;
            final isComplete = user.completedLevels.contains(level.id);
            final isActive = idx == user.currentLevelIndex && !isComplete;
            final isLocked = idx > user.currentLevelIndex;
            final color = _hexToColor(level.color);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? AppColors.surfaceLight
                          : color.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isComplete
                            ? AppColors.success
                            : isActive
                                ? AppColors.primary
                                : AppColors.cardBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: isLocked
                          ? const Icon(Icons.lock_outline, color: AppColors.textHint, size: 18)
                          : Text(level.icon, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.name,
                          style: TextStyle(
                            color: isLocked
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: isComplete
                                ? 1.0
                                : isActive
                                    ? 0.5
                                    : 0.0,
                            backgroundColor: AppColors.surfaceLight,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isComplete ? AppColors.success : AppColors.primary,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? AppColors.success.withOpacity(0.15)
                          : isActive
                              ? AppColors.primary.withOpacity(0.15)
                              : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isComplete ? '✓ Done' : isActive ? 'Active' : 'Locked',
                      style: TextStyle(
                        color: isComplete
                            ? AppColors.success
                            : isActive
                                ? AppColors.primary
                                : AppColors.textHint,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(user) {
    final activities = List<Map<String, dynamic>>.from(user.recentActivity);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Recent Activity',
            subtitle: '${activities.length} events',
          ),
          const SizedBox(height: 12),
          if (activities.isEmpty)
            const Text(
              'No activity yet. Start a quest!',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
            )
          else
            ...activities.take(5).map<Widget>((a) {
              final isQuiz = a['type'] == 'quiz';
              final levelId = a['levelId'] as String;
              final level =
                  questLevels.firstWhere((l) => l.id == levelId, orElse: () => questLevels.first);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          isQuiz ? '📝' : '💻',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isQuiz
                                ? '${level.name} Quiz: ${a['score']}/${a['total']} correct'
                                : '${level.name} Challenge Complete',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatDate(a['timestamp'] as String),
                            style: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    XpBadge(xp: a['xp'] as int, fontSize: 11),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(user) {
    final weeklyXp = List<int>.from(user.weeklyXp);
    final maxVal = weeklyXp.reduce((a, b) => a > b ? a : b).toDouble();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Weekly Performance'),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                barGroups: weeklyXp.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.toDouble(),
                        gradient: AppColors.primaryGradient,
                        width: 22,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxVal > 0 ? maxVal * 1.2 : 100,
                          color: AppColors.surfaceLight,
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) => Text(
                        days[v.toInt()],
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return 'Recently';
    }
  }

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}
