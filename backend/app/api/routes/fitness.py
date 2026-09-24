from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Dict, Any

from app.db.session import get_db
from app.models.models import User, FitnessProfile, WorkoutSession
from app.core.security import get_current_user
from app.schemas.schemas import FitnessProfileCreateOrUpdate, FitnessProfileResponse, ReadinessSummary

router = APIRouter()

@router.get("/profile", response_model=FitnessProfileResponse)
async def get_fitness_profile(
    current_token: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_id = int(current_token["sub"])
    result = await db.execute(select(FitnessProfile).where(FitnessProfile.user_id == user_id))
    profile = result.scalar_one_or_none()
    if not profile:
        profile = FitnessProfile(user_id=user_id)
        db.add(profile)
        await db.commit()
        await db.refresh(profile)
    return profile

@router.put("/profile", response_model=FitnessProfileResponse)
async def update_fitness_profile(
    profile_in: FitnessProfileCreateOrUpdate,
    current_token: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_id = int(current_token["sub"])
    result = await db.execute(select(FitnessProfile).where(FitnessProfile.user_id == user_id))
    profile = result.scalar_one_or_none()
    if not profile:
        profile = FitnessProfile(user_id=user_id)
        db.add(profile)

    for field, value in profile_in.model_dump(exclude_unset=True).items():
        setattr(profile, field, value)

    await db.commit()
    await db.refresh(profile)
    return profile

@router.get("/readiness", response_model=ReadinessSummary)
async def get_readiness_score(
    current_token: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Calculates adaptive recovery/readiness score based on profile metrics."""
    user_id = int(current_token["sub"])
    result = await db.execute(select(FitnessProfile).where(FitnessProfile.user_id == user_id))
    profile = result.scalar_one_or_none()

    sleep = profile.sleep_quality if profile else "good"
    stress = profile.typical_stress_level if profile else "moderate"

    score = 80
    if sleep == "poor":
        score -= 25
    elif sleep == "moderate":
        score -= 10

    if stress == "high":
        score -= 15
    elif stress == "low":
        score += 5

    score = max(10, min(100, score))

    if score >= 75:
        status = "optimal"
        rec = "High recovery today. Great day for progressive overload or high-intensity intervals."
    elif score >= 50:
        status = "moderate"
        rec = "Moderate recovery. Intensity adjusted to 70% with focused warm-up."
    else:
        status = "recovery"
        rec = "Recovery is low. Recommended: 20-minute gentle mobility, stretching, and deep breathing."

    return ReadinessSummary(
        readiness_score=score,
        status=status,
        recovery_recommendation=rec,
        sleep_factor=sleep,
        stress_factor=stress,
    )

@router.get("/progress")
async def get_fitness_progress(
    current_token: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_id = int(current_token["sub"])
    result = await db.execute(
        select(WorkoutSession)
        .where(WorkoutSession.user_id == user_id)
        .order_by(WorkoutSession.started_at.desc())
        .limit(30)
    )
    sessions = result.scalars().all()

    total_workouts = len(sessions)
    total_reps = sum(s.total_reps for s in sessions)
    total_calories = sum(s.calories_burned for s in sessions)
    avg_form = (sum(s.average_form_score for s in sessions) / total_workouts) if total_workouts > 0 else 92.0

    return {
        "total_workouts": total_workouts,
        "total_reps": total_reps,
        "total_calories_burned": round(total_calories, 1),
        "average_form_score": round(avg_form, 1),
        "workout_streak_days": min(total_workouts, 7),
        "recent_sessions": [
            {
                "id": s.id,
                "duration_minutes": round(s.duration_seconds / 60, 1),
                "reps": s.total_reps,
                "form_score": s.average_form_score,
                "calories": s.calories_burned,
                "date": s.started_at.isoformat() if s.started_at else None,
            }
            for s in sessions[:5]
        ]
    }
