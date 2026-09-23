import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectorService {
  final PoseDetector _poseDetector;

  PoseDetectorService()
      : _poseDetector = PoseDetector(options: PoseDetectorOptions(mode: PoseDetectionMode.stream));

  Future<List<Pose>> processImage(InputImage inputImage) async {
    try {
      final poses = await _poseDetector.processImage(inputImage);
      return poses;
    } catch (e) {
      print("Pose detection error: $e");
      return [];
    }
  }

  void close() {
    _poseDetector.close();
  }
}

final poseDetectorProvider = Provider<PoseDetectorService>((ref) {
  return PoseDetectorService();
});
