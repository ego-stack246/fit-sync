from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from app.services.ai_service import ai_service
# In a real app, Depends(get_current_user) would be here

router = APIRouter()

class AIRequest(BaseModel):
    prompt: str
    user_context: dict

class AIResponse(BaseModel):
    response: str
    source: str = "cloud"

@router.post("/chat", response_model=AIResponse)
async def chat_with_coach(request: AIRequest):
    # Simulated auth context
    response_text = await ai_service.generate_coach_response(request.user_context, request.prompt)
    return AIResponse(response=response_text)
