import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import screens (to be implemented)
// import '../features/auth/presentation/screens/splash_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('FitSync AI Splash/Dashboard - Coming Soon')),
        ),
      ),
      // Add other routes here: /onboarding, /auth, /home, /workout, /ai_coach
    ],
  );
});

