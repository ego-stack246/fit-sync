import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ai_router/ai_router.dart';

class EdgeLLMService implements LLMService {
  @override
  Future<bool> isAvailable() async {
    // In a real app, this checks if the TFLite/MediaPipe LLM model is downloaded and loaded.
    return true;
  }

  @override
  Future<AIResponse> generateResponse(AIRequest request) async {
    // Mock local inference delay
    await Future.delayed(const Duration(milliseconds: 500));
    return AIResponse(
      message: "Processed locally: Here is a quick answer to your request: '${request.prompt}'.",
      source: 'edge',
      voiceText: "Here is a quick answer.",
    );
  }

  @override
  Stream<String> streamResponse(AIRequest request) async* {
    yield "Processed locally: ";
    yield "Here is ";
    yield "a quick answer.";
  }
}

final edgeLLMProvider = Provider<EdgeLLMService>((ref) => EdgeLLMService());

