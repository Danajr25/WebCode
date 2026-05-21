import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../data/app_data.dart';

class AppProvider extends ChangeNotifier {
  UserModel? _currentUser;
  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  List<UserModel> get studentUsers =>
      _allUsers.where((u) => u.role == UserRole.student).toList();

  AppProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();

    // Load all users
    final usersJson = prefs.getString('all_users');
    if (usersJson != null) {
      final List<dynamic> list = jsonDecode(usersJson);
      _allUsers = list.map((e) => UserModel.fromJson(e)).toList();
    }

    // Seed default teacher account
    if (!_allUsers.any((u) => u.username == 'teacher')) {
      _allUsers.add(UserModel(
        id: 'teacher_001',
        username: 'teacher',
        passwordHash: _hash('teacher123'),
        role: UserRole.teacher,
      ));
      await _saveUsers();
    }

    // Restore session
    final currentId = prefs.getString('current_user_id');
    if (currentId != null) {
      final found = _allUsers.where((u) => u.id == currentId);
      if (found.isNotEmpty) _currentUser = found.first;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Simple deterministic hash (not for production — local storage only)
  String _hash(String input) {
    int hash = 0;
    for (final char in input.runes) {
      hash = (hash * 31 + char) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }

  Future<bool> login(String username, String password) async {
    final hashed = _hash(password);
    final matches = _allUsers.where(
      (u) => u.username == username && u.passwordHash == hashed,
    );
    if (matches.isEmpty) {
      _error = 'Invalid username or password.';
      notifyListeners();
      return false;
    }
    _currentUser = matches.first;
    _error = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', _currentUser!.id);
    notifyListeners();
    return true;
  }

  Future<bool> register(String username, String password) async {
    if (_allUsers.any((u) => u.username == username)) {
      _error = 'Username already taken.';
      notifyListeners();
      return false;
    }
    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      passwordHash: _hash(password),
    );
    _allUsers.add(newUser);
    _currentUser = newUser;
    _error = null;
    await _saveUsers();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', newUser.id);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── Pretest ──────────────────────────────────────────────────────────────

  Future<void> savePretestResults(List<int> answers) async {
    if (_currentUser == null) return;
    final score = answers.fold(0, (a, b) => a + b);
    final level = getLevelFromScore(score, answers.length * 5);
    final startIndex = getStartingLevelIndex(level);

    _currentUser!.pretestAnswers = answers;
    _currentUser!.pretestScore = score;
    _currentUser!.level = level;
    _currentUser!.currentLevelIndex = startIndex;
    _currentUser!.hasCompletedPretest = true;
    await _saveCurrentUser();
    notifyListeners();
  }

  // ─── Quiz ─────────────────────────────────────────────────────────────────

  Future<void> saveQuizResult(String levelId, int correct, int total) async {
    if (_currentUser == null) return;
    final xpEarned = correct * 50;
    _currentUser!.quizScores[levelId] = correct;
    _currentUser!.xp += xpEarned;

    // Update accuracy as rolling average
    final allScores = _currentUser!.quizScores.values.toList();
    final totalQuestions = allScores.length * total;
    final totalCorrect = allScores.fold(0, (a, b) => a + b);
    _currentUser!.accuracy = totalQuestions > 0
        ? ((totalCorrect / totalQuestions) * 100).round()
        : 0;

    // Update weekly XP
    final dayIndex = DateTime.now().weekday - 1;
    _currentUser!.weeklyXp[dayIndex] += xpEarned;

    _currentUser!.recentActivity.insert(0, {
      'type': 'quiz',
      'levelId': levelId,
      'score': correct,
      'total': total,
      'xp': xpEarned,
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (_currentUser!.recentActivity.length > 10) {
      _currentUser!.recentActivity.removeLast();
    }

    await _saveCurrentUser();
    notifyListeners();
  }

  Future<void> saveChallengeComplete(String levelId) async {
    if (_currentUser == null) return;
    _currentUser!.xp += 100;

    final dayIndex = DateTime.now().weekday - 1;
    _currentUser!.weeklyXp[dayIndex] += 100;

    _currentUser!.recentActivity.insert(0, {
      'type': 'challenge',
      'levelId': levelId,
      'xp': 100,
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (_currentUser!.recentActivity.length > 10) {
      _currentUser!.recentActivity.removeLast();
    }

    await _saveCurrentUser();
    notifyListeners();
  }

  // ─── Level Complete ───────────────────────────────────────────────────────

  Future<void> completeLevel(String levelId) async {
    if (_currentUser == null) return;
    if (!_currentUser!.completedLevels.contains(levelId)) {
      _currentUser!.completedLevels.add(levelId);
    }

    // Award level badge
    final badge = '${levelId}_complete';
    if (!_currentUser!.badges.contains(badge)) {
      _currentUser!.badges.add(badge);
    }

    // Award level XP bonus
    final level = questLevels.firstWhere((l) => l.id == levelId,
        orElse: () => questLevels.first);
    _currentUser!.xp += level.xpReward;

    // Update streak
    _currentUser!.streak++;

    // Advance to next level
    final idx = questLevels.indexWhere((l) => l.id == levelId);
    if (idx >= 0 && idx + 1 < questLevels.length) {
      _currentUser!.currentLevelIndex = idx + 1;
    }

    await _saveCurrentUser();
    notifyListeners();
  }

  // ─── Post-test ────────────────────────────────────────────────────────────

  Future<void> savePosttestResults(List<int> answers) async {
    if (_currentUser == null) return;
    final score = answers.fold(0, (a, b) => a + b);
    final newLevel = getLevelFromScore(score, answers.length * 5);

    _currentUser!.posttestAnswers = answers;
    _currentUser!.posttestScore = score;
    _currentUser!.hasCompletedPosttest = true;

    // Level up if improved
    final levelOrder = ['beginner', 'intermediate', 'advanced'];
    final currentIdx = levelOrder.indexOf(_currentUser!.level);
    final newIdx = levelOrder.indexOf(newLevel);
    if (newIdx > currentIdx) {
      _currentUser!.level = newLevel;
      _currentUser!.badges.add('level_up_${newLevel}');
    }

    // Add XP for completing post-test
    _currentUser!.xp += 200;

    await _saveCurrentUser();
    notifyListeners();
  }

  // ─── Persistence ──────────────────────────────────────────────────────────

  Future<void> _saveCurrentUser() async {
    if (_currentUser == null) return;
    final idx = _allUsers.indexWhere((u) => u.id == _currentUser!.id);
    if (idx >= 0) _allUsers[idx] = _currentUser!;
    await _saveUsers();
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_allUsers.map((u) => u.toJson()).toList());
    await prefs.setString('all_users', json);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String get levelDisplayName {
    switch (_currentUser?.level) {
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return 'Beginner';
    }
  }

  String get pretestRecommendation {
    switch (_currentUser?.level) {
      case 'intermediate':
        return 'You already know the basics! Start from CSS Forest to strengthen your styling skills and dive into JavaScript.';
      case 'advanced':
        return 'Great skills! Jump straight into JavaScript Cave to master interactivity and dynamic web programming.';
      default:
        return 'Start from HTML Village to build a solid foundation. Take your time with each concept and don\'t skip the challenges!';
    }
  }

  String getPosttestAIFeedback() {
    if (_currentUser == null) return '';
    final pre = _currentUser!.pretestScore;
    final post = _currentUser!.posttestScore;
    final diff = post - pre;
    if (diff > 10) {
      return 'Incredible progress! Your self-efficacy score jumped significantly. You\'ve clearly mastered the core concepts. Keep building!';
    } else if (diff > 5) {
      return 'Good improvement! You\'ve grown your confidence and skills through the quests. Keep practicing to solidify your knowledge.';
    } else if (diff >= 0) {
      return 'You\'ve maintained your skills and gained practical experience. Review the lessons you found challenging to boost your confidence further.';
    } else {
      return 'Don\'t be discouraged! Self-assessment can be tricky. Your actual quiz performance shows real improvement. Keep practicing!';
    }
  }
}
