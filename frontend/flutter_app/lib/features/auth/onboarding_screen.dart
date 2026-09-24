import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form State
  String name = "Shivam";
  int age = 24;
  double height = 175.0; // cm
  double weight = 70.0; // kg
  String fitnessLevel = "Beginner";
  String fitnessGoal = "Muscle Gain";
  int workoutTime = 25; // minutes
  String equipment = "Bodyweight & Dumbbells";
  String dietaryPref = "Vegetarian";
  String foodPref = "Indian";
  String sleepQuality = "Good (7-8 hrs)";
  String stressLevel = "Moderate";
  String activityLevel = "Moderately Active";

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to FitSync AI", style: theme.textTheme.titleMedium),
        actions: [
          TextButton(
            onPressed: () => context.go('/auth'),
            child: const Text("Skip"),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Privacy Promise Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Your workout camera video is processed on your device and is not uploaded to the cloud.",
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                children: [
                  _buildProfileStep(theme),
                  _buildFitnessGoalsStep(theme),
                  _buildLifestyleStep(theme),
                ],
              ),
            ),

            // Bottom Navigation Controls
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? theme.colorScheme.primary : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _nextPage,
                    icon: Icon(_currentPage == 2 ? Icons.check_circle : Icons.arrow_forward_rounded),
                    label: Text(_currentPage == 2 ? "Get Started" : "Continue"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Let's personalize your coach", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Basic biometrics enable precise workout load and calorie estimation.", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: name,
            decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
            onChanged: (val) => name = val,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: age.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder()),
                  onChanged: (val) => age = int.tryParse(val) ?? age,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: "Male",
                  decoration: const InputDecoration(labelText: "Gender", border: OutlineInputBorder()),
                  items: ["Male", "Female", "Prefer not to say"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: height.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Height (cm)", border: OutlineInputBorder()),
                  onChanged: (val) => height = double.tryParse(val) ?? height,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: weight.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Weight (kg)", border: OutlineInputBorder()),
                  onChanged: (val) => weight = double.tryParse(val) ?? weight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessGoalsStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Goals & Equipment", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("The AI adapts your routine based on available gear and time.", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: fitnessGoal,
            decoration: const InputDecoration(labelText: "Primary Fitness Goal", border: OutlineInputBorder()),
            items: ["Weight Loss", "Muscle Gain", "Cardio Endurance", "Mobility & Recovery"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (val) => setState(() => fitnessGoal = val ?? fitnessGoal),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: fitnessLevel,
            decoration: const InputDecoration(labelText: "Current Fitness Level", border: OutlineInputBorder()),
            items: ["Beginner", "Intermediate", "Advanced Athlete"].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
            onChanged: (val) => setState(() => fitnessLevel = val ?? fitnessLevel),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: workoutTime,
            decoration: const InputDecoration(labelText: "Available Daily Time (Minutes)", border: OutlineInputBorder()),
            items: [15, 20, 30, 45, 60].map((t) => DropdownMenuItem(value: t, child: Text("$t Minutes"))).toList(),
            onChanged: (val) => setState(() => workoutTime = val ?? workoutTime),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: equipment,
            decoration: const InputDecoration(labelText: "Available Equipment", border: OutlineInputBorder()),
            items: ["Bodyweight Only", "Bodyweight & Dumbbells", "Full Home Gym"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => equipment = val ?? equipment),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Diet & Recovery Context", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("FitSync AI factors sleep, stress, and Indian diet preferences into your recovery scores.", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: dietaryPref,
            decoration: const InputDecoration(labelText: "Dietary Preference", border: OutlineInputBorder()),
            items: ["Vegetarian", "Non-Vegetarian", "Vegan", "Jain", "Eggetarian"].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (val) => setState(() => dietaryPref = val ?? dietaryPref),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: foodPref,
            decoration: const InputDecoration(labelText: "Food Style Preference", border: OutlineInputBorder()),
            items: ["Indian Cuisine", "Continental", "Balanced Mixed"].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
            onChanged: (val) => setState(() => foodPref = val ?? foodPref),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: sleepQuality,
            decoration: const InputDecoration(labelText: "Typical Sleep Duration", border: OutlineInputBorder()),
            items: ["Poor (< 5 hrs)", "Moderate (5-6 hrs)", "Good (7-8 hrs)", "Optimal (> 8 hrs)"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) => setState(() => sleepQuality = val ?? sleepQuality),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: stressLevel,
            decoration: const InputDecoration(labelText: "Daily Stress Level", border: OutlineInputBorder()),
            items: ["Low", "Moderate", "High"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) => setState(() => stressLevel = val ?? stressLevel),
          ),
        ],
      ),
    );
  }
}

