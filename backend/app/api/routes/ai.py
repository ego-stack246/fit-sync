import asyncio
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from typing import Dict, Any

from app.services.ai_service import ai_service
from app.schemas.schemas import AIRequest, AIResponse

router = APIRouter()

@router.post("/chat", response_model=AIResponse)
async def chat_with_ai(request: AIRequest):
    """Conversational AI Coach endpoint following ChatGPT-style conversational experience."""
    result = await ai_service.generate_coach_response(
        prompt=request.prompt,
        user_context=request.user_context,
        conversation_id=request.conversation_id,
    )
    return AIResponse(**result)

@router.post("/plan")
async def generate_workout_plan(request: AIRequest):
    """Cloud AI Adaptive Multi-day workout planner."""
    result = await ai_service.generate_coach_response(
        prompt=f"Create a structured adaptive fitness plan: {request.prompt}",
        user_context=request.user_context,
        conversation_id=request.conversation_id,
    )
    return result

@router.post("/nutrition")
async def generate_nutrition_advice(request: AIRequest):
    """Cloud AI Nutrition reasoning with Indian food guidance."""
    result = await ai_service.generate_coach_response(
        prompt=f"Provide nutrition guidance: {request.prompt}",
        user_context=request.user_context,
        conversation_id=request.conversation_id,
    )
    return result

@router.post("/coach")
async def real_time_coach_event(request: AIRequest):
    """Real-time coaching query during workout sessions."""
    result = await ai_service.generate_coach_response(
        prompt=request.prompt,
        user_context=request.user_context,
        conversation_id=request.conversation_id,
    )
    return result

@router.websocket("/stream")
async def websocket_ai_stream(websocket: WebSocket):
    """Real-time streaming WebSocket endpoint for conversational voice and chat tokens."""
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_text()
            response = await ai_service.generate_coach_response(prompt=data)
            full_msg = response["message"]

            # Stream words with realistic conversational pace
            words = full_msg.split(" ")
            for i, word in enumerate(words):
                chunk = word + (" " if i < len(words) - 1 else "")
                await websocket.send_json({"chunk": chunk, "is_last": i == len(words) - 1})
                await asyncio.sleep(0.04)

            # Send final structured action payload
            await websocket.send_json({
                "type": "completed",
                "actions": response["actions"],
                "voice_text": response["voice_text"],
                "source": response["source"]
            })
    except WebSocketDisconnect:
        pass
