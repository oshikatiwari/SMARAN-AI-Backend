from fastapi import FastAPI
from pydantic import BaseModel, Field
from typing import Literal
from pathlib import Path
import pandas as pd
import joblib


# --------------------------------------------------
# SMARAN AI Backend
# --------------------------------------------------

app = FastAPI(
    title="SMARAN AI Backend",
    description="AI-powered adaptive difficulty API for SMARAN cognitive games",
    version="1.0.0"
)


# --------------------------------------------------
# Load the trained ML pipeline
# --------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent

MODEL_PATH = BASE_DIR / "models" / "smaran_adaptive_pipeline.joblib"

model = joblib.load(MODEL_PATH)


# --------------------------------------------------
# Input data received from the game
# --------------------------------------------------

class GameSession(BaseModel):
    game_type: Literal["memory_matching", "pattern_recognition"]
    current_difficulty: Literal["easy", "medium", "hard"]
    accuracy: float = Field(ge=0.0, le=1.0)
    completion_rate: float = Field(ge=0.0, le=1.0)
    response_time_ms: int = Field(gt=0)
    errors: int = Field(ge=0)
    hints_used: int = Field(ge=0)


# --------------------------------------------------
# Difficulty order
# --------------------------------------------------

difficulty_order = {
    "Easy": 0,
    "Medium": 1,
    "Hard": 2
}


# --------------------------------------------------
# Patient and caregiver messages
# --------------------------------------------------

def get_difficulty_message(
    current_difficulty: str,
    recommended_level: str
):

    current_value = difficulty_order[current_difficulty]

    recommended_value = difficulty_order[recommended_level]

    if recommended_value > current_value:

        patient_message = (
            "Wonderful! You're getting better at this activity. "
            "Would you like to try a little more?"
        )

        caregiver_summary = (
            "Performance supports increasing the challenge level."
        )

    elif recommended_value < current_value:

        patient_message = (
            "Good effort today! We'll keep the next activity "
            "a little easier so you can continue comfortably."
        )

        caregiver_summary = (
            "Performance suggests reducing the challenge level."
        )

    else:

        patient_message = (
            "You're doing well! We'll keep the next activity "
            "at a comfortable level."
        )

        caregiver_summary = (
            "Performance suggests maintaining the current challenge level."
        )

    return patient_message, caregiver_summary


# --------------------------------------------------
# Health check
# --------------------------------------------------

@app.get("/health")
def health_check():

    return {
        "status": "healthy",
        "service": "SMARAN AI Backend"
    }


# --------------------------------------------------
# AI difficulty prediction
# --------------------------------------------------

@app.post("/predict-difficulty")
def predict_difficulty(session: GameSession):

    # Convert incoming game data into the format
    # expected by the trained ML pipeline
    input_data = pd.DataFrame([{
        "game_type": (
            "Memory Matching"
            if session.game_type == "memory_matching"
            else "Pattern Recognition"
        ),
        "current_difficulty": session.current_difficulty.capitalize(),
        "accuracy": session.accuracy,
        "completion_rate": session.completion_rate,
        "response_time_ms": session.response_time_ms,
        "errors": session.errors,
        "hints_used": session.hints_used
    }])

    # Ask the trained ML pipeline for a prediction
    predicted_level = model.predict(input_data)[0]

    # Generate user-friendly messages
    patient_message, caregiver_summary = get_difficulty_message(
        session.current_difficulty.capitalize(),
        predicted_level
    )

    return {
        "recommended_level": predicted_level,
        "patient_message": patient_message,
        "caregiver_summary": caregiver_summary
    }