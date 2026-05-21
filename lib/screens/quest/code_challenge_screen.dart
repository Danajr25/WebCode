import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:provider/provider.dart';
import '../../data/app_data.dart';
import '../../models/question_model.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class CodeChallengeScreen extends StatefulWidget {
  const CodeChallengeScreen({super.key});

  @override
  State<CodeChallengeScreen> createState() => _CodeChallengeScreenState();
}

class _CodeChallengeScreenState extends State<CodeChallengeScreen> {
  late String _levelId;
  late CodeChallenge _challenge;
  late CodeController _codeController;
  bool _showHint = false;
  bool _isRunning = false;
  bool? _passed;
  String _feedback = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _levelId = ModalRoute.of(context)!.settings.arguments as String? ?? 'html';
    _challenge = getChallengeForLevel(_levelId);
    _codeController = CodeController(
      text: _challenge.starterCode,
      language: _getLanguage(_challenge.language),
    );
  }

  dynamic _getLanguage(String lang) {
    switch (lang) {
      case 'css':
        return css;
      case 'javascript':
        return javascript;
      default:
        return xml;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _runCode() async {
    setState(() {
      _isRunning = true;
      _passed = null;
      _feedback = '';
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final code = _codeController.fullText.toLowerCase();
    final allKeywordsFound = _challenge.validationKeywords
        .every((kw) => code.contains(kw.toLowerCase()));

    setState(() {
      _isRunning = false;
      _passed = allKeywordsFound;
      _feedback = allKeywordsFound
          ? '✅ Great job! All required elements are present. Your code looks correct!'
          : '❌ Not quite. Make sure your code includes all the required elements. Check the mission description again.';
    });

    if (allKeywordsFound) {
      await context.read<AppProvider>().saveChallengeComplete(_levelId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMissionCard(),
                      const SizedBox(height: 12),
                      if (_showHint) _buildHintCard(),
                      const SizedBox(height: 8),
                      _buildEditorCard(),
                      const SizedBox(height: 12),
                      _buildExpectedOutput(),
                      const SizedBox(height: 12),
                      if (_feedback.isNotEmpty) _buildFeedbackCard(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final levelData = questLevels.firstWhere((l) => l.id == _levelId);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textSecondary, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          Text(levelData.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _challenge.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  levelData.name,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          XpBadge(xp: 100),
        ],
      ),
    );
  }

  Widget _buildMissionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.15), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Mission Briefing',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _challenge.mission,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintCard() {
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
              _challenge.hint,
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

  Widget _buildEditorCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.code_rounded, color: AppColors.accent, size: 16),
            const SizedBox(width: 6),
            const Text(
              'Code Editor',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _challenge.language.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(minHeight: 200, maxHeight: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CodeTheme(
              data: CodeThemeData(styles: atomOneDarkTheme),
              child: SingleChildScrollView(
                child: CodeField(
                  controller: _codeController,
                  textStyle: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.5,
                  ),
                  background: const Color(0xFF1E2348),
                  lineNumberStyle: const LineNumberStyle(
                    textStyle: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpectedOutput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.preview_rounded, color: AppColors.textSecondary, size: 16),
            SizedBox(width: 6),
            Text(
              'Expected Output',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Text(
            _challenge.expectedOutput,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'monospace',
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (_passed == true)
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (_passed == true)
              ? AppColors.success.withOpacity(0.4)
              : AppColors.error.withOpacity(0.4),
        ),
      ),
      child: Text(
        _feedback,
        style: TextStyle(
          color: (_passed == true) ? AppColors.success : AppColors.error,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlineButton(
                  text: '💡 Hint',
                  onPressed: () => setState(() => _showHint = !_showHint),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GradientButton(
                  text: _isRunning ? 'Running...' : '▶  Run Code',
                  onPressed: _runCode,
                  isLoading: _isRunning,
                ),
              ),
            ],
          ),
          if (_passed == true) ...[
            const SizedBox(height: 10),
            GradientButton(
              text: '🏆  Complete Challenge',
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                '/level-complete',
                arguments: _levelId,
              ),
              gradient: const LinearGradient(
                colors: [AppColors.success, Color(0xFF2E7D32)],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
