import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/app_data.dart';
import '../../models/question_model.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'dart:math';

class LevelCompleteScreen extends StatefulWidget {
  const LevelCompleteScreen({super.key});

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _levelSaved = false;
  late String _levelId;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
      _scaleController.forward();
      _saveLevel();
    });
  }

  Future<void> _saveLevel() async {
    if (_levelSaved) return;
    _levelSaved = true;
    await context.read<AppProvider>().completeLevel(_levelId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _levelId = ModalRoute.of(context)!.settings.arguments as String? ?? 'html';
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;
    final completedLevel = questLevels.firstWhere((l) => l.id == _levelId);
    final levelIdx = questLevels.indexWhere((l) => l.id == _levelId);
    final hasNext = levelIdx < questLevels.length - 1;
    final nextLevel = hasNext ? questLevels[levelIdx + 1] : null;
    final allComplete = user.completedLevels.length >= questLevels.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppColors.primary,
                  AppColors.accent,
                  AppColors.gold,
                  AppColors.success,
                  Colors.pink,
                ],
                numberOfParticles: 30,
                maxBlastForce: 30,
                minBlastForce: 10,
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildCelebrationIcon(completedLevel),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '🎉 Level Complete!',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      completedLevel.name,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '+${completedLevel.xpReward} XP earned!',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // AI Guide message
                    Container(
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
                                const SizedBox(height: 4),
                                Text(
                                  _getAIMessage(completedLevel.id, hasNext, nextLevel?.name),
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
                    // Certificate
                    _buildCertificate(user.username, completedLevel),
                    const SizedBox(height: 24),
                    // Actions
                    if (hasNext && nextLevel != null)
                      GradientButton(
                        text: 'Advance to ${nextLevel.name}',
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/quiz',
                          arguments: nextLevel.id,
                        ),
                        icon: Text(nextLevel.icon,
                            style: const TextStyle(fontSize: 18)),
                      )
                    else if (allComplete)
                      GradientButton(
                        text: '📋 Take Post-Test',
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/posttest'),
                        gradient: const LinearGradient(
                          colors: [AppColors.success, Color(0xFF2E7D32)],
                        ),
                      )
                    else
                      GradientButton(
                        text: '🗺️ Back to Quest Map',
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/quest-map'),
                      ),
                    const SizedBox(height: 12),
                    OutlineButton(
                      text: '📊 View Dashboard',
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/dashboard'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationIcon(QuestLevel level) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.5),
            blurRadius: 32,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Text(level.icon, style: const TextStyle(fontSize: 48)),
      ),
    );
  }

  Widget _buildCertificate(String username, QuestLevel level) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surfaceLight,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 20),
              SizedBox(width: 6),
              Text(
                'Certificate of Completion',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.cardBorder),
          const SizedBox(height: 12),
          Text(
            username,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'has successfully completed',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              level.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'WebCode Quest · ${_formattedDate()}',
            style: const TextStyle(color: AppColors.textHint, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _getAIMessage(String levelId, bool hasNext, String? nextName) {
    if (!hasNext) {
      return 'Outstanding! You\'ve conquered all three zones of WebCode Quest! You are now ready for the final assessment. Take the post-test to see how much you\'ve grown!';
    }
    switch (levelId) {
      case 'html':
        return 'Excellent work! You\'ve mastered HTML — the skeleton of the web. Now head to $nextName where you\'ll learn to make your pages beautiful with CSS styling!';
      case 'css':
        return 'Amazing! You can now style any webpage like a pro. Next up: $nextName, where you\'ll add real interactivity and make things truly dynamic!';
      default:
        return 'Well done! Keep building on what you\'ve learned!';
    }
  }

  String _formattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}
