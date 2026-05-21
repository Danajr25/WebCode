import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/app_data.dart';
import '../../models/question_model.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late String _levelId;
  late List<QuizQuestion> _questions;
  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  bool _showHint = false;
  int _correctCount = 0;
  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _feedbackAnimation = CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _levelId = ModalRoute.of(context)!.settings.arguments as String? ?? 'html';
    _questions = allQuestions[_levelId] ?? htmlQuizQuestions;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      _showHint = false;
      if (index == _questions[_currentIndex].correctIndex) {
        _correctCount++;
      }
    });
    _feedbackController.forward(from: 0);
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
        _showHint = false;
      });
      _feedbackController.reset();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    await context.read<AppProvider>().saveQuizResult(
          _levelId,
          _correctCount,
          _questions.length,
        );
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/code-challenge',
      arguments: _levelId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    final isLast = _currentIndex == _questions.length - 1;
    final levelData = questLevels.firstWhere((l) => l.id == _levelId);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(levelData),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuestion(q),
                      const SizedBox(height: 16),
                      if (_showHint) _buildHintCard(q),
                      const SizedBox(height: 8),
                      ...q.options.asMap().entries.map(
                            (e) => _buildOption(e.key, e.value, q),
                          ),
                      const SizedBox(height: 16),
                      if (_answered) _buildExplanation(q),
                    ],
                  ),
                ),
              ),
              _buildFooter(q, isLast),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(QuestLevel levelData) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => _showQuitDialog(),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(levelData.icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      levelData.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              XpBadge(xp: 50),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Q${_currentIndex + 1} / ${_questions.length}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + (_answered ? 1 : 0)) / _questions.length,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    '$_correctCount',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(QuizQuestion q) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        q.question,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildHintCard(QuizQuestion q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: AppColors.gold, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              q.hint,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(int index, String text, QuizQuestion q) {
    final isSelected = _selectedOption == index;
    final isCorrect = index == q.correctIndex;
    Color borderColor = AppColors.cardBorder;
    Color bgColor = AppColors.surface;
    Widget? trailing;

    if (_answered) {
      if (isCorrect) {
        borderColor = AppColors.success;
        bgColor = AppColors.success.withOpacity(0.1);
        trailing = const Icon(Icons.check_circle_rounded, color: AppColors.success);
      } else if (isSelected && !isCorrect) {
        borderColor = AppColors.error;
        bgColor = AppColors.error.withOpacity(0.1);
        trailing = const Icon(Icons.cancel_rounded, color: AppColors.error);
      }
    } else if (isSelected) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primary.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: () => _selectOption(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _answered && isCorrect
                    ? AppColors.success
                    : _answered && isSelected && !isCorrect
                        ? AppColors.error
                        : isSelected
                            ? AppColors.primary
                            : AppColors.surfaceLight,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: isSelected || (_answered && isCorrect)
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: _answered && isCorrect
                      ? AppColors.success
                      : _answered && isSelected && !isCorrect
                          ? AppColors.error
                          : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation(QuizQuestion q) {
    final isCorrect = _selectedOption == q.correctIndex;
    return ScaleTransition(
      scale: _feedbackAnimation,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCorrect
              ? AppColors.success.withOpacity(0.1)
              : AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCorrect
                ? AppColors.success.withOpacity(0.4)
                : AppColors.error.withOpacity(0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.celebration_rounded : Icons.info_outline,
                  color: isCorrect ? AppColors.success : AppColors.error,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isCorrect ? '🎉 Correct!' : '❌ Not quite...',
                  style: TextStyle(
                    color: isCorrect ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              q.explanation,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(QuizQuestion q, bool isLast) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Row(
        children: [
          if (!_answered)
            Expanded(
              child: OutlineButton(
                text: '💡 Hint',
                onPressed: () => setState(() => _showHint = !_showHint),
              ),
            ),
          if (!_answered) const SizedBox(width: 12),
          Expanded(
            flex: _answered ? 1 : 1,
            child: GradientButton(
              text: _answered
                  ? (isLast ? '🏆 Finish Quiz' : 'Next Question ➜')
                  : 'Submit Answer',
              onPressed: _answered
                  ? _nextQuestion
                  : (_selectedOption != null ? () => _selectOption(_selectedOption!) : () {}),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Quit Quiz?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Your progress will not be saved.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/quest-map');
            },
            child: const Text('Quit', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
