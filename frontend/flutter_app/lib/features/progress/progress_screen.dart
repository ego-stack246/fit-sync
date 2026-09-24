import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress & Analytics"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak & Volume Highlights Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat("5 Days", "Current Streak", Icons.local_fire_department_rounded, Colors.orange),
                        _buildStat("1,420 kg", "Total Volume", Icons.fitness_center_rounded, Colors.blue),
                        _buildStat("94%", "Avg Form Score", Icons.verified_rounded, Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text("Weekly Workout Form Trend", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Weekly Form Bar Chart Simulation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar("Mon", 0.88, "88%"),
                      _buildBar("Tue", 0.92, "92%"),
                      _buildBar("Wed", 0.90, "90%"),
                      _buildBar("Thu", 0.95, "95%"),
                      _buildBar("Fri", 0.94, "94%"),
                      _buildBar("Sat", 0.96, "96%"),
                      _buildBar("Sun", 0.0, "Rest"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text("Recent Personal Records", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.emoji_events_rounded, color: Colors.white)),
                title: const Text("Bodyweight Squats", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("15 reps with 96% form accuracy"),
                trailing: const Text("Yesterday", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.emoji_events_rounded, color: Colors.white)),
                title: const Text("Forearm Plank", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("45 seconds continuous hold"),
                trailing: const Text("3 days ago", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildBar(String day, double percentage, String label) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: percentage == 0.0 ? 6 : (percentage * 80),
          decoration: BoxDecoration(
            color: percentage == 0.0 ? Colors.grey.shade400 : Colors.green.shade600,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
