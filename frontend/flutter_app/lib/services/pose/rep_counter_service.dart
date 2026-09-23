import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math' as math;

class RepCounterService {
  int _repCount = 0;
  bool _isDown = false;

  int get repCount => _repCount;

  void processPose(Pose pose, String exerciseType) {
    if (exerciseType == "squat") {
      _countSquat(pose);
    }
    // Add logic for pushups, etc.
  }

  void _countSquat(Pose pose) {
    // simplified angle calculation logic for squats
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final knee = pose.landmarks[PoseLandmarkType.leftKnee];
    final ankle = pose.landmarks[PoseLandmarkType.leftAnkle];

    if (hip != null && knee != null && ankle != null) {
      double angle = _calculateAngle(hip.x, hip.y, knee.x, knee.y, ankle.x, ankle.y);
      
      // Thresholds for a squat
      if (angle < 90) { // Deep enough
        _isDown = true;
      } else if (angle > 160 && _isDown) { // Stood back up
        _repCount++;
        _isDown = false;
      }
    }
  }

  double _calculateAngle(double ax, double ay, double bx, double by, double cx, double cy) {
    double radians = math.atan2(cy - by, cx - bx) - math.atan2(ay - by, ax - bx);
    double angle = radians * 180.0 / math.pi;
    if (angle < 0.0) {
      angle += 360.0;
    }
    return angle > 180.0 ? 360.0 - angle : angle;
  }
}
