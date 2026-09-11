import os
import sys
import joblib
import json
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split, KFold, cross_val_score
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier, GradientBoostingClassifier, VotingRegressor
from xgboost import XGBRegressor, XGBClassifier
from sklearn.metrics import mean_squared_error, r2_score, classification_report, accuracy_score

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

def train_and_export_models():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    dataset_path = os.path.join(base_dir, "dataset", "kaggle_dementia_cognitive_game_telemetry.csv")
    models_dir = os.path.join(base_dir, "models")
    os.makedirs(models_dir, exist_ok=True)

    print(f"[*] Loading dataset from {dataset_path}...", flush=True)
    df = pd.read_csv(dataset_path)

    # Derived Engineering Features
    df["accuracy_speed_ratio"] = df["accuracy"] / (df["response_time_ms"] / 1000.0)
    df["error_rate"] = df["errors"] / (df["attempts"] + 1e-5)
    df["cognitive_efficiency_idx"] = df["completion_rate"] * df["accuracy"]

    # Categorical Encodings
    game_type_le = LabelEncoder()
    df["game_type_encoded"] = game_type_le.fit_transform(df["game_type"])

    lang_le = LabelEncoder()
    df["language_encoded"] = lang_le.fit_transform(df["preferred_language"])

    difficulty_map = {"easy": 0, "medium": 1, "hard": 2}
    df["difficulty_target"] = df["next_adaptive_difficulty"].map(difficulty_map)

    # 22 High-Dimensional Feature Vector (including Motor Jitter & Speech Acoustic Features)
    feature_cols = [
        "age",
        "education_level",
        "language_encoded",
        "mmse_score",
        "gds_score",
        "game_type_encoded",
        "time_of_day_hour",
        "accuracy",
        "response_time_ms",
        "attempts",
        "errors",
        "repeat_mismatches",
        "spatial_proximity_error_score",
        "span_memory_capacity",
        "flip_latency_variance_ms",
        "motor_jitter_index",
        "speech_hesitation_score",
        "hints_used",
        "completion_rate",
        "accuracy_speed_ratio",
        "error_rate",
        "cognitive_efficiency_idx"
    ]

    X = df[feature_cols]
    y_cps = df["cps_score"]
    y_diff = df["difficulty_target"]
    y_impairment = df["cognitive_impairment_status"]

    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    # Train / Validation Splits
    X_train, X_test, y_cps_train, y_cps_test, y_diff_train, y_diff_test, y_imp_train, y_imp_test = train_test_split(
        X_scaled, y_cps, y_diff, y_impairment, test_size=0.2, random_state=42
    )

    print("\n--- 1. Training High-Precision Ensemble CPS Regressor (XGBoost + Random Forest) ---", flush=True)
    xgb_reg = XGBRegressor(n_estimators=100, learning_rate=0.05, max_depth=6, random_state=42, n_jobs=-1)
    rf_reg = RandomForestRegressor(n_estimators=100, max_depth=10, random_state=42, n_jobs=-1)
    
    ensemble_cps = VotingRegressor(estimators=[('xgb', xgb_reg), ('rf', rf_reg)])
    ensemble_cps.fit(X_train, y_cps_train)

    y_cps_pred = ensemble_cps.predict(X_test)
    r2 = r2_score(y_cps_test, y_cps_pred)
    mse = mean_squared_error(y_cps_test, y_cps_pred)
    print(f"[+] Ensemble CPS Model R2 Score: {r2:.4f}", flush=True)
    print(f"[+] Ensemble CPS Model MSE: {mse:.4f}", flush=True)

    print("\n--- 2. Training Hidden Adaptive Difficulty Classifier ---", flush=True)
    diff_model = RandomForestClassifier(n_estimators=100, max_depth=8, random_state=42, n_jobs=-1)
    diff_model.fit(X_train, y_diff_train)

    y_diff_pred = diff_model.predict(X_test)
    acc = accuracy_score(y_diff_test, y_diff_pred)
    print(f"[+] Hidden Adaptive Difficulty Model Accuracy: {acc * 100:.2f}%", flush=True)
    print(classification_report(y_diff_test, y_diff_pred, target_names=["Easy", "Medium", "Hard"]), flush=True)

    print("\n--- 3. Training Clinical Cognitive Impairment Classifier ---", flush=True)
    imp_model = GradientBoostingClassifier(n_estimators=100, learning_rate=0.05, max_depth=5, random_state=42)
    imp_model.fit(X_train, y_imp_train)
    y_imp_pred = imp_model.predict(X_test)
    imp_acc = accuracy_score(y_imp_test, y_imp_pred)
    print(f"[+] Impairment Classifier Accuracy: {imp_acc * 100:.2f}%", flush=True)

    # Save Models & Artifacts
    joblib.dump(ensemble_cps, os.path.join(models_dir, "cps_regressor.pkl"))
    joblib.dump(diff_model, os.path.join(models_dir, "difficulty_classifier.pkl"))
    joblib.dump(imp_model, os.path.join(models_dir, "impairment_classifier.pkl"))
    joblib.dump(scaler, os.path.join(models_dir, "scaler.pkl"))
    joblib.dump(game_type_le, os.path.join(models_dir, "game_type_encoder.pkl"))
    joblib.dump(lang_le, os.path.join(models_dir, "language_encoder.pkl"))

    meta_info = {
        "model_version": "4.0.0-Ensemble-Edge",
        "sih_problem_statement": "SIH26003",
        "supported_languages": ["Hindi", "English", "Mizo", "Khasi", "Assamese"],
        "feature_cols": feature_cols,
        "difficulty_mapping": {"0": "easy", "1": "medium", "2": "hard"},
        "cps_r2_score": round(float(r2), 4),
        "difficulty_accuracy": round(float(acc), 4),
        "impairment_accuracy": round(float(imp_acc), 4),
        "scaler_means": scaler.mean_.tolist(),
        "scaler_scales": scaler.scale_.tolist()
    }

    with open(os.path.join(models_dir, "model_metadata.json"), "w") as f:
        json.dump(meta_info, f, indent=4)

    print(f"\n[+] All Ensemble ML models successfully trained & saved to {models_dir}", flush=True)

if __name__ == "__main__":
    train_and_export_models()
