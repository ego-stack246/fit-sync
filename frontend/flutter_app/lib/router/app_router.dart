import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/splash_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/home/home_dashboard_screen.dart';
import '../features/ai_coach/ai_coach_screen.dart';
import '../features/workout/workout_screen.dart';
import '../features/nutrition/nutrition_scanner_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/wellness/wellness_break_screen.dart';
import '../features/profile/profile_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeDashboardScreen(),
      ),
      GoRoute(
        path: '/ai_coach',
        builder: (context, state) => const AICoachScreen(),
      ),
      GoRoute(
        path: '/workout',
        builder: (context, state) => const WorkoutScreen(),
      ),
      GoRoute(
        path: '/nutrition',
        builder: (context, state) => const NutritionScannerScreen(),
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/wellness',
        builder: (context, state) => const WellnessBreakScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
