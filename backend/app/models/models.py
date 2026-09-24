import datetime
from datetime import timezone
from sqlalchemy import (
    Column, Integer, String, Boolean, Float, Text, JSON, ForeignKey, DateTime
)
from sqlalchemy.orm import declarative_base, relationship

Base = declarative_base()

def utc_now():
    return datetime.datetime.now(timezone.utc)

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    name = Column(String(255), nullable=False, default="Fitness Enthusiast")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=utc_now)
    updated_at = Column(DateTime, default=utc_now, onupdate=utc_now)

    # Privacy & Consent Controls (Mandated by Section 9)
    consent_status = Column(Boolean, default=True)
    data_retention_preference = Column(String(50), default="30_days") # 30_days, 90_days, indefinite, local_only
    cloud_ai_preference = Column(Boolean, default=True)
    local_ai_preference = Column(Boolean, default=True)
    analytics_consent = Column(Boolean, default=False)
    raw_video_upload_allowed = Column(Boolean, default=False) # Privacy rule: never upload raw video

    # Relationships
    profile = relationship("FitnessProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    voice_preference = relationship("VoicePreference", back_populates="user", uselist=False, cascade="all, delete-orphan")
    workout_sessions = relationship("WorkoutSession", back_populates="user", cascade="all, delete-orphan")
    meals = relationship("Meal", back_populates="user", cascade="all, delete-orphan")
    ai_conversations = relationship("AIConversation", back_populates="user", cascade="all, delete-orphan")
    wellness_breaks = relationship("WellnessBreak", back_populates="user", cascade="all, delete-orphan")

class FitnessProfile(Base):
    __tablename__ = "fitness_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    age = Column(Integer, nullable=True)
    gender = Column(String(50), nullable=True)
    height = Column(Float, nullable=True) # cm
    weight = Column(Float, nullable=True) # kg
    fitness_level = Column(String(50), default="beginner") # beginner, intermediate, advanced
    fitness_goal = Column(String(100), default="general_fitness") # weight_loss, muscle_gain, endurance, mobility
    available_workout_time = Column(Integer, default=30) # minutes
    equipment_availability = Column(String(100), default="bodyweight_only")
    dietary_preference = Column(String(100), default="vegetarian") # vegetarian, non_veg, vegan, jain
    food_preference = Column(String(100), default="indian") # indian, continental, mixed
    sleep_quality = Column(String(50), default="good") # poor, moderate, good
    typical_stress_level = Column(String(50), default="moderate") # low, moderate, high
    daily_activity_level = Column(String(50), default="sedentary")

    user = relationship("User", back_populates="profile")

class VoicePreference(Base):
    __tablename__ = "voice_preferences"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    voice_name = Column(String(50), default="natural_calm")
    speech_speed = Column(Float, default=1.0)
    pitch = Column(Float, default=1.0)
    volume = Column(Float, default=1.0)
    tone = Column(String(50), default="calm") # calm, energetic, professional, friendly
    coaching_intensity = Column(String(50), default="supportive")
    preferred_language = Column(String(20), default="en")

    user = relationship("User", back_populates="voice_preference")

class Exercise(Base):
    __tablename__ = "exercises"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False)
    category = Column(String(50), default="strength")
    target_muscle = Column(String(100))
    instructions = Column(Text)
    difficulty = Column(String(50), default="beginner")
    calories_per_minute = Column(Float, default=8.0)

class Workout(Base):
    __tablename__ = "workouts"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(150), nullable=False)
    description = Column(Text)
    category = Column(String(50), default="full_body")
    duration_minutes = Column(Integer, default=20)
    difficulty = Column(String(50), default="beginner")
    exercises = Column(JSON, default=list)

class WorkoutSession(Base):
    __tablename__ = "workout_sessions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    workout_id = Column(Integer, ForeignKey("workouts.id"), nullable=True)
    started_at = Column(DateTime, default=utc_now)
    ended_at = Column(DateTime, nullable=True)
    duration_seconds = Column(Integer, default=0)
    total_reps = Column(Integer, default=0)
    average_form_score = Column(Float, default=0.0) # 0 to 100%
    calories_burned = Column(Float, default=0.0)
    exercise_summary = Column(JSON, default=list) # non-sensitive metrics only: reps, form, sets

    user = relationship("User", back_populates="workout_sessions")

class Meal(Base):
    __tablename__ = "meals"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    name = Column(String(150), nullable=False)
    meal_type = Column(String(50), default="lunch") # breakfast, lunch, dinner, snack
    is_indian_food = Column(Boolean, default=True)
    calories = Column(Float, default=0.0)
    protein_grams = Column(Float, default=0.0)
    carbs_grams = Column(Float, default=0.0)
    fat_grams = Column(Float, default=0.0)
    portion_description = Column(String(100), default="1 serving")
    confidence_score = Column(Float, default=0.90)
    logged_at = Column(DateTime, default=utc_now)

    user = relationship("User", back_populates="meals")

class AIConversation(Base):
    __tablename__ = "ai_conversations"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String(150), default="Workout Consultation")
    created_at = Column(DateTime, default=utc_now)

    user = relationship("User", back_populates="ai_conversations")
    messages = relationship("AIMessage", back_populates="conversation", cascade="all, delete-orphan")

class AIMessage(Base):
    __tablename__ = "ai_messages"

    id = Column(Integer, primary_key=True, index=True)
    conversation_id = Column(Integer, ForeignKey("ai_conversations.id"), nullable=False)
    role = Column(String(20), nullable=False) # user, assistant, system
    content = Column(Text, nullable=False)
    source = Column(String(20), default="edge") # edge, cloud
    created_at = Column(DateTime, default=utc_now)

    conversation = relationship("AIConversation", back_populates="messages")

class WellnessBreak(Base):
    __tablename__ = "wellness_breaks"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    break_type = Column(String(100), default="neck_stretch") # neck_stretch, eye_rest, micro_movement
    duration_seconds = Column(Integer, default=120)
    completed = Column(Boolean, default=True)
    completed_at = Column(DateTime, default=utc_now)

    user = relationship("User", back_populates="wellness_breaks")

