import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WellnessBreakScreen extends StatefulWidget {
  const WellnessBreakScreen({super.key});

  @override
  State<WellnessBreakScreen> createState() => _WellnessBreakScreenState();
}

class _WellnessBreakScreenState extends State<WellnessBreakScreen> {
  int _secondsLeft = 120;
  bool _isRunning = false;
  Timer? _timer;

  final List<Map<String, String>> _microStretches = [
    {"name": "Gentle Neck Tilt", "duration": "30s", "desc": "Slowly lower your left ear toward your shoulder. Hold and switch sides."},
    {"name": "Shoulder Rolls", "duration": "30s", "desc": "Roll your shoulders backward 10 times, then forward 10 times."},
    {"name": "Seated Spinal Twist", "duration": "30s", "desc": "Inhale tall, gently rotate your torso to the right, look over shoulder."},
    {"name": "Wrist & Forearm Release", "duration": "30s", "desc": "Extend arms forward, gently pull fingers backward to relieve keyboard strain."},
  ];

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
          _showCompletion();
        }
      });
    }
  }

  void _showCompletion() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Micro-Break Completed! 🎉"),
        content: const Text("Great job relieving desk fatigue. Your posture and focus are revitalized!"),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text("Return to Dashboard")),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wellness Micro-Break"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Circular Countdown Timer
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: _secondsLeft / 120,
                      strokeWidth: 8,
                      color: Colors.teal,
                      backgroundColor: Colors.teal.shade100,
                    ),
                  ),
                  Column(
                    children: [
                      Text("$m:$s", style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const Text("Active Reset", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _toggleTimer,
              icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
              label: Text(_isRunning ? "Pause Break" : "Start 2-Minute Reset"),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("Desk Stretches Routine", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),

            ..._microStretches.map((stretch) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade50,
                      child: const Icon(Icons.accessibility_new_rounded, color: Colors.teal),
                    ),
                    title: Text(stretch["name"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(stretch["desc"]!),
                    trailing: Chip(label: Text(stretch["duration"]!, style: const TextStyle(fontSize: 11))),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
