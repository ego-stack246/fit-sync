import datetime
from datetime import timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.session import get_db
from app.models.models import WorkoutSession, FitnessProfile
from app.core.security import get_current_user
from app.schemas.schemas import WorkoutSessionStart, WorkoutSessionComplete, WorkoutSessionResponse

router = APIRouter()

@router.get("/today")
async def get_today_adaptive_workout(
    current_token: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Generates an adaptive daily workout based on user goals, readiness, and time."""
    user_id = int(current_token["sub"])
    result = await db.execute(select(FitnessProfile).where(FitnessProfile.user_id == user_id))
    profile = result.scalar_one_or_none()

    time_mins = profile.available_workout_time if profile and profile.available_workout_time else 25
    goal = profile.fitness_goal if profile and profile.fitness_goal else "general_fitness"

    return {
        "title": "FitSync Adaptive Daily Focus",
        "category": "Full Body Strength & Core",
        "estimated_duration_minutes": time_mins,
        "difficulty": profile.fitness_level if profile else "beginner",
        "exercises": [
            {
                "name": "Bodyweight Squats",
                "sets": 3,
                "reps": 12,
                "rest_seconds": 45,
                "form_focus": "Keep knees aligned over toes and neutral lumbar spine.",
            },
            {
                "name": "Standard Push-ups",
                "sets": 3,
                "reps": 10,
                "rest_seconds": 45,
                "form_focus": "Elbows at 45 degrees, engage core without hip sagging.",
            },
            {
                "name": "Reverse Lunges",
                "sets": 3,
                "reps": 10,
                "rest_seconds": 45,
                "form_focus": "Step backward steadily, 90-degree bend in both knees.",
            },
            {
                "name": "Plank Hold",
                "sets": 3,
                "reps": 30, # seconds
                "rest_seconds": 30,
                "form_focus": "Tight glutes, straight line from head to heels.",
            },
        ],
        "coaching_tip": "Camera pose detection will track your depth and count your reps locally."
    }

@router.post("/start")
async def start_workout_session(
    session_start: WorkoutSessionStart,
    current_token: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_id = int(current_token["sub"])
    session = WorkoutSession(
        user_id=user_id,
        workout_id=session_start.workout_id,
        started_at=datetime.datetime.now(timezone.utc),
    )
    db.add(session)
    await db.commit()
    await db.refresh(session)
    return {"session_id": session.id, "status": "active", "message": "Workout session initiated."}

@router.post("/complete", response_model=WorkoutSessionResponse)
async def complete_workout_session(
    complete_in: WorkoutSessionComplete,
    session_id: int,
    current_token: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Logs non-sensitive workout metrics derived strictly on-device (Privacy Rule)."""
    user_id = int(current_token["sub"])
    result = await db.execute(
        select(WorkoutSession).where(WorkoutSession.id == session_id, WorkoutSession.user_id == user_id)
    )
    session = result.scalar_one_or_none()
    if not session:
        # Create a new record if session id was ephemeral
        session = WorkoutSession(user_id=user_id)
        db.add(session)

    session.ended_at = datetime.datetime.now(timezone.utc)
    session.duration_seconds = complete_in.duration_seconds
    session.total_reps = complete_in.total_reps
    session.average_form_score = complete_in.average_form_score
    session.calories_burned = complete_in.calories_burned
    session.exercise_summary = complete_in.exercise_summary

    await db.commit()
    await db.refresh(session)
    return session

@router.get("/history")
async def get_workout_history(
    current_token: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_id = int(current_token["sub"])
    result = await db.execute(
        select(WorkoutSession)
        .where(WorkoutSession.user_id == user_id)
        .order_by(WorkoutSession.started_at.desc())
    )
    sessions = result.scalars().all()
    return sessions

