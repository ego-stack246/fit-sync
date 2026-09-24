import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  int _reps = 8;
  final int _targetReps = 12;
  int _currentSet = 2;
  final int _totalSets = 3;
  double _formScore = 93.0; // %
  String _tempoStatus = "Optimal Tempo";
  String _voiceFeedback = "Keep your chest high and drive through heels.";
  int _secondsElapsed = 145;
  bool _isPaused = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _simulatePoseDetection();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_isPaused && mounted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  void _simulatePoseDetection() {
    // Simulates on-device MediaPipe rep counting & angle evaluation
    Timer.periodic(const Duration(seconds: 4), (t) {
      if (!_isPaused && mounted && _reps < _targetReps) {
        setState(() {
          _reps++;
          if (_reps == 10) {
            _voiceFeedback = "Two more reps! Maintain that depth.";
            _formScore = 95.0;
          } else if (_reps == _targetReps) {
            _voiceFeedback = "Excellent set! Take a 45-second rest.";
            _tempoStatus = "Set Completed";
          } else {
            _voiceFeedback = "Great alignment. Go slightly lower.";
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Feed Simulation with Skeleton Overlay
            Positioned.fill(
              child: Container(
                color: const Color(0xFF1A1A1A),
                child: CustomPaint(
                  painter: PoseSkeletonPainter(),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videocam_rounded, size: 48, color: Colors.white24),
                        const SizedBox(height: 8),
                        Text(
                          "Local Camera Feed (Edge AI Processing)",
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                        ),
                        Text(
                          "Zero cloud video streaming — 100% On-Device",
                          style: TextStyle(color: Colors.green.withOpacity(0.6), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Top Header: Exercise, Timer & Privacy Badge
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _formatTime(_secondsElapsed),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade900.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.lock_outline_rounded, color: Colors.greenAccent, size: 14),
                        SizedBox(width: 4),
                        Text("On-Device AI", style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),

            // Center Floating Live Coaching Voice Feedback Pill
            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.record_voice_over_rounded, color: Colors.lightBlueAccent, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _voiceFeedback,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Performance HUD Card
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF222222).withOpacity(0.92),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("BODYWEIGHT SQUAT", style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text("Set $_currentSet of $_totalSets", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_tempoStatus, style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Metrics Row (Reps, Form Score, Calories)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHUDMetric("REPS", "$_reps/$_targetReps", Colors.amberAccent),
                        _buildHUDMetric("FORM SCORE", "${_formScore.toInt()}%", Colors.greenAccent),
                        _buildHUDMetric("EST. CALS", "48 kcal", Colors.orangeAccent),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Interactive Controls
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => setState(() => _isPaused = !_isPaused),
                            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause, color: Colors.white),
                            label: Text(_isPaused ? "Resume" : "Pause", style: const TextStyle(color: Colors.white)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              context.pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Workout session completed & saved privately!")),
                              );
                            },
                            icon: const Icon(Icons.check_circle_rounded),
                            label: const Text("Finish Set"),
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHUDMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class PoseSkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.lightBlueAccent.withOpacity(0.65)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final jointPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.fill;

    // Simulated skeleton keypoints in center of screen
    final head = Offset(size.width * 0.5, size.height * 0.28);
    final lShoulder = Offset(size.width * 0.42, size.height * 0.35);
    final rShoulder = Offset(size.width * 0.58, size.height * 0.35);
    final lHip = Offset(size.width * 0.44, size.height * 0.52);
    final rHip = Offset(size.width * 0.56, size.height * 0.52);
    final lKnee = Offset(size.width * 0.40, size.height * 0.65);
    final rKnee = Offset(size.width * 0.60, size.height * 0.65);
    final lAnkle = Offset(size.width * 0.42, size.height * 0.78);
    final rAnkle = Offset(size.width * 0.58, size.height * 0.78);

    // Draw bones
    canvas.drawLine(lShoulder, rShoulder, linePaint);
    canvas.drawLine(lShoulder, lHip, linePaint);
    canvas.drawLine(rShoulder, rHip, linePaint);
    canvas.drawLine(lHip, rHip, linePaint);
    canvas.drawLine(lHip, lKnee, linePaint);
    canvas.drawLine(rHip, rKnee, linePaint);
    canvas.drawLine(lKnee, lAnkle, linePaint);
    canvas.drawLine(rKnee, rAnkle, linePaint);

    // Draw joints
    for (final pt in [head, lShoulder, rShoulder, lHip, rHip, lKnee, rKnee, lAnkle, rAnkle]) {
      canvas.drawCircle(pt, 5.0, jointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

