import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/user_model.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/pretest/pretest_screen.dart';
import 'screens/pretest/pretest_result_screen.dart';
import 'screens/quest/quiz_screen.dart';
import 'screens/quest/code_challenge_screen.dart';
import 'screens/quest/level_complete_screen.dart';
import 'screens/posttest/posttest_screen.dart';
import 'screens/posttest/posttest_result_screen.dart';
import 'screens/teacher/teacher_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const WebCodeQuestApp());
}

class WebCodeQuestApp extends StatelessWidget {
  const WebCodeQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'WebCode Quest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/',
        routes: {
          '/': (ctx) => const SplashRouter(),
          '/login': (ctx) => const LoginScreen(),
          '/register': (ctx) => const RegisterScreen(),
          '/pretest': (ctx) => const PretestScreen(),
          '/pretest-result': (ctx) => const PretestResultScreen(),
          '/quest-map': (ctx) => const HomeScreen(initialIndex: 1),
          '/quiz': (ctx) => const QuizScreen(),
          '/code-challenge': (ctx) => const CodeChallengeScreen(),
          '/level-complete': (ctx) => const LevelCompleteScreen(),
          '/dashboard': (ctx) => const HomeScreen(initialIndex: 0),
          '/posttest': (ctx) => const PosttestScreen(),
          '/posttest-result': (ctx) => const PosttestResultScreen(),
          '/teacher-dashboard': (ctx) => const TeacherDashboardScreen(),
        },
      ),
    );
  }
}

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate());
  }

  void _navigate() {
    final provider = context.read<AppProvider>();
    if (provider.isLoading) {
      provider.addListener(_onProviderReady);
      return;
    }
    _doNavigate(provider);
  }

  void _onProviderReady() {
    final provider = context.read<AppProvider>();
    if (!provider.isLoading) {
      provider.removeListener(_onProviderReady);
      if (mounted) _doNavigate(provider);
    }
  }

  void _doNavigate(AppProvider provider) {
    if (!provider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final user = provider.currentUser!;
      if (user.role == UserRole.teacher) {
        Navigator.pushReplacementNamed(context, '/teacher-dashboard');
      } else if (!user.hasCompletedPretest) {
        Navigator.pushReplacementNamed(context, '/pretest');
      } else {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.shield_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'WebCode Quest',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
