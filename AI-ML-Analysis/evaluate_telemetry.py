import sys
import os
import json
import random

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

from cps_analyzer import CPSAnalyzer

def run_evaluation_suite():
    analyzer = CPSAnalyzer()

    print("=========================================================================")
    print(" SIH26003: Advanced AI & ML Multi-Feature Evaluation Test Suite (v4.0)")
    print(" Features: Ensemble ML, Biomotor Jitter, Speech Acoustics, 5 Languages")
    print("=========================================================================\n")

    scenarios = [
        {"name": "High Performing Patient (Hindi Preferred)", "lang": "Hindi", "accuracy": 0.95, "time": 25000, "attempts": 10, "errors": 0, "hints": 0, "comp": 1.0, "mmse": 27.5},
        {"name": "Moderate Cognitive Decline (Mizo Preferred)", "lang": "Mizo", "accuracy": 0.65, "time": 65000, "attempts": 15, "errors": 5, "hints": 2, "comp": 0.8, "mmse": 21.0},
        {"name": "High Fatigue & Motor Jitter (Khasi Preferred)", "lang": "Khasi", "accuracy": 0.35, "time": 95000, "attempts": 18, "errors": 11, "hints": 4, "comp": 0.5, "mmse": 16.0},
        {"name": "Careful Slow Reaction Patient (Assamese Preferred)", "lang": "Assamese", "accuracy": 0.90, "time": 55000, "attempts": 10, "errors": 1, "hints": 0, "comp": 1.0, "mmse": 24.0},
        {"name": "Random Telemetry Stream Scenario (English)", "lang": "English", "accuracy": round(random.uniform(0.3, 0.98), 2), "time": random.randint(20000, 110000), "attempts": random.randint(8, 20), "errors": random.randint(0, 7), "hints": random.randint(0, 3), "comp": round(random.uniform(0.5, 1.0), 2), "mmse": round(random.uniform(14.0, 29.0), 1)}
    ]

    for idx, sc in enumerate(scenarios, 1):
        telemetry = {
            "age": 74,
            "education_level": 2,
            "preferred_language": sc["lang"],
            "mmse_score": sc["mmse"],
            "gds_score": 4.0,
            "game_type": "memory_matching" if idx % 2 != 0 else "pattern_recognition",
            "accuracy": sc["accuracy"],
            "response_time_ms": sc["time"],
            "attempts": sc["attempts"],
            "errors": sc["errors"],
            "hints_used": sc["hints"],
            "completion_rate": sc["comp"],
            "time_of_day_hour": 10
        }

        res = analyzer.analyze_session(telemetry)
        sub = res["cognitive_sub_scores"]
        bio = res["biomotor_and_speech_diagnostics"]
        proj = res["trajectory_projections"]
        recs = res["caregiver_reminiscence_therapy"]
        
        print(f"Scenario {idx}: [{sc['name']}]")
        print(f"  * Input Telemetry : Lang={sc['lang']}, Accuracy={sc['accuracy']*100:.0f}%, Time={sc['time']/1000:.1f}s, Errors={sc['errors']}")
        print(f"  * Composite CPS Score : {res['cps_score']} / 100.0 (Functional Cognitive Age: {res['functional_cognitive_age']} vs Age: {res['biological_age']})")
        print(f"  * Biomotor & Speech   : Motor Jitter: {bio['motor_jitter_index']} ({bio['motor_status']}) | Speech Hesitation: {bio['speech_hesitation_score']} ({bio['speech_status']})")
        print(f"  * Cognitive Sub-scores: Memory={sub['memory_retention_index']}, Speed={sub['reaction_latency_score']}, Executive={sub['executive_function_index']}, Reminiscence={sub['autobiographical_reminiscence_score']}")
        print(f"  * Hidden Adaptive Diff: {res['hidden_adaptive_difficulty'].upper()} (Grid/Sequence Auto-Adjusted in Background)")
        print(f"  * Active Guidance ({sc['lang'].upper()}): \"{res['patient_active_guidance']}\"")
        print(f"  * 30d/90d AI Forecast : 30-Day Projected CPS: {proj['projected_cps_30_days']} | 90-Day Projected CPS: {proj['projected_cps_90_days']} ({proj['trajectory_status']})")
        print(f"  * Caregiver Risk      : {res['caregiver_dashboard']['cognitive_impairment_risk']} (Fatigue Index: {res['caregiver_dashboard']['fatigue_index']})")
        print("-" * 75)

if __name__ == "__main__":
    run_evaluation_suite()
