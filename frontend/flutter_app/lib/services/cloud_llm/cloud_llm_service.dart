import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ai_router/ai_router.dart';
// import 'package:dio/dio.dart';

class CloudLLMService implements LLMService {
  @override
  Future<bool> isAvailable() async {
    // Check network connectivity in a real app
    return true; 
  }

  @override
  Future<AIResponse> generateResponse(AIRequest request) async {
    // In a real app, make API call to FastAPI backend which then calls Gemini
    await Future.delayed(const Duration(seconds: 1));
    return AIResponse(
      message: "Processed in cloud: Here is a detailed, personalized plan based on your history for: '${request.prompt}'.",
      source: 'cloud',
      voiceText: "Here is your detailed plan.",
    );
  }

  @override
  Stream<String> streamResponse(AIRequest request) async* {
    yield "Processed in cloud: ";
    yield "Here is a detailed, ";
    yield "personalized plan.";
  }
}

final cloudLLMProvider = Provider<CloudLLMService>((ref) => CloudLLMService());

