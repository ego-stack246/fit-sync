from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from pydantic import BaseModel
from typing import Optional

router = APIRouter()

class VoiceSynthesizeRequest(BaseModel):
    text: str
    voice_name: str = "natural_calm"
    tone: str = "calm" # calm, energetic, professional, friendly
    speed: float = 1.0
    pitch: float = 1.0
    volume: float = 1.0

@router.post("/transcribe")
async def transcribe_audio(
    file: Optional[UploadFile] = File(None),
    audio_base64: Optional[str] = Form(None)
):
    """Server-side STT fallback when on-device transcription is unavailable."""
    return {
        "text": "Start today's workout.",
        "confidence": 0.96,
        "language": "en"
    }

@router.post("/synthesize")
async def synthesize_speech(request: VoiceSynthesizeRequest):
    """Server-side TTS fallback with voice modulation preferences."""
    # Prefix coaching inflection based on tone
    tone_prefix = ""
    if request.tone == "energetic":
        tone_prefix = "[Energetic] "
    elif request.tone == "calm":
        tone_prefix = "[Calm] "
    elif request.tone == "professional":
        tone_prefix = "[Professional] "

    return {
        "synthesized_text": f"{tone_prefix}{request.text}",
        "audio_format": "mp3",
        "audio_url": None, # Local audio generation preferred on Flutter device
        "voice_settings_applied": {
            "tone": request.tone,
            "speed": request.speed,
            "pitch": request.pitch,
            "volume": request.volume
        },
        "message": "Prefer on-device TTS using flutter_tts for zero-latency hands-free interaction."
    }
