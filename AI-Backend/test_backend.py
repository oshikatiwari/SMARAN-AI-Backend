"""
Backend Unit Test Suite for SMARAN AI FastAPI Service & Joblib Pipeline.
"""

import sys
import os
import unittest
from pathlib import Path

# Add backend directory to sys.path
backend_dir = Path(__file__).resolve().parent
sys.path.insert(0, str(backend_dir))

from fastapi.testclient import TestClient
from main import app, model

client = TestClient(app)

class TestSmaranAiBackend(unittest.TestCase):
    def test_model_loaded(self):
        self.assertIsNotNone(model, "Model joblib pipeline failed to load.")

    def test_root_endpoint(self):
        response = client.get("/")
        self.assertEqual(response.status_code, 200)
        json_data = response.json()
        self.assertEqual(json_data["status"], "online")
        self.assertEqual(json_data["service"], "SMARAN AI Backend API")

    def test_health_endpoint(self):
        response = client.get("/health")
        self.assertEqual(response.status_code, 200)
        json_data = response.json()
        self.assertEqual(json_data["status"], "healthy")

    def test_predict_difficulty_valid_request(self):
        payload = {
            "game_type": "memory_matching",
            "current_difficulty": "medium",
            "accuracy": 0.95,
            "completion_rate": 1.0,
            "response_time_ms": 25000,
            "errors": 0,
            "hints_used": 0
        }
        response = client.post("/predict-difficulty", json=payload)
        self.assertEqual(response.status_code, 200)
        json_data = response.json()
        self.assertIn(json_data["recommended_level"], ["Easy", "Medium", "Hard"])
        self.assertTrue(len(json_data["patient_message"]) > 0)
        self.assertTrue(len(json_data["caregiver_summary"]) > 0)

    def test_predict_difficulty_pattern_recognition(self):
        payload = {
            "game_type": "pattern_recognition",
            "current_difficulty": "easy",
            "accuracy": 0.90,
            "completion_rate": 1.0,
            "response_time_ms": 20000,
            "errors": 0,
            "hints_used": 0
        }
        response = client.post("/predict-difficulty", json=payload)
        self.assertEqual(response.status_code, 200)
        json_data = response.json()
        self.assertIn(json_data["recommended_level"], ["Easy", "Medium", "Hard"])

    def test_predict_difficulty_invalid_missing_fields(self):
        payload = {
            "game_type": "memory_matching",
            "accuracy": 0.95
            # Missing required fields
        }
        response = client.post("/predict-difficulty", json=payload)
        self.assertEqual(response.status_code, 422) # Unprocessable Entity validation error

    def test_analyze_session_endpoint(self):
        payload = {
            "game_type": "pattern_recognition",
            "current_difficulty": "easy",
            "accuracy": 0.80,
            "completion_rate": 1.0,
            "response_time_ms": 30000,
            "errors": 1,
            "hints_used": 0
        }
        response = client.post("/analyze-session", json=payload)
        self.assertEqual(response.status_code, 200)
        json_data = response.json()
        self.assertIn("cps_score", json_data)
        self.assertIn("cognitive_sub_scores", json_data)
        self.assertIn("anomaly_alert", json_data)

if __name__ == "__main__":
    unittest.main()
