from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Dict, Any

from app.db.session import get_db
from app.models.models import User
from app.core.security import get_current_user
from app.schemas.schemas import UserResponse

router = APIRouter()

@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(
    current_token: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_id = int(current_token["sub"])
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.put("/me", response_model=UserResponse)
async def update_current_user(
    update_data: Dict[str, Any],
    current_token: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_id = int(current_token["sub"])
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if "name" in update_data:
        user.name = update_data["name"]
    if "consent_status" in update_data:
        user.consent_status = update_data["consent_status"]
    if "cloud_ai_preference" in update_data:
        user.cloud_ai_preference = update_data["cloud_ai_preference"]
    if "local_ai_preference" in update_data:
        user.local_ai_preference = update_data["local_ai_preference"]
    if "data_retention_preference" in update_data:
        user.data_retention_preference = update_data["data_retention_preference"]

    await db.commit()
    await db.refresh(user)
    return user

@router.delete("/me", status_code=status.HTTP_200_OK)
async def delete_current_user_account(
    current_token: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Privacy Rule: Complete account & associated biometric/workout data deletion."""
    user_id = int(current_token["sub"])
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    await db.delete(user)
    await db.commit()
    return {"message": "All user account records, workout metrics, and profiles have been completely erased."}

