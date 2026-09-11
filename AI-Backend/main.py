from fastapi import FastAPI
from pydantic import BaseModel, Field
from typing import Literal, Optional
from pathlib import Path
import pandas as pd
import joblib


# --------------------------------------------------
# SMARAN AI Backend
# --------------------------------------------------

app = FastAPI(
    title="SMARAN AI Backend",
    description="AI-powered adaptive difficulty & clinical cognitive monitoring API for SMARAN cognitive games",
    version="4.0.0"
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
    preferred_language: Optional[str] = "English"


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
        "service": "SMARAN AI Backend",
        "version": "4.0.0"
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


# --------------------------------------------------
# Extended Clinical Analysis Endpoint
# --------------------------------------------------

@app.post("/analyze-session")
def analyze_session(session: GameSession):
    # Predict difficulty
    diff_res = predict_difficulty(session)

    # Compute CPS Score (0-100)
    time_sec = session.response_time_ms / 1000.0
    cps_score = min(100.0, max(30.0, round(session.accuracy * 70.0 + (60.0 - min(60.0, time_sec)) * 0.5 - session.errors * 1.5, 2)))

    # Compute Sub-Scores
    memory_idx = round(min(100.0, session.accuracy * 100.0), 1)
    speed_idx = round(min(100.0, max(20.0, (1.0 - min(1.0, time_sec / 90.0)) * 100.0)), 1)
    executive_idx = round(min(100.0, max(10.0, session.completion_rate * 100.0 - session.errors * 5.0)), 1)

    # Anomaly checks
    is_anomaly = session.accuracy < 0.4 or session.errors > 6
    alert_msg = "Acute performance drop detected: high error count or low accuracy." if is_anomaly else "Normal session bounds."

    return {
        "recommended_level": diff_res["recommended_level"],
        "patient_message": diff_res["patient_message"],
        "caregiver_summary": diff_res["caregiver_summary"],
        "cps_score": cps_score,
        "cognitive_sub_scores": {
            "memory_retention_index": memory_idx,
            "reaction_latency_score": speed_idx,
            "executive_function_index": executive_idx
        },
        "anomaly_alert": {
            "detected": is_anomaly,
            "alert_message": alert_msg,
            "risk_level": "Elevated" if is_anomaly else "Low"
        }
    }


if __name__ == "__main__":
    import os
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port)