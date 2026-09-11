import sys
import os
import json

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

from cps_analyzer import CPSAnalyzer

def interactive_session():
    analyzer = CPSAnalyzer()

    print("\n" + "="*75)
    print("   SIH26003: 5-LANGUAGE AI & ML LIVE INTERACTIVE TESTER")
    print("   Languages: Hindi, English, Mizo, Khasi, Assamese")
    print("="*75)
    print("Input custom patient gameplay response metrics to see real-time CPS scores,")
    print("cognitive breakdown, hidden difficulty adaptation, & activity recommendations.\n")

    try:
        print("Select Preferred Language for Patient UI Guidance:")
        print(" [1] Hindi  [2] English  [3] Mizo  [4] Khasi  [5] Assamese")
        lang_choice = input("Choice (1-5) [default 2]: ").strip()
        lang_map = {"1": "Hindi", "2": "English", "3": "Mizo", "4": "Khasi", "5": "Assamese"}
        pref_lang = lang_map.get(lang_choice, "English")

        acc_in = input("1. Gameplay Accuracy [0.0 - 1.0, default 0.88]: ").strip()
        accuracy = float(acc_in) if acc_in else 0.88

        time_in = input("2. Response Time in seconds [e.g. 30, default 30]: ").strip()
        response_time_ms = int(float(time_in) * 1000) if time_in else 30000

        attempts_in = input("3. Total Attempts [e.g. 10, default 10]: ").strip()
        attempts = int(attempts_in) if attempts_in else 10

        errors_in = input("4. Errors Count [e.g. 1, default 1]: ").strip()
        errors = int(errors_in) if errors_in else 1

        hints_in = input("5. Hints Used [e.g. 0, default 0]: ").strip()
        hints = int(hints_in) if hints_in else 0

        mmse_in = input("6. Patient MMSE Score [0 - 30, default 25.0]: ").strip()
        mmse = float(mmse_in) if mmse_in else 25.0

        gtype_in = input("7. Game Type (1: Memory Matching, 2: Pattern Recognition) [default 1]: ").strip()
        game_type = "pattern_recognition" if gtype_in == "2" else "memory_matching"

    except Exception as e:
        print(f"Using default sample metrics ({e})...")
        pref_lang = "English"
        accuracy = 0.88
        response_time_ms = 30000
        attempts = 10
        errors = 1
        hints = 0
        mmse = 25.0
        game_type = "memory_matching"

    telemetry = {
        "age": 72,
        "education_level": 2,
        "preferred_language": pref_lang,
        "mmse_score": mmse,
        "gds_score": 4.0,
        "game_type": game_type,
        "accuracy": accuracy,
        "response_time_ms": response_time_ms,
        "attempts": attempts,
        "errors": errors,
        "hints_used": hints,
        "completion_rate": min(1.0, accuracy + 0.08)
    }

    result = analyzer.analyze_session(telemetry)
    sub = result["cognitive_sub_scores"]
    trend = result["longitudinal_trend"]
    recs = result["ai_activity_recommendations"]

    print("\n" + "─"*75)
    print("               AI ANALYSIS & ML MODEL OUTPUT REPORT")
    print("─"*75)
    print(f"📊 Composite CPS Score           : {result['cps_score']} / 100.0")
    print(f"🧠 Cognitive Sub-Scores          :")
    print(f"   • Memory Retention Index     : {sub['memory_retention_index']} / 100")
    print(f"   • Reaction Latency Score     : {sub['reaction_latency_score']} / 100")
    print(f"   • Executive Function Index   : {sub['executive_function_index']} / 100")
    print(f"   • Error Recovery Rate        : {sub['error_recovery_rate']} / 100")
    print(f"\n⚙️  Hidden Adaptive Difficulty    : {result['hidden_adaptive_difficulty'].upper()}")
    print(f"🔒  Patient UI Badge Status      : HIDDEN FROM PATIENT (Prevents Stigma)")
    print(f"💬 Active Patient Voice Guidance  : ({pref_lang.upper()}): \"{result['patient_active_guidance']}\"")
    print(f"\n📈 Longitudinal Cognitive Trend  : {trend['direction']} ({trend['clinical_summary']})")
    print(f"💡 AI Recommended Activity      : {recs[0]['activity_name']} [{recs[0]['category']}]")
    print(f"   • Description                : {recs[0]['description']}")
    print(f"\n🏥 Caregiver Risk Status       : {result['caregiver_dashboard']['cognitive_impairment_risk']}")
    print(f"😓 Patient Fatigue Index         : {result['caregiver_dashboard']['fatigue_index']} / 1.0")
    print(f"🎯 Target Game Configuration     : {result['caregiver_dashboard']['target_game_config']}")
    print("─"*75 + "\n")

if __name__ == "__main__":
    interactive_session()
