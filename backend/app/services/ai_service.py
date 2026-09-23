import google.generativeai as genai
from app.core.config import settings

class AIService:
    def __init__(self):
        if settings.GEMINI_API_KEY:
            genai.configure(api_key=settings.GEMINI_API_KEY)
            self.model = genai.GenerativeModel('gemini-1.5-flash') # Using flash for speed/cost
        else:
            self.model = None

    async def generate_coach_response(self, user_context: dict, prompt: str) -> str:
        if not self.model:
            return "Demo mode: AI cloud processing is disabled because GEMINI_API_KEY is not set."
            
        system_instruction = f"""
        You are FitSync AI, a highly intelligent and adaptive fitness coach.
        User Context: {user_context}
        Keep your responses concise, conversational, and helpful. Do not output your internal reasoning.
        """
        
        try:
            # Using generate_content for a single turn. For full chat, we would use start_chat.
            response = self.model.generate_content(f"{system_instruction}\nUser: {prompt}")
            return response.text
        except Exception as e:
            return f"An error occurred while generating a response: {str(e)}"

ai_service = AIService()
