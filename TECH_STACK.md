# WebCode Quest — Tech Stack & Dependencies

## Language & Framework

| Technology | Version | Purpose |
|---|---|---|
| **Dart** | 3.10.7 | Programming language |
| **Flutter** | 3.38.6 (stable) | Mobile UI framework |

---

## Flutter Dependencies (`pubspec.yaml`)

### Runtime Dependencies

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.2 | State management (`ChangeNotifier` / `context.watch`) |
| `shared_preferences` | ^2.3.3 | Local data persistence — stores user progress, scores, and login state as JSON |
| `fl_chart` | ^0.69.0 | Bar charts and pie charts in the student & teacher dashboards |
| `confetti` | ^0.7.0 | Confetti animation on the Level Complete screen |
| `google_fonts` | ^6.2.1 | Poppins font throughout the app |
| `flutter_code_editor` | ^0.3.2 | In-app code editor with syntax highlighting for code challenges |
| `flutter_highlight` | ^0.7.0 | Syntax highlighting engine used by the code editor |
| `highlight` | ^0.7.0 | Core highlight.js port for Dart (dependency of flutter_highlight) |
| `cupertino_icons` | ^1.0.8 | iOS-style icons (bundled with Flutter starter template) |

### Dev Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_test` | SDK | Unit and widget testing framework |
| `flutter_lints` | ^6.0.0 | Recommended Dart lint rules |

---

## Architecture & Patterns

- **Pattern**: Provider + `ChangeNotifier` for reactive state
- **Persistence**: `SharedPreferences` — all data serialised to/from JSON strings
- **Navigation**: Named routes (`Navigator.pushNamed`) with a `BottomNavigationBar` (`NavigationBar`) shell (`HomeScreen`) for the main student views
- **Theming**: Centralised `AppTheme.darkTheme` (dark navy/purple colour palette) + `AppColors` constants

---

## Project Structure

```
lib/
├── main.dart                  # Entry point, routes, Provider setup
├── data/
│   └── app_data.dart          # Static quest levels, questions, badge data
├── models/
│   ├── user_model.dart        # UserModel, UserRole enum
│   └── question_model.dart    # QuestLevel, Question, CodeChallenge models
├── providers/
│   └── app_provider.dart      # AppProvider (ChangeNotifier) — all app state
├── theme/
│   └── app_theme.dart         # Dark theme + AppColors constants
├── widgets/
│   └── common_widgets.dart    # GradientButton, OutlineButton, XpBar, etc.
└── screens/
    ├── home_screen.dart        # NavigationBar shell (Dashboard + Quest Map)
    ├── auth/
    │   ├── login_screen.dart
    │   └── register_screen.dart
    ├── pretest/
    │   ├── pretest_screen.dart
    │   └── pretest_result_screen.dart
    ├── quest/
    │   ├── quest_map_screen.dart
    │   ├── quiz_screen.dart
    │   ├── code_challenge_screen.dart
    │   └── level_complete_screen.dart
    ├── dashboard/
    │   └── student_dashboard_screen.dart
    ├── posttest/
    │   ├── posttest_screen.dart
    │   └── posttest_result_screen.dart
    └── teacher/
        └── teacher_dashboard_screen.dart
```

---

## Build & Tooling

| Tool | Version / Detail |
|---|---|
| **Flutter SDK** | `C:\Users\User\Desktop\flutter` |
| **Android SDK** | `C:\Users\User\AppData\Local\Android\Sdk` |
| **Gradle** | Used via Flutter's Android build pipeline |
| **ADB** | `platform-tools` — wireless debugging over Wi-Fi |
| **VS Code** | IDE with Flutter & Dart extensions |

### Build Commands

```bash
# Install dependencies
flutter pub get

# Run on connected device (wireless ADB)
flutter run -d <device-ip>:<port>

# Build release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk (~49.4 MB)
```

---

## Colour Palette

| Name | Hex | Usage |
|---|---|---|
| Background | `#0A0E27` | App background gradient start |
| Surface | `#141836` | Cards and containers |
| Primary (Purple) | `#7C6FFF` | Buttons, accents, navigation |
| Accent (Cyan) | `#00D4FF` | Highlights, XP bar |
| Gold | `#FFD700` | Badges, XP rewards |
| Success (Green) | `#4CAF50` | Completed levels, post-test prompt |

---

## Target Platform

- **Android** (primary) — tested on Realme RMX3780 (Android 14)
- iOS support possible via Flutter's cross-platform build, not yet configured
