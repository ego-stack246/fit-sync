import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
              child: Icon(Icons.person, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hi, Shivam 👋", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text("Recovery: Moderate (72%)", style: theme.textTheme.bodySmall?.copyWith(color: Colors.green.shade700)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Recommendation Banner (Requested Example)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer.withOpacity(0.7),
                    theme.colorScheme.surfaceVariant.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("AI Coach Recommendation", style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          '"Good evening, Shivam. Your recovery looks moderate today, so I reduced your workout intensity to 4 sets with longer rest periods."',
                          style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Today's Workout Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: const Text("Today's Focus"),
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                          labelStyle: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                          padding: EdgeInsets.zero,
                        ),
                        Row(
                          children: const [
                            Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text("20 Mins", style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Adaptive Lower Body & Core", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text("Squats, Lunges, Pushups & Core Plank with real-time pose tracking.", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => context.push('/workout'),
                        icon: const Icon(Icons.play_arrow_rounded, size: 24),
                        label: const Text("Start Workout (Camera Pose AI)", style: TextStyle(fontSize: 16)),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Daily Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    theme,
                    title: "Streak",
                    value: "5 Days 🔥",
                    subtitle: "Personal Record!",
                    icon: Icons.local_fire_department_rounded,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    theme,
                    title: "Form Score",
                    value: "94%",
                    subtitle: "+3% vs last week",
                    icon: Icons.check_circle_outline_rounded,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    theme,
                    title: "Calories",
                    value: "420 kcal",
                    subtitle: "Goal: 500 kcal",
                    icon: Icons.flash_on_rounded,
                    color: Colors.amber.shade800,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    theme,
                    title: "Active Time",
                    value: "32 mins",
                    subtitle: "Target: 40 mins",
                    icon: Icons.fitness_center_rounded,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Wellness Break Reminder
            Card(
              color: Colors.teal.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.shade700,
                  child: const Icon(Icons.self_improvement_rounded, color: Colors.white),
                ),
                title: const Text("Micro-Break: 2-Min Neck Stretch", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("You have been seated for 2 hours. Tap to refresh."),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () => context.push('/wellness'),
              ),
            ),
            const SizedBox(height: 80), // Padding for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (idx) {
          if (idx == 0) return;
          if (idx == 1) context.push('/workout');
          if (idx == 2) context.push('/nutrition');
          if (idx == 3) context.push('/ai_coach');
          if (idx == 4) context.push('/progress');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: "Home"),
          NavigationDestination(icon: Icon(Icons.fitness_center_rounded), label: "Workout"),
          NavigationDestination(icon: Icon(Icons.restaurant_rounded), label: "Nutrition"),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), label: "AI Coach"),
          NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: "Progress"),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ai_coach'),
        icon: const Icon(Icons.mic_rounded),
        label: const Text("Ask AI Coach"),
      ),
    );
  }

  Widget _buildMetricCard(
    ThemeData theme, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
