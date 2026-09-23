import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../edge_llm/edge_llm_service.dart';
import '../cloud_llm/cloud_llm_service.dart';

// Models
class AIRequest {
  final String prompt;
  final bool requiresComplexReasoning;
  final bool containsPrivateData; // e.g., detailed health metrics

  AIRequest({
    required this.prompt,
    this.requiresComplexReasoning = false,
    this.containsPrivateData = false,
  });
}

class AIResponse {
  final String message;
  final String source; // 'edge' or 'cloud'
  final String? voiceText;

  AIResponse({
    required this.message,
    required this.source,
    this.voiceText,
  });
}

abstract class LLMService {
  Future<AIResponse> generateResponse(AIRequest request);
  Stream<String> streamResponse(AIRequest request);
  Future<bool> isAvailable();
}

// Router
class AIRequestRouter {
  final EdgeLLMService edgeLLM;
  final CloudLLMService cloudLLM;

  AIRequestRouter(this.edgeLLM, this.cloudLLM);

  Future<AIResponse> routeRequest(AIRequest request) async {
    // Privacy first: If it contains private data, we prefer edge unless user explicitly opts in to cloud for complex reasoning.
    // For this demo, we strictly route private data to edge.
    if (request.containsPrivateData) {
      if (await edgeLLM.isAvailable()) {
        return edgeLLM.generateResponse(request);
      } else {
        return AIResponse(
          message: "I need to process this privately on your device, but the local AI model is currently unavailable.",
          source: 'system',
        );
      }
    }

    if (request.requiresComplexReasoning) {
      if (await cloudLLM.isAvailable()) {
        try {
          return await cloudLLM.generateResponse(request);
        } catch (e) {
          // Fallback to edge
          if (await edgeLLM.isAvailable()) {
            return await edgeLLM.generateResponse(request);
          }
        }
      }
    }

    // Default to Edge
    if (await edgeLLM.isAvailable()) {
      return await edgeLLM.generateResponse(request);
    } else if (await cloudLLM.isAvailable()) {
      return await cloudLLM.generateResponse(request);
    }

    return AIResponse(
      message: "No AI services are currently available. Please check your connection or download the offline model.",
      source: 'system'
    );
  }
}

final aiRouterProvider = Provider<AIRequestRouter>((ref) {
  return AIRequestRouter(
    ref.read(edgeLLMProvider),
    ref.read(cloudLLMProvider),
  );
});

