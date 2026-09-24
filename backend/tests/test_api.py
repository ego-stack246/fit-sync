import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.db.session import init_db

@pytest_asyncio.fixture(autouse=True)
async def prepare_database():
    await init_db()

@pytest.mark.asyncio
async def test_health_and_root():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        res = await client.get("/health")
        assert res.status_code == 200
        assert res.json() == {"status": "healthy"}

        root = await client.get("/")
        assert root.status_code == 200
        assert "FitSync AI" in root.json()["app"]

@pytest.mark.asyncio
async def test_full_user_and_workout_flow():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Register new user
        reg_data = {
            "email": "demo_athlete@fitsync.ai",
            "password": "StrongPassword2026!",
            "name": "Shivam",
            "consent_status": True,
            "cloud_ai_preference": True,
            "data_retention_preference": "30_days"
        }
        await client.post("/api/auth/register", json=reg_data)

        # Login
        login_res = await client.post("/api/auth/login", json={
            "email": "demo_athlete@fitsync.ai",
            "password": "StrongPassword2026!"
        })
        assert login_res.status_code == 200
        token = login_res.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # 1. Check Profile & Readiness
        profile_res = await client.get("/api/fitness/profile", headers=headers)
        assert profile_res.status_code == 200

        readiness_res = await client.get("/api/fitness/readiness", headers=headers)
        assert readiness_res.status_code == 200
        assert "readiness_score" in readiness_res.json()

        # 2. Get Today's Adaptive Workout
        workout_today = await client.get("/api/workouts/today", headers=headers)
        assert workout_today.status_code == 200
        assert "exercises" in workout_today.json()

        # 3. Start Workout Session
        start_res = await client.post("/api/workouts/start", json={"workout_title": "Leg Day"}, headers=headers)
        assert start_res.status_code == 200
        session_id = start_res.json()["session_id"]

        # 4. Complete Workout Session (Simulated 15 squats at 94% form)
        complete_res = await client.post(
            f"/api/workouts/complete?session_id={session_id}",
            json={
                "duration_seconds": 900,
                "total_reps": 15,
                "average_form_score": 94.0,
                "calories_burned": 110.5,
                "exercise_summary": [{"name": "Bodyweight Squat", "reps": 15, "form_score": 94.0}]
            },
            headers=headers
        )
        assert complete_res.status_code == 200
        assert complete_res.json()["total_reps"] == 15

        # 5. Check Progress Dashboard
        progress_res = await client.get("/api/fitness/progress", headers=headers)
        assert progress_res.status_code == 200
        assert progress_res.json()["total_workouts"] >= 1

        # 6. Log Indian Meal (Moong Dal Khichdi)
        meal_res = await client.post(
            "/api/nutrition/meals",
            json={
                "name": "Moong Dal Khichdi",
                "meal_type": "dinner",
                "is_indian_food": True,
                "calories": 210.0,
                "protein_grams": 8.0,
                "carbs_grams": 36.0,
                "fat_grams": 3.5,
                "portion_description": "1 bowl (200g)",
                "confidence_score": 0.95
            },
            headers=headers
        )
        assert meal_res.status_code == 201

        # 7. Check Daily Nutrition
        daily_res = await client.get("/api/nutrition/daily", headers=headers)
        assert daily_res.status_code == 200
        assert daily_res.json()["total_calories"] >= 210.0

        # 8. Test Voice Modulation
        voice_res = await client.post(
            "/api/voice/synthesize",
            json={
                "text": "Great squat form! 3 more reps to go.",
                "tone": "energetic",
                "speed": 1.1
            }
        )
        assert voice_res.status_code == 200
        assert "[Energetic]" in voice_res.json()["synthesized_text"]

@pytest.mark.asyncio
async def test_ai_coach_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        payload = {
            "prompt": "Start today's workout.",
            "user_context": {"fitness_goal": "muscle_gain", "readiness_score": 90}
        }
        res = await client.post("/api/ai/chat", json=payload)
        assert res.status_code == 200
        data = res.json()
        assert "message" in data
        assert "actions" in data
        assert any(a["action"] == "START_WORKOUT" for a in data["actions"])
        assert data["source"] in ["edge", "cloud"]

@pytest.mark.asyncio
async def test_nutrition_indian_food():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        res = await client.post("/api/nutrition/analyze", json={
            "food_name": "Paneer Tikka",
            "is_indian_food": True
        })
        assert res.status_code == 200
        data = res.json()
        assert data["is_indian_food"] is True
        assert data["protein_grams"] >= 10.0
        assert "disclaimer" in data

@pytest.mark.asyncio
async def test_exercise_library():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        res = await client.get("/api/exercises/")
        assert res.status_code == 200
        exercises = res.json()
        assert len(exercises) >= 3
        assert any(e["name"] == "Bodyweight Squat" for e in exercises)
