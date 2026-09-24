from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.db.session import init_db
from app.api.routes import auth, users, fitness, workouts, exercises, nutrition, ai, voice

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize database tables on startup
    await init_db()
    yield

app = FastAPI(
    title="FitSync AI Backend",
    description="Privacy-First, Free, Adaptive Fitness & AI Coaching Platform API",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include all API modules specified in product requirements
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(users.router, prefix="/api/users", tags=["users"])
app.include_router(fitness.router, prefix="/api/fitness", tags=["fitness"])
app.include_router(workouts.router, prefix="/api/workouts", tags=["workouts"])
app.include_router(exercises.router, prefix="/api/exercises", tags=["exercises"])
app.include_router(nutrition.router, prefix="/api/nutrition", tags=["nutrition"])
app.include_router(ai.router, prefix="/api/ai", tags=["ai"])
app.include_router(voice.router, prefix="/api/voice", tags=["voice"])

@app.get("/")
async def root():
    return {
        "app": "FitSync AI API",
        "status": "online",
        "version": "1.0.0",
        "privacy": "Zero-Raw-Video-Upload: Computer vision runs on-device",
        "docs": "/docs"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
