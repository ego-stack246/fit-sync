# FitSync AI

FitSync AI is a free, privacy-first, adaptive fitness coaching platform that combines Edge AI, Cloud LLMs, and real-time computer vision for personalized workout guidance.

## Features
- **Privacy First**: Zero raw video uploads. All pose tracking and rep counting happen on-device.
- **Hybrid AI Engine**: Routes complex reasoning tasks to Cloud LLM (Gemini) and handles offline/fast queries locally with an Edge LLM mockup.
- **Conversational Coach**: ChatGPT-style conversational UI to adjust workouts on the fly.
- **Voice Interactions**: Hands-free interactions via local TTS and STT.
- **Offline Capable**: Uses Isar local database and edge processing for offline functionality.

## Architecture

![Architecture](docs/architecture.png)
*(Note: Create architecture diagram image for docs folder)*

**Frontend (Flutter)**
- Clean Architecture (Domain, Data, Presentation)
- Riverpod for State Management
- `AIRequestRouter` deciding between `EdgeLLMService` and `CloudLLMService`.
- MediaPipe / Google ML Kit for on-device Vision.

**Backend (FastAPI)**
- Connects to PostgreSQL and Redis via SQLAlchemy/AsyncPG.
- `AIService` wraps the Gemini API to act as the Cloud LLM brain.
- Manages secure user data, authentication (JWT), and workout history.

## Development Setup

### Backend
1. `cd backend`
2. Install Python 3.11+ and `pip install -r requirements.txt`
3. Set up `.env` from `.env.example`
4. Run `docker compose up -d` to spin up PostgreSQL and Redis.
5. Run `uvicorn app.main:app --reload`

### Frontend
1. Install Flutter (>=3.2.0)
2. `cd frontend/flutter_app`
3. `flutter pub get`
4. Run on an iOS/Android simulator or physical device: `flutter run`

## AI Routing Logic
- **Simple Requests**: "How many reps did I do?" -> Routed to Edge LLM.
- **Complex Requests**: "Plan a 4-week split based on my sleep history." -> Routed to Cloud LLM.
- **Privacy Fallback**: If network fails or user disables cloud AI, routes fallback to Edge LLM.

## Privacy & Security
- Raw camera feed is strictly kept on the device.
- Only non-sensitive metrics (e.g., "12 squats completed") are sent to the cloud.
- Environment variables handle all API secrets. No API keys are hardcoded in the Flutter app.

