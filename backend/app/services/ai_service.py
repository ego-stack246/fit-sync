import os
import re
from typing import Dict, Any, Optional, List
from app.core.config import settings

try:
    import google.generativeai as genai
    _GENAI_AVAILABLE = True
except ImportError:
    _GENAI_AVAILABLE = False

class AIService:
    def __init__(self):
        self.api_key = settings.GEMINI_API_KEY
        self.model = None
        if _GENAI_AVAILABLE and self.api_key:
            try:
                genai.configure(api_key=self.api_key)
                self.model = genai.GenerativeModel("gemini-1.5-flash")
            except Exception as e:
                print(f"Warning: Gemini init failed: {e}")

    def _detect_action(self, text: str) -> List[Dict[str, Any]]:
        """Extracts structured app actions from user prompt or assistant intent."""
        lower = text.lower()
        actions = []
        if "start" in lower and "workout" in lower:
            actions.append({"action": "START_WORKOUT", "payload": {"workout_type": "adaptive_daily"}})
        elif "skip" in lower and "exercise" in lower:
            actions.append({"action": "SKIP_EXERCISE", "payload": {}})
        elif "pause" in lower and "workout" in lower:
            actions.append({"action": "PAUSE_WORKOUT", "payload": {}})
        elif "log" in lower and ("meal" in lower or "food" in lower or "ate" in lower):
            actions.append({"action": "LOG_MEAL", "payload": {"intent": "prompt_user_meal_scanner"}})
        elif "create" in lower and "workout" in lower:
            actions.append({"action": "CREATE_WORKOUT", "payload": {"custom": True}})
        return actions

    async def generate_coach_response(
        self,
        prompt: str,
        user_context: Optional[Dict[str, Any]] = None,
        conversation_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """Generates conversational, ChatGPT-like fitness response with structured actions."""
        detected_actions = self._detect_action(prompt)

        # Base context extraction
        ctx = user_context or {}
        fitness_goal = ctx.get("fitness_goal", "general fitness")
        fitness_level = ctx.get("fitness_level", "beginner")
        readiness = ctx.get("readiness_score", 85)

        system_instruction = (
            "You are FitSync AI, an empathetic, privacy-first, certified AI fitness companion. "
            f"User Context: Goal={fitness_goal}, Level={fitness_level}, RecoveryScore={readiness}. "
            "Rules:\n"
            "1. Give concise, conversational, motivational, actionable coaching.\n"
            "2. Never expose internal reasoning or chain-of-thought.\n"
            "3. If user mentions acute pain or injury, advise stopping and consulting a healthcare professional.\n"
            "4. Never claim medical diagnosis."
        )

        response_text = ""
        source = "cloud"

        if self.model:
            try:
                full_prompt = f"{system_instruction}\nUser: {prompt}\nCoach:"
                result = self.model.generate_content(full_prompt)
                response_text = result.text.strip()
            except Exception as e:
                response_text = self._fallback_rule_response(prompt, readiness, fitness_goal)
                source = "edge"
        else:
            response_text = self._fallback_rule_response(prompt, readiness, fitness_goal)
            source = "edge"

        # Voice text: shorter punchy version for TTS
        voice_text = response_text.split("\n")[0]
        if len(voice_text) > 140:
            voice_text = voice_text[:137] + "..."

        return {
            "message": response_text,
            "source": source,
            "conversation_id": conversation_id or "conv_default",
            "actions": detected_actions,
            "recommendations": [
                "Keep knees tracked over toes during squats",
                "Maintain hydration: sip water every 15 minutes",
                "Ensure 7+ hours of sleep for muscle recovery"
            ],
            "voice_text": voice_text,
            "requires_confirmation": False
        }

    def _fallback_rule_response(self, prompt: str, readiness: int, goal: str) -> str:
        """High-quality conversational fallback when running offline or without cloud API key."""
        lower = prompt.lower()
        if "tired" in lower or "sleep" in lower or "exhausted" in lower:
            return (
                f"I noticed your energy is lower today. Since recovery is key for your {goal}, "
                "I recommend dialing back intensity: let's do a 15-minute gentle mobility routine "
                "and focus on light stretches rather than heavy resistance."
            )
        elif "knee" in lower and ("hurt" in lower or "pain" in lower):
            return (
                "Please stop any exercise that causes sharp knee pain immediately. "
                "Ensure your knees do not collapse inward during squats and your weight stays centered through mid-foot. "
                "If pain persists, please consult a medical professional."
            )
        elif "protein" in lower or "eat" in lower or "diet" in lower:
            return (
                "For your fitness goals, aim for 1.2 to 1.6 grams of protein per kg of body weight. "
                "Great Indian sources include paneer, dal, moong sprouts, Greek yogurt/curd, eggs, and roasted chana."
            )
        elif "start" in lower or "workout" in lower:
            return "All set! Let's kick off today's adaptive workout with a 3-minute dynamic warm-up to prepare your joints."
        else:
            return (
                f"Great question! Based on your current recovery score of {readiness}%, "
                f"you are on track for your {goal}. Focus on smooth, controlled tempo and proper alignment during every repetition."
            )

ai_service = AIService()
