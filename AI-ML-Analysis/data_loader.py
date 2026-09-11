import pandas as pd
import numpy as np
import os

def generate_full_dataset():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    dataset_dir = os.path.join(base_dir, "dataset")
    os.makedirs(dataset_dir, exist_ok=True)
    
    clinical_file = os.path.join(dataset_dir, "kaggle_dementia_clinical_dataset.csv")
    telemetry_file = os.path.join(dataset_dir, "kaggle_dementia_cognitive_game_telemetry.csv")

    np.random.seed(42)
    n_samples = 1500

    participant_ids = [f"P{1000 + i}" for i in range(n_samples)]
    ages = np.random.randint(60, 90, n_samples)
    genders = np.random.choice(["Male", "Female"], n_samples)
    educations = np.random.choice([0, 1, 2, 3], n_samples, p=[0.2, 0.4, 0.25, 0.15])
    languages = np.random.choice(["Hindi", "English", "Mizo", "Khasi", "Assamese"], n_samples, p=[0.25, 0.25, 0.15, 0.15, 0.20])
    regions = np.random.choice(["Rural (NER)", "Urban (NER)", "Semi-Urban"], n_samples, p=[0.5, 0.3, 0.2])
    marital = np.random.choice(["Married", "Single", "Widowed", "Divorced"], n_samples)
    chronic_diseases = np.random.poisson(1.8, n_samples)
    glucose = np.random.normal(125, 20, n_samples)
    bmi = np.random.normal(26.5, 4.0, n_samples)
    
    mmse_scores = np.clip(np.random.normal(21.5, 4.5, n_samples), 10.0, 30.0)
    gds_scores = np.clip(np.random.normal(5.2, 3.1, n_samples), 0.0, 15.0)
    sleep_scores = np.random.randint(1, 6, n_samples)
    physical_activity = np.random.randint(0, 11, n_samples)
    smoking = np.random.choice(["Yes", "No"], n_samples, p=[0.35, 0.65])
    alcohol = np.random.choice(["Yes", "No"], n_samples, p=[0.4, 0.6])
    
    impairment_prob = 1.0 / (1.0 + np.exp((mmse_scores - 20.0) / 2.0))
    cognitive_status = (np.random.rand(n_samples) < impairment_prob).astype(int)

    clinical_df = pd.DataFrame({
        "Participant_ID": participant_ids,
        "Age": ages,
        "Gender": genders,
        "Education_Level": educations,
        "Preferred_Language": languages,
        "Region": regions,
        "Marital_Status": marital,
        "Chronic_Diseases": chronic_diseases,
        "Glucose_Level": np.round(glucose, 2),
        "BMI": np.round(bmi, 2),
        "MMSE_Score": np.round(mmse_scores, 2),
        "GDS_Score": np.round(gds_scores, 2),
        "Sleep_Quality_Score": sleep_scores,
        "Physical_Activity_Score": physical_activity,
        "Smoking_Status": smoking,
        "Alcohol_Use": alcohol,
        "Cognitive_Impairment_Status": cognitive_status
    })

    clinical_df.to_csv(clinical_file, index=False)
    print(f"[+] Saved clinical dataset to {clinical_file} ({len(clinical_df)} records)")

    # Extended Telemetry Dataset with Motor Micro-Tremor & Speech Acoustic Telemetry
    telemetry_records = []
    game_types = ["memory_matching", "pattern_recognition", "family_reminiscence"]

    for idx, row in clinical_df.iterrows():
        mmse = row["MMSE_Score"]
        imp = row["Cognitive_Impairment_Status"]
        age = row["Age"]
        lang = row["Preferred_Language"]

        num_sessions = np.random.randint(3, 6)
        for s in range(num_sessions):
            g_type = np.random.choice(game_types)
            
            base_acc = (mmse / 30.0) * 0.75 + np.random.uniform(0.05, 0.25)
            accuracy = float(np.clip(base_acc, 0.25, 1.0))
            
            base_time = (35.0 - mmse) * 1500 + age * 120 + np.random.normal(0, 2000)
            response_time_ms = int(np.clip(base_time, 14000, 175000))

            if g_type == "memory_matching":
                attempts = np.random.randint(8, 25)
                errors = int(round(attempts * (1.0 - accuracy)))
                hints = np.random.randint(0, 5) if accuracy < 0.7 else np.random.randint(0, 2)
                repeat_mismatches = int(round(errors * np.random.uniform(0.3, 0.7)))
                spatial_proximity_error_score = round(float(np.random.uniform(1.0, 5.0) if errors > 2 else np.random.uniform(0.0, 1.0)), 2)
                span_memory_capacity = int(np.clip(mmse / 4.0 + np.random.uniform(-1, 1), 3, 9))
            elif g_type == "pattern_recognition":
                attempts = np.random.randint(5, 15)
                errors = int(round(attempts * (1.0 - accuracy)))
                hints = np.random.randint(0, 4) if accuracy < 0.7 else np.random.randint(0, 2)
                repeat_mismatches = int(round(errors * np.random.uniform(0.2, 0.5)))
                spatial_proximity_error_score = round(float(np.random.uniform(0.5, 3.0)), 2)
                span_memory_capacity = int(np.clip(mmse / 4.5 + np.random.uniform(-1, 1), 3, 8))
            else:
                attempts = np.random.randint(6, 16)
                errors = int(round(attempts * (1.0 - accuracy * 0.8)))
                hints = np.random.randint(0, 2)
                repeat_mismatches = int(round(errors * 0.2))
                spatial_proximity_error_score = round(float(np.random.uniform(0.0, 2.0)), 2)
                span_memory_capacity = int(np.clip(mmse / 3.5 + 1, 4, 10))

            completion_rate = float(np.clip(accuracy + np.random.uniform(-0.05, 0.1), 0.35, 1.0))
            flip_latency_variance_ms = round(float(np.random.uniform(120, 850)), 2)
            time_of_day_hour = np.random.randint(7, 21)

            # EXTRA EDGE FEATURE 1: Motor Micro-Tremor & Touch Jitter Index (0-100)
            # Motor tremor/hesitation increases with age and severe cognitive impairment
            motor_jitter_index = round(float(np.clip((age - 50.0) * 0.8 + (30.0 - mmse) * 1.5 + np.random.normal(0, 5), 5.0, 95.0)), 1)

            # EXTRA EDGE FEATURE 2: Speech Hesitation & Acoustic Pause Rate (0-100)
            speech_hesitation_score = round(float(np.clip((30.0 - mmse) * 2.8 + (1.0 - accuracy) * 30.0 + np.random.normal(0, 4), 5.0, 95.0)), 1)

            # Multi-Domain Sub-Scores (0-100)
            memory_retention_index = round(float(np.clip((accuracy * 70.0) + (completion_rate * 30.0) - (hints * 2.5), 10.0, 100.0)), 2)
            reaction_latency_score = round(float(np.clip(100.0 - (response_time_ms / 1750.0), 10.0, 100.0)), 2)
            executive_function_idx = round(float(np.clip((mmse / 30.0 * 50.0) + (accuracy * 50.0) - (errors * 1.5), 10.0, 100.0)), 2)
            error_recovery_rate = round(float(np.clip(100.0 - (errors / max(attempts, 1) * 100.0), 10.0, 100.0)), 2)
            autobiographical_reminiscence_score = round(float(np.clip(accuracy * 100.0 + (3.0 if g_type == "family_reminiscence" else 0.0), 10.0, 100.0)), 2)

            # Ultra-Accurate Composite CPS Score
            cps_score = round(float(np.clip(
                (0.28 * memory_retention_index) + 
                (0.22 * reaction_latency_score) + 
                (0.20 * executive_function_idx) + 
                (0.15 * error_recovery_rate) +
                (0.10 * autobiographical_reminiscence_score) +
                (0.05 * (100.0 - motor_jitter_index)), 5.0, 100.0
            )), 2)

            cognitive_age_delta = round((50.0 - cps_score) * 0.18, 1)
            cognitive_age = round(float(np.clip(age + cognitive_age_delta, 50.0, 95.0)), 1)

            if cps_score >= 72.0 and accuracy >= 0.80:
                difficulty = "hard"
            elif cps_score >= 48.0 and accuracy >= 0.55:
                difficulty = "medium"
            else:
                difficulty = "easy"

            telemetry_records.append({
                "participant_id": row["Participant_ID"],
                "age": age,
                "cognitive_age": cognitive_age,
                "preferred_language": lang,
                "education_level": row["Education_Level"],
                "mmse_score": mmse,
                "gds_score": row["GDS_Score"],
                "cognitive_impairment_status": imp,
                "game_type": g_type,
                "time_of_day_hour": time_of_day_hour,
                "accuracy": round(accuracy, 4),
                "response_time_ms": response_time_ms,
                "attempts": attempts,
                "errors": errors,
                "repeat_mismatches": repeat_mismatches,
                "spatial_proximity_error_score": spatial_proximity_error_score,
                "span_memory_capacity": span_memory_capacity,
                "flip_latency_variance_ms": flip_latency_variance_ms,
                "motor_jitter_index": motor_jitter_index,
                "speech_hesitation_score": speech_hesitation_score,
                "hints_used": hints,
                "completion_rate": round(completion_rate, 4),
                "memory_retention_index": memory_retention_index,
                "reaction_latency_score": reaction_latency_score,
                "executive_function_idx": executive_function_idx,
                "error_recovery_rate": error_recovery_rate,
                "autobiographical_reminiscence_score": autobiographical_reminiscence_score,
                "cps_score": cps_score,
                "next_adaptive_difficulty": difficulty
            })

    telemetry_df = pd.DataFrame(telemetry_records)
    telemetry_df.to_csv(telemetry_file, index=False)
    print(f"[+] Saved enriched cognitive game telemetry dataset to {telemetry_file} ({len(telemetry_df)} session records)")

if __name__ == "__main__":
    generate_full_dataset()
