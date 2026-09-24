from pydantic import BaseModel, EmailStr, Field, ConfigDict
from typing import Optional, List, Dict, Any
import datetime

# --- Auth Schemas ---
class UserRegister(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    name: str = "Fitness Enthusiast"
    consent_status: bool = True
    cloud_ai_preference: bool = True
    data_retention_preference: str = "30_days"

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: int
    name: str

class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    email: EmailStr
    name: str
    is_active: bool
    consent_status: bool
    cloud_ai_preference: bool
    local_ai_preference: bool
    data_retention_preference: str

# --- Fitness Profile Schemas ---
class FitnessProfileCreateOrUpdate(BaseModel):
    age: Optional[int] = None
    gender: Optional[str] = None
    height: Optional[float] = None
    weight: Optional[float] = None
    fitness_level: Optional[str] = "beginner"
    fitness_goal: Optional[str] = "general_fitness"
    available_workout_time: Optional[int] = 30
    equipment_availability: Optional[str] = "bodyweight_only"
    dietary_preference: Optional[str] = "vegetarian"
    food_preference: Optional[str] = "indian"
    sleep_quality: Optional[str] = "good"
    typical_stress_level: Optional[str] = "moderate"
    daily_activity_level: Optional[str] = "sedentary"

class FitnessProfileResponse(FitnessProfileCreateOrUpdate):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int

# --- Readiness & Progress Schemas ---
class ReadinessSummary(BaseModel):
    readiness_score: int # 0 - 100
    status: str # "optimal", "moderate", "recovery"
    recovery_recommendation: str
    sleep_factor: str
    stress_factor: str

# --- Workout Schemas ---
class WorkoutSessionStart(BaseModel):
    workout_id: Optional[int] = None
    workout_title: str = "Adaptive Daily Session"

class WorkoutSessionComplete(BaseModel):
    duration_seconds: int
    total_reps: int
    average_form_score: float
    calories_burned: float
    exercise_summary: List[Dict[str, Any]] = []

class WorkoutSessionResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    duration_seconds: int
    total_reps: int
    average_form_score: float
    calories_burned: float
    started_at: datetime.datetime
    ended_at: Optional[datetime.datetime] = None

# --- Exercise Schemas ---
class ExerciseResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    category: str
    target_muscle: Optional[str]
    instructions: Optional[str]
    difficulty: str
    calories_per_minute: float

# --- Nutrition Schemas ---
class NutritionAnalyzeRequest(BaseModel):
    food_name: str
    portion_hint: Optional[str] = "1 plate"
    is_indian_food: bool = True

class NutritionEstimate(BaseModel):
    name: str
    is_indian_food: bool
    estimated_calories: float
    protein_grams: float
    carbs_grams: float
    fat_grams: float
    portion_estimate: str
    confidence_indicator: float
    disclaimer: str = "Estimates are for general wellness only and not medical advice."

class MealCreate(BaseModel):
    name: str
    meal_type: str = "lunch"
    is_indian_food: bool = True
    calories: float
    protein_grams: float
    carbs_grams: float
    fat_grams: float
    portion_description: str = "1 serving"
    confidence_score: float = 0.90

class MealResponse(MealCreate):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    logged_at: datetime.datetime

# --- AI Schemas ---
class AIRequest(BaseModel):
    prompt: str
    user_context: Optional[Dict[str, Any]] = None
    conversation_id: Optional[str] = None

class AIAction(BaseModel):
    action: str
    payload: Dict[str, Any] = {}

class AIResponse(BaseModel):
    message: str
    source: str = "cloud" # "edge" or "cloud"
    conversation_id: Optional[str] = None
    actions: List[AIAction] = []
    recommendations: List[str] = []
    voice_text: Optional[str] = None
    requires_confirmation: bool = False

# --- Voice & Preference Schemas ---
class VoicePreferenceUpdate(BaseModel):
    voice_name: Optional[str] = "natural_calm"
    speech_speed: Optional[float] = 1.0
    pitch: Optional[float] = 1.0
    volume: Optional[float] = 1.0
    tone: Optional[str] = "calm"
    coaching_intensity: Optional[str] = "supportive"
    preferred_language: Optional[str] = "en"

