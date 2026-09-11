# SMARAN AI Backend

AI-powered adaptive difficulty and clinical cognitive analysis backend for the SMARAN cognitive gaming platform.

## What it does

The backend receives cognitive game session metrics from the SMARAN Flutter application and uses a trained machine learning pipeline to recommend the next difficulty level and evaluate Cognitive Performance Scores (CPS).

Supported games:
- Memory Matching
- Pattern Recognition

Supported difficulty levels:
- Easy
- Medium
- Hard

## Local Execution & Server Launch

To launch the FastAPI backend locally:

```bash
cd AI-Backend
python -m uvicorn main:app --reload
```

Exposed Endpoints:
- `GET /` — Service status & API index.
- `GET /health` — Service health check.
- `POST /predict-difficulty` — Adaptive difficulty recommendation.
- `POST /analyze-session` — Full CPS scoring & acute drop anomaly detection.

## Client Configuration (`SMARAN_API_BASE_URL`)

The Flutter application connects to the backend using a configurable base URL:

1. **Local Desktop / Emulator Testing**:
   `http://127.0.0.1:8000` (Default fallback)

2. **Physical Android Testing**:
   `http://<YOUR_LOCAL_IP>:8000` (e.g. `flutter run --dart-define=SMARAN_API_BASE_URL=http://192.168.1.50:8000`)

3. **Production Deployment**:
   Configured via `--dart-define=SMARAN_API_BASE_URL=https://your-api-domain.com`

## Request Schema (`POST /predict-difficulty`)

Payload expected:
```json
{
  "game_type": "memory_matching",
  "current_difficulty": "medium",
  "accuracy": 0.85,
  "completion_rate": 1.0,
  "response_time_ms": 45000,
  "errors": 2,
  "hints_used": 1
}
```

Note: Does NOT require `patient_id` or `attempts`.

## Response Schema

```json
{
  "recommended_level": "Hard",
  "patient_message": "Wonderful! You're getting better at this activity. Would you like to try a little more?",
  "caregiver_summary": "Performance supports increasing the challenge level."
}
```
