enum UserRole { student, teacher }

class UserModel {
  final String id;
  final String username;
  final String passwordHash;
  final UserRole role;
  int xp;
  int streak;
  int accuracy;
  String level; // 'beginner', 'intermediate', 'advanced'
  List<String> completedLevels;
  List<String> badges;
  int currentLevelIndex; // 0=HTML, 1=CSS, 2=JS
  int pretestScore;
  int posttestScore;
  bool hasCompletedPretest;
  bool hasCompletedPosttest;
  List<int> pretestAnswers;
  List<int> posttestAnswers;
  Map<String, int> quizScores; // levelId -> score
  List<Map<String, dynamic>> recentActivity;
  List<int> weeklyXp;

  UserModel({
    required this.id,
    required this.username,
    required this.passwordHash,
    this.role = UserRole.student,
    this.xp = 0,
    this.streak = 0,
    this.accuracy = 0,
    this.level = 'beginner',
    List<String>? completedLevels,
    List<String>? badges,
    this.currentLevelIndex = 0,
    this.pretestScore = 0,
    this.posttestScore = 0,
    this.hasCompletedPretest = false,
    this.hasCompletedPosttest = false,
    List<int>? pretestAnswers,
    List<int>? posttestAnswers,
    Map<String, int>? quizScores,
    List<Map<String, dynamic>>? recentActivity,
    List<int>? weeklyXp,
  })  : completedLevels = completedLevels ?? [],
        badges = badges ?? [],
        pretestAnswers = pretestAnswers ?? [],
        posttestAnswers = posttestAnswers ?? [],
        quizScores = quizScores ?? {},
        recentActivity = recentActivity ?? [],
        weeklyXp = weeklyXp ?? [0, 0, 0, 0, 0, 0, 0];

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'passwordHash': passwordHash,
        'role': role.name,
        'xp': xp,
        'streak': streak,
        'accuracy': accuracy,
        'level': level,
        'completedLevels': completedLevels,
        'badges': badges,
        'currentLevelIndex': currentLevelIndex,
        'pretestScore': pretestScore,
        'posttestScore': posttestScore,
        'hasCompletedPretest': hasCompletedPretest,
        'hasCompletedPosttest': hasCompletedPosttest,
        'pretestAnswers': pretestAnswers,
        'posttestAnswers': posttestAnswers,
        'quizScores': quizScores,
        'recentActivity': recentActivity,
        'weeklyXp': weeklyXp,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        username: json['username'],
        passwordHash: json['passwordHash'],
        role: UserRole.values.firstWhere((r) => r.name == json['role'],
            orElse: () => UserRole.student),
        xp: json['xp'] ?? 0,
        streak: json['streak'] ?? 0,
        accuracy: json['accuracy'] ?? 0,
        level: json['level'] ?? 'beginner',
        completedLevels: List<String>.from(json['completedLevels'] ?? []),
        badges: List<String>.from(json['badges'] ?? []),
        currentLevelIndex: json['currentLevelIndex'] ?? 0,
        pretestScore: json['pretestScore'] ?? 0,
        posttestScore: json['posttestScore'] ?? 0,
        hasCompletedPretest: json['hasCompletedPretest'] ?? false,
        hasCompletedPosttest: json['hasCompletedPosttest'] ?? false,
        pretestAnswers: List<int>.from(json['pretestAnswers'] ?? []),
        posttestAnswers: List<int>.from(json['posttestAnswers'] ?? []),
        quizScores: Map<String, int>.from(json['quizScores'] ?? {}),
        recentActivity:
            List<Map<String, dynamic>>.from(json['recentActivity'] ?? []),
        weeklyXp: List<int>.from(json['weeklyXp'] ?? [0, 0, 0, 0, 0, 0, 0]),
      );
}
