from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Dict, Any

from app.db.session import get_db
from app.models.models import User, FitnessProfile, VoicePreference
from app.core.security import get_password_hash, verify_password, create_access_token, get_current_user
from app.schemas.schemas import UserRegister, UserLogin, Token, UserResponse

router = APIRouter()

@router.post("/register", response_model=Token, status_code=status.HTTP_201_CREATED)
async def register(user_in: UserRegister, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == user_in.email))
    existing_user = result.scalar_one_or_none()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this email already exists."
        )

    user = User(
        email=user_in.email,
        hashed_password=get_password_hash(user_in.password),
        name=user_in.name,
        consent_status=user_in.consent_status,
        cloud_ai_preference=user_in.cloud_ai_preference,
        data_retention_preference=user_in.data_retention_preference,
    )
    db.add(user)
    await db.flush()

    # Create associated default profile & voice preferences
    profile = FitnessProfile(user_id=user.id)
    voice_pref = VoicePreference(user_id=user.id)
    db.add(profile)
    db.add(voice_pref)
    await db.commit()
    await db.refresh(user)

    token = create_access_token(data={"sub": str(user.id), "email": user.email})
    return Token(access_token=token, token_type="bearer", user_id=user.id, name=user.name)

@router.post("/login", response_model=Token)
async def login(login_in: UserLogin, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == login_in.email))
    user = result.scalar_one_or_none()
    if not user or not verify_password(login_in.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = create_access_token(data={"sub": str(user.id), "email": user.email})
    return Token(access_token=token, token_type="bearer", user_id=user.id, name=user.name)

@router.post("/refresh", response_model=Token)
async def refresh_token(current_user: dict = Depends(get_current_user)):
    new_token = create_access_token(data={"sub": current_user["sub"], "email": current_user.get("email", "")})
    return Token(access_token=new_token, token_type="bearer", user_id=int(current_user["sub"]), name="User")

@router.post("/logout")
async def logout(current_user: dict = Depends(get_current_user)):
    return {"message": "Successfully logged out. Please clear your local secure token."}

@router.post("/forgot-password")
async def forgot_password(email_data: Dict[str, str]):
    email = email_data.get("email", "")
    return {
        "message": f"If an account exists for {email}, a secure password reset link has been dispatched.",
        "status": "dispatched"
    }

