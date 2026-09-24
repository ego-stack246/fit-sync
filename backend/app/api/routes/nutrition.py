from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import List, Dict, Any
import datetime
from datetime import timezone

from app.db.session import get_db
from app.models.models import Meal
from app.core.security import get_current_user
from app.schemas.schemas import (
    NutritionAnalyzeRequest,
    NutritionEstimate,
    MealCreate,
    MealResponse,
)

router = APIRouter()

INDIAN_FOOD_KNOWLEDGE_BASE: Dict[str, Dict[str, Any]] = {
    "roti": {"calories": 104, "protein": 3.1, "carbs": 22.0, "fat": 0.5, "portion": "1 medium roti (35g)"},
    "chapati": {"calories": 104, "protein": 3.1, "carbs": 22.0, "fat": 0.5, "portion": "1 medium (35g)"},
    "dal tadka": {"calories": 165, "protein": 8.5, "carbs": 24.0, "fat": 4.5, "portion": "1 medium katori (150g)"},
    "dal makhani": {"calories": 280, "protein": 9.0, "carbs": 28.0, "fat": 14.5, "portion": "1 katori (150g)"},
    "paneer tikka": {"calories": 240, "protein": 16.0, "carbs": 8.0, "fat": 16.0, "portion": "6 pieces (150g)"},
    "palak paneer": {"calories": 230, "protein": 11.0, "carbs": 9.0, "fat": 17.0, "portion": "1 bowl (180g)"},
    "masala dosa": {"calories": 310, "protein": 6.5, "carbs": 52.0, "fat": 9.0, "portion": "1 medium with sambar"},
    "idli": {"calories": 58, "protein": 2.0, "carbs": 12.0, "fat": 0.3, "portion": "1 piece (40g)"},
    "sambar": {"calories": 85, "protein": 3.5, "carbs": 14.0, "fat": 1.5, "portion": "1 bowl (150ml)"},
    "chicken biryani": {"calories": 420, "protein": 24.0, "carbs": 48.0, "fat": 14.0, "portion": "1 plate (250g)"},
    "vegetable biryani": {"calories": 320, "protein": 7.0, "carbs": 54.0, "fat": 9.0, "portion": "1 plate (250g)"},
    "chole": {"calories": 250, "protein": 10.5, "carbs": 38.0, "fat": 6.5, "portion": "1 katori (150g)"},
    "rajma": {"calories": 240, "protein": 11.0, "carbs": 36.0, "fat": 5.0, "portion": "1 katori (150g)"},
    "moong dal khichdi": {"calories": 210, "protein": 8.0, "carbs": 36.0, "fat": 3.5, "portion": "1 bowl (200g)"},
    "curd": {"calories": 98, "protein": 4.5, "carbs": 6.0, "fat": 6.0, "portion": "1 small katori (100g)"},
    "poha": {"calories": 180, "protein": 3.5, "carbs": 34.0, "fat": 3.0, "portion": "1 medium plate (150g)"},
    "upma": {"calories": 190, "protein": 4.0, "carbs": 32.0, "fat": 5.0, "portion": "1 medium bowl (150g)"},
    "egg bhurji": {"calories": 175, "protein": 12.0, "carbs": 3.0, "fat": 12.5, "portion": "2 eggs with onions/spices"},
}

@router.post("/analyze", response_model=NutritionEstimate)
async def analyze_food_item(request: NutritionAnalyzeRequest):
    """Analyzes food items with rich Indian nutrition database & estimates."""
    query = request.food_name.strip().lower()

    matched = None
    for name, data in INDIAN_FOOD_KNOWLEDGE_BASE.items():
        if name in query or query in name:
            matched = (name, data)
            break

    if matched:
        name, data = matched
        return NutritionEstimate(
            name=name.title(),
            is_indian_food=True,
            estimated_calories=float(data["calories"]),
            protein_grams=float(data["protein"]),
            carbs_grams=float(data["carbs"]),
            fat_grams=float(data["fat"]),
            portion_estimate=data["portion"],
            confidence_indicator=0.92,
        )

    # General default estimate
    return NutritionEstimate(
        name=request.food_name.title(),
        is_indian_food=request.is_indian_food,
        estimated_calories=220.0,
        protein_grams=8.0,
        carbs_grams=30.0,
        fat_grams=7.0,
        portion_estimate=request.portion_hint or "1 standard serving",
        confidence_indicator=0.75,
    )

@router.post("/meals", response_model=MealResponse, status_code=status.HTTP_201_CREATED)
async def log_meal(
    meal_in: MealCreate,
    current_token: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_id = int(current_token["sub"])
    meal = Meal(
        user_id=user_id,
        name=meal_in.name,
        meal_type=meal_in.meal_type,
        is_indian_food=meal_in.is_indian_food,
        calories=meal_in.calories,
        protein_grams=meal_in.protein_grams,
        carbs_grams=meal_in.carbs_grams,
        fat_grams=meal_in.fat_grams,
        portion_description=meal_in.portion_description,
        confidence_score=meal_in.confidence_score,
        logged_at=datetime.datetime.now(timezone.utc),
    )
    db.add(meal)
    await db.commit()
    await db.refresh(meal)
    return meal

@router.get("/daily")
async def get_daily_nutrition_summary(
    current_token: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_id = int(current_token["sub"])
    today = datetime.datetime.now(timezone.utc).date()
    start_of_day = datetime.datetime.combine(today, datetime.time.min, tzinfo=timezone.utc)

    result = await db.execute(
        select(Meal).where(Meal.user_id == user_id, Meal.logged_at >= start_of_day)
    )
    meals = result.scalars().all()

    total_calories = sum(m.calories for m in meals)
    total_protein = sum(m.protein_grams for m in meals)
    total_carbs = sum(m.carbs_grams for m in meals)
    total_fat = sum(m.fat_grams for m in meals)

    return {
        "date": today.isoformat(),
        "total_calories": round(total_calories, 1),
        "total_protein_grams": round(total_protein, 1),
        "total_carbs_grams": round(total_carbs, 1),
        "total_fat_grams": round(total_fat, 1),
        "meals_count": len(meals),
        "meals": [
            {
                "id": m.id,
                "name": m.name,
                "type": m.meal_type,
                "calories": m.calories,
                "protein": m.protein_grams,
                "carbs": m.carbs_grams,
                "fat": m.fat_grams,
                "portion": m.portion_description,
            }
            for m in meals
        ]
    }

@router.get("/history")
async def get_nutrition_history(
    current_token: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    user_id = int(current_token["sub"])
    result = await db.execute(
        select(Meal).where(Meal.user_id == user_id).order_by(Meal.logged_at.desc()).limit(50)
    )
    return result.scalars().all()
