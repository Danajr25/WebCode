class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String hint;
  final String levelId;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.hint,
    required this.levelId,
  });
}

class CodeChallenge {
  final String id;
  final String levelId;
  final String title;
  final String mission;
  final String starterCode;
  final String expectedOutput;
  final String hint;
  final String language;
  final List<String> validationKeywords;

  const CodeChallenge({
    required this.id,
    required this.levelId,
    required this.title,
    required this.mission,
    required this.starterCode,
    required this.expectedOutput,
    required this.hint,
    required this.language,
    required this.validationKeywords,
  });
}

class QuestLevel {
  final String id;
  final String name;
  final String subtitle;
  final String icon;
  final String description;
  final int xpReward;
  final String color;

  const QuestLevel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.description,
    required this.xpReward,
    required this.color,
  });
}

class IpsasQuestion {
  final String id;
  final String text;
  final String category;

  const IpsasQuestion({
    required this.id,
    required this.text,
    required this.category,
  });
}
