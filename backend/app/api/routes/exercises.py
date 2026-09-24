from fastapi import APIRouter, HTTPException
from typing import List, Dict, Any

router = APIRouter()

EXERCISES_DATABASE: List[Dict[str, Any]] = [
    {
        "id": 1,
        "name": "Bodyweight Squat",
        "category": "Lower Body",
        "target_muscle": "Quadriceps, Glutes, Hamstrings",
        "difficulty": "Beginner",
        "calories_per_minute": 7.5,
        "instructions": "Stand with feet shoulder-width apart. Lower your hips until thighs are parallel to the floor, keeping back neutral. Drive through heels to stand.",
        "joint_landmarks": ["left_hip", "left_knee", "left_ankle"],
        "target_angle_bottom": 90.0
    },
    {
        "id": 2,
        "name": "Push-up",
        "category": "Upper Body",
        "target_muscle": "Pectorals, Anterior Deltoids, Triceps",
        "difficulty": "Beginner",
        "calories_per_minute": 8.0,
        "instructions": "Place hands slightly wider than shoulder-width. Lower chest until elbows reach 90 degrees while maintaining rigid core. Push up powerfully.",
        "joint_landmarks": ["left_shoulder", "left_elbow", "left_wrist"],
        "target_angle_bottom": 90.0
    },
    {
        "id": 3,
        "name": "Forward Lunge",
        "category": "Lower Body",
        "target_muscle": "Quadriceps, Glutes, Calves",
        "difficulty": "Intermediate",
        "calories_per_minute": 8.5,
        "instructions": "Step forward with one leg until both knees are bent at 90 degrees. Return to standing position by pushing off the front heel.",
        "joint_landmarks": ["hip", "knee", "ankle"],
        "target_angle_bottom": 90.0
    },
    {
        "id": 4,
        "name": "Forearm Plank",
        "category": "Core",
        "target_muscle": "Rectus Abdominis, Transverse Abdominis, Shoulders",
        "difficulty": "Beginner",
        "calories_per_minute": 5.0,
        "instructions": "Rest on forearms and toes. Keep straight line from shoulders to ankles without allowing hips to drop.",
        "joint_landmarks": ["shoulder", "hip", "ankle"],
        "target_angle_bottom": 180.0
    },
    {
        "id": 5,
        "name": "Jumping Jacks",
        "category": "Cardio",
        "target_muscle": "Full Body Cardio",
        "difficulty": "Beginner",
        "calories_per_minute": 10.0,
        "instructions": "Jump while spreading legs and clapping hands overhead, then return to starting position.",
        "joint_landmarks": ["wrists", "ankles"],
        "target_angle_bottom": 0.0
    },
]

@router.get("/")
async def list_exercises():
    return EXERCISES_DATABASE

@router.get("/{exercise_id}")
async def get_exercise(exercise_id: int):
    for ex in EXERCISES_DATABASE:
        if ex["id"] == exercise_id:
            return ex
    raise HTTPException(status_code=404, detail="Exercise not found")

