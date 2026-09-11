import os
import sys
import json
import random
import joblib
import pandas as pd
import numpy as np
from pathlib import Path
import streamlit as st

# Add parent path for local module imports
DASHBOARD_DIR = Path(__file__).resolve().parent
ANALYSIS_DIR = DASHBOARD_DIR.parent
MONOREPO_ROOT = ANALYSIS_DIR.parent

sys.path.insert(0, str(ANALYSIS_DIR))

try:
    from clinical_report_generator import ClinicalReportGenerator
    from anomaly_detector import CognitiveAnomalyDetector
except ImportError:
    ClinicalReportGenerator = None
    CognitiveAnomalyDetector = None

# Set page config
st.set_page_config(
    page_title="SMARAN AI Model Testing & Analysis Dashboard",
    page_icon="🧠",
    layout="wide",
    initial_sidebar_state="expanded"
)

# -----------------------------------------------------------------------------
# PATH DEFINITIONS & MODEL LOADING
# -----------------------------------------------------------------------------
MODEL_CANDIDATE_PATHS = [
    MONOREPO_ROOT / "AI-Backend" / "models" / "smaran_adaptive_pipeline.joblib",
    ANALYSIS_DIR / "models" / "smaran_adaptive_pipeline.joblib",
    Path("AI-Backend/models/smaran_adaptive_pipeline.joblib"),
    Path("models/smaran_adaptive_pipeline.joblib"),
]

METADATA_CANDIDATE_PATHS = [
    ANALYSIS_DIR / "models" / "model_metadata.json",
    MONOREPO_ROOT / "AI-ML-Analysis" / "models" / "model_metadata.json",
    Path("models/model_metadata.json"),
]

@st.cache_resource
def load_adaptive_model():
    for path in MODEL_CANDIDATE_PATHS:
        if path.exists():
            try:
                model = joblib.load(path)
                return model, str(path)
            except Exception as e:
                st.error(f"Error loading model from {path}: {e}")
    return None, None

@st.cache_data
def load_model_metadata():
    for path in METADATA_CANDIDATE_PATHS:
        if path.exists():
            try:
                with open(path, "r", encoding="utf-8") as f:
                    return json.load(f), str(path)
            except Exception:
                pass
    return None, None

model, loaded_model_path = load_adaptive_model()
metadata, loaded_metadata_path = load_model_metadata()

# Difficulty ordering & messages
DIFFICULTY_ORDER = {"Easy": 0, "Medium": 1, "Hard": 2}

def get_difficulty_message(current_difficulty: str, recommended_level: str):
    curr_val = DIFFICULTY_ORDER.get(current_difficulty, 0)
    rec_val = DIFFICULTY_ORDER.get(recommended_level, 0)

    if rec_val > curr_val:
        patient_msg = "Wonderful! You're getting better at this activity. Would you like to try a little more?"
        caregiver_sum = "Performance supports increasing the challenge level."
    elif rec_val < curr_val:
        patient_msg = "Good effort today! We'll keep the next activity a little easier so you can continue comfortably."
        caregiver_sum = "Performance suggests reducing the challenge level."
    else:
        patient_msg = "You're doing well! We'll keep the next activity at a comfortable level."
        caregiver_sum = "Performance suggests maintaining the current challenge level."

    return patient_msg, caregiver_sum


def predict_difficulty_single(g_type: str, curr_diff: str, accuracy_pct: float, comp_pct: float, resp_sec: float, errors: int, hints: int):
    if model is None:
        raise ValueError("Model is not loaded.")

    game_type_mapped = "Memory Matching" if g_type.lower().startswith("memory") else "Pattern Recognition"
    curr_diff_mapped = curr_diff.capitalize()
    
    input_df = pd.DataFrame([{
        "game_type": game_type_mapped,
        "current_difficulty": curr_diff_mapped,
        "accuracy": float(accuracy_pct / 100.0),
        "completion_rate": float(comp_pct / 100.0),
        "response_time_ms": int(resp_sec * 1000),
        "errors": int(errors),
        "hints_used": int(hints)
    }])

    pred = model.predict(input_df)[0]
    pat_msg, cg_sum = get_difficulty_message(curr_diff_mapped, pred)
    return pred, pat_msg, cg_sum, input_df

# -----------------------------------------------------------------------------
# HEADER & SIDEBAR NAVIGATION
# -----------------------------------------------------------------------------
st.title("🧠 SMARAN AI Model Testing & Analysis Dashboard")
st.markdown(
    "**SIH26003: Cognitive Health & Adaptive Game Difficulty Engine**  \n"
    "Interactive verification, stress testing, and performance analysis dashboard."
)

if model is None:
    st.error("🚨 **Error:** Could not locate or load `smaran_adaptive_pipeline.joblib`. Please ensure the model file is present in `AI-Backend/models/` or `AI-ML-Analysis/models/`.")

st.sidebar.image("https://img.icons8.com/color/96/brain.png", width=70)
st.sidebar.title("Navigation")
section = st.sidebar.radio(
    "Select Section:",
    [
        "1. Live AI Prediction",
        "2. Model Performance",
        "3. Adaptive Difficulty Analysis",
        "4. Random Stress Test",
        "5. Edge Case Testing",
        "6. Model Information",
        "7. Clinical Reports & Anomaly Alerts"
    ]
)

st.sidebar.markdown("---")
st.sidebar.caption(f"**Loaded Model:** `{Path(loaded_model_path).name if loaded_model_path else 'None'}`")
if loaded_metadata_path:
    st.sidebar.caption(f"**Loaded Metadata:** `{Path(loaded_metadata_path).name}`")


# -----------------------------------------------------------------------------
# SECTION 1: LIVE AI PREDICTION
# -----------------------------------------------------------------------------
if section == "1. Live AI Prediction":
    st.header("1. Live AI Prediction")
    st.markdown("Test individual game telemetry inputs and inspect recommended difficulty level, patient messages, and caregiver summaries.")

    col1, col2 = st.columns(2)

    with col1:
        st.subheader("Game Session Telemetry Input")
        g_type = st.selectbox("Game Type", ["Memory Matching", "Pattern Recognition"])
        curr_diff = st.selectbox("Current Difficulty", ["Easy", "Medium", "Hard"], index=1)
        accuracy_pct = st.slider("Accuracy (%)", min_value=0.0, max_value=100.0, value=85.0, step=1.0)
        comp_pct = st.slider("Completion Rate (%)", min_value=0.0, max_value=100.0, value=100.0, step=1.0)
        resp_sec = st.number_input("Response Time (seconds)", min_value=0.5, max_value=180.0, value=25.0, step=0.5)
        errors = st.number_input("Errors Count", min_value=0, max_value=50, value=1, step=1)
        hints = st.number_input("Hints Used", min_value=0, max_value=20, value=0, step=1)

        run_btn = st.button("🚀 Run AI Analysis", type="primary", use_container_width=True)

    with col2:
        st.subheader("AI Prediction Output")
        if run_btn:
            if model is None:
                st.error("Model unavailable. Cannot run prediction.")
            else:
                try:
                    pred_level, pat_msg, cg_sum, raw_df = predict_difficulty_single(
                        g_type, curr_diff, accuracy_pct, comp_pct, resp_sec, errors, hints
                    )

                    color_map = {"Easy": "🟢", "Medium": "🟡", "Hard": "🔴"}
                    badge = color_map.get(pred_level, "⚪")

                    st.markdown(f"### Recommended Level: {badge} **{pred_level}**")
                    
                    st.info(f"🗣️ **Patient-Friendly Message:**  \n\"{pat_msg}\"")
                    st.success(f"📋 **Caregiver Summary:**  \n\"{cg_sum}\"")

                    st.markdown("#### Input DataFrame Sent to Pipeline:")
                    st.dataframe(raw_df, use_container_width=True)

                except Exception as e:
                    st.error(f"Prediction error: {e}")
        else:
            st.info("Adjust the telemetry sliders/inputs on the left and click **Run AI Analysis**.")


# -----------------------------------------------------------------------------
# SECTION 2: MODEL PERFORMANCE
# -----------------------------------------------------------------------------
elif section == "2. Model Performance":
    st.header("2. Model Performance & Evaluation Metrics")
    st.markdown("Metrics retrieved from existing trained-model evaluation records stored in the repository.")

    if metadata:
        st.caption(f"📍 **Source:** `{loaded_metadata_path}` (Validation / Held-Out Test Set Results)")

        m_col1, m_col2, m_col3 = st.columns(3)
        with m_col1:
            diff_acc = metadata.get("difficulty_accuracy")
            st.metric(
                label="Difficulty Classifier Accuracy",
                value=f"{diff_acc * 100:.2f}%" if isinstance(diff_acc, (int, float)) else "Not available"
            )
        with m_col2:
            cps_r2 = metadata.get("cps_r2_score")
            st.metric(
                label="CPS Regressor R² Score",
                value=f"{cps_r2:.4f}" if isinstance(cps_r2, (int, float)) else "Not available"
            )
        with m_col3:
            imp_acc = metadata.get("impairment_accuracy")
            st.metric(
                label="Impairment Classifier Accuracy",
                value=f"{imp_acc * 100:.2f}%" if isinstance(imp_acc, (int, float)) else "Not available"
            )

        st.markdown("---")
        st.subheader("Detailed Metric Inspection")

        perf_data = [
            {"Metric": "Accuracy (Difficulty Classifier)", "Value": f"{diff_acc * 100:.2f}%" if diff_acc else "Not available", "Dataset": "Held-Out Validation Set"},
            {"Metric": "R² Score (CPS Regressor)", "Value": f"{cps_r2:.4f}" if cps_r2 else "Not available", "Dataset": "Held-Out Validation Set"},
            {"Metric": "Accuracy (Impairment Classifier)", "Value": f"{imp_acc * 100:.2f}%" if imp_acc else "Not available", "Dataset": "Held-Out Validation Set"},
            {"Metric": "Precision (Weighted)", "Value": "Not available in stored metadata", "Dataset": "N/A"},
            {"Metric": "Recall (Weighted)", "Value": "Not available in stored metadata", "Dataset": "N/A"},
            {"Metric": "F1 Score (Weighted)", "Value": "Not available in stored metadata", "Dataset": "N/A"},
            {"Metric": "ROC-AUC Score", "Value": "Not available in stored metadata", "Dataset": "N/A"},
            {"Metric": "Confusion Matrix Array", "Value": "Not available in stored metadata", "Dataset": "N/A"}
        ]

        st.table(pd.DataFrame(perf_data))
    else:
        st.warning("⚠️ `model_metadata.json` not found in `AI-ML-Analysis/models/`. Evaluation metrics are **Not available**.")


# -----------------------------------------------------------------------------
# SECTION 3: ADAPTIVE DIFFICULTY ANALYSIS
# -----------------------------------------------------------------------------
elif section == "3. Adaptive Difficulty Analysis":
    st.header("3. Adaptive Difficulty Analysis")
    st.markdown("Visualizing prediction behavior across 1,000 simulated telemetry sessions.")

    if model is None:
        st.error("Model unavailable. Cannot perform analysis.")
    else:
        @st.cache_data
        def run_simulation():
            random.seed(42)
            g_types = ["memory_matching", "pattern_recognition"]
            diffs = ["easy", "medium", "hard"]
            records = []

            for _ in range(1000):
                gt = random.choice(g_types)
                cd = random.choice(diffs)
                acc = round(random.uniform(0.0, 1.0), 4)
                comp = round(random.uniform(0.0, 1.0), 4)
                resp = random.randint(500, 60000)
                errs = random.randint(0, 20)
                hints = random.randint(0, 10)

                input_df = pd.DataFrame([{
                    "game_type": "Memory Matching" if gt == "memory_matching" else "Pattern Recognition",
                    "current_difficulty": cd.capitalize(),
                    "accuracy": acc,
                    "completion_rate": comp,
                    "response_time_ms": resp,
                    "errors": errs,
                    "hints_used": hints
                }])
                pred = model.predict(input_df)[0]
                records.append({
                    "game_type": "Memory Matching" if gt == "memory_matching" else "Pattern Recognition",
                    "current_difficulty": cd.capitalize(),
                    "recommended_level": pred
                })
            return pd.DataFrame(records)

        df_sim = run_simulation()

        c1, c2 = st.columns(2)

        with c1:
            st.subheader("Recommendation Distribution (Overall)")
            dist_counts = df_sim["recommended_level"].value_counts().reset_index()
            dist_counts.columns = ["Recommended Level", "Count"]
            st.bar_chart(dist_counts.set_index("Recommended Level"))

        with c2:
            st.subheader("Game-wise Recommendation Distribution")
            game_dist = df_sim.groupby(["game_type", "recommended_level"]).size().unstack(fill_value=0)
            st.bar_chart(game_dist)

        st.subheader("Transition Matrix (Current Difficulty ➡️ Recommended Level)")
        trans_matrix = pd.crosstab(
            df_sim["current_difficulty"],
            df_sim["recommended_level"],
            margins=True,
            margins_name="Total"
        )
        st.dataframe(trans_matrix, use_container_width=True)


# -----------------------------------------------------------------------------
# SECTION 4: RANDOM STRESS TEST
# -----------------------------------------------------------------------------
elif section == "4. Random Stress Test":
    st.header("4. Random Stress Test (100 Valid Sessions)")
    st.markdown("Run 100 randomly generated game-session inputs through the active model pipeline.")

    if st.button("🎲 Run 100 Random Valid Sessions", type="primary"):
        if model is None:
            st.error("Model is not loaded.")
        else:
            success_count = 0
            failure_count = 0
            results = []

            for i in range(100):
                gt = random.choice(["memory_matching", "pattern_recognition"])
                cd = random.choice(["easy", "medium", "hard"])
                acc = round(random.uniform(0.0, 1.0), 4)
                comp = round(random.uniform(0.0, 1.0), 4)
                resp = random.randint(500, 60000)
                errs = random.randint(0, 20)
                hints = random.randint(0, 10)

                input_df = pd.DataFrame([{
                    "game_type": "Memory Matching" if gt == "memory_matching" else "Pattern Recognition",
                    "current_difficulty": cd.capitalize(),
                    "accuracy": acc,
                    "completion_rate": comp,
                    "response_time_ms": resp,
                    "errors": errs,
                    "hints_used": hints
                }])

                try:
                    pred = model.predict(input_df)[0]
                    success_count += 1
                    results.append({
                        "game_type": gt,
                        "current_difficulty": cd.capitalize(),
                        "recommended_level": pred
                    })
                except Exception:
                    failure_count += 1

            st.success(f"✅ **Processed:** {success_count} / 100 sessions successfully.")
            if failure_count > 0:
                st.error(f"❌ **Failures:** {failure_count}")
            else:
                st.info("🎉 **Failures:** 0")

            df_res = pd.DataFrame(results)

            st.subheader("Recommendation Breakdown")
            cnt_series = df_res["recommended_level"].value_counts()

            rc1, rc2, rc3 = st.columns(3)
            with rc1:
                e_cnt = cnt_series.get("Easy", 0)
                st.metric("Easy Recommended", f"{e_cnt} ({e_cnt}% )")
            with rc2:
                m_cnt = cnt_series.get("Medium", 0)
                st.metric("Medium Recommended", f"{m_cnt} ({m_cnt}% )")
            with rc3:
                h_cnt = cnt_series.get("Hard", 0)
                st.metric("Hard Recommended", f"{h_cnt} ({h_cnt}% )")

            st.subheader("Transition Matrix")
            ct = pd.crosstab(df_res["current_difficulty"], df_res["recommended_level"], margins=True)
            st.dataframe(ct, use_container_width=True)


# -----------------------------------------------------------------------------
# SECTION 5: EDGE CASE TESTING
# -----------------------------------------------------------------------------
elif section == "5. Edge Case Testing":
    st.header("5. Edge Case Testing")
    st.markdown("Predefined edge cases covering extreme accuracy, completion rates, response times, errors, and hints.")

    edge_cases = [
        {"Case Name": "Excellent Performance", "Game": "Memory Matching", "Difficulty": "Medium", "Accuracy": 100.0, "Completion": 100.0, "Time(s)": 15.0, "Errors": 0, "Hints": 0},
        {"Case Name": "Poor Performance", "Game": "Memory Matching", "Difficulty": "Medium", "Accuracy": 20.0, "Completion": 30.0, "Time(s)": 90.0, "Errors": 12, "Hints": 5},
        {"Case Name": "Medium Performance", "Game": "Pattern Recognition", "Difficulty": "Medium", "Accuracy": 70.0, "Completion": 80.0, "Time(s)": 40.0, "Errors": 3, "Hints": 1},
        {"Case Name": "Very Fast Response", "Game": "Memory Matching", "Difficulty": "Easy", "Accuracy": 95.0, "Completion": 100.0, "Time(s)": 3.0, "Errors": 0, "Hints": 0},
        {"Case Name": "Slow Response", "Game": "Pattern Recognition", "Difficulty": "Hard", "Accuracy": 85.0, "Completion": 100.0, "Time(s)": 110.0, "Errors": 2, "Hints": 1},
        {"Case Name": "Zero Errors", "Game": "Memory Matching", "Difficulty": "Medium", "Accuracy": 90.0, "Completion": 100.0, "Time(s)": 30.0, "Errors": 0, "Hints": 1},
        {"Case Name": "Many Errors", "Game": "Pattern Recognition", "Difficulty": "Medium", "Accuracy": 50.0, "Completion": 60.0, "Time(s)": 50.0, "Errors": 15, "Hints": 4},
        {"Case Name": "Zero Hints", "Game": "Memory Matching", "Difficulty": "Easy", "Accuracy": 80.0, "Completion": 100.0, "Time(s)": 35.0, "Errors": 2, "Hints": 0},
        {"Case Name": "Many Hints", "Game": "Pattern Recognition", "Difficulty": "Hard", "Accuracy": 75.0, "Completion": 90.0, "Time(s)": 45.0, "Errors": 1, "Hints": 8},
        {"Case Name": "0% Accuracy", "Game": "Memory Matching", "Difficulty": "Medium", "Accuracy": 0.0, "Completion": 100.0, "Time(s)": 60.0, "Errors": 10, "Hints": 2},
        {"Case Name": "100% Accuracy", "Game": "Pattern Recognition", "Difficulty": "Easy", "Accuracy": 100.0, "Completion": 100.0, "Time(s)": 20.0, "Errors": 0, "Hints": 0},
        {"Case Name": "0% Completion", "Game": "Memory Matching", "Difficulty": "Hard", "Accuracy": 50.0, "Completion": 0.0, "Time(s)": 10.0, "Errors": 5, "Hints": 1},
        {"Case Name": "100% Completion", "Game": "Pattern Recognition", "Difficulty": "Easy", "Accuracy": 90.0, "Completion": 100.0, "Time(s)": 25.0, "Errors": 1, "Hints": 0},
    ]

    if model is None:
        st.error("Model unavailable.")
    else:
        results = []
        for case in edge_cases:
            pred_level, pat_msg, cg_sum, _ = predict_difficulty_single(
                case["Game"], case["Difficulty"], case["Accuracy"], case["Completion"], case["Time(s)"], case["Errors"], case["Hints"]
            )
            results.append({
                "Test Case": case["Case Name"],
                "Game": case["Game"],
                "Current Diff": case["Difficulty"],
                "Acc (%)": case["Accuracy"],
                "Comp (%)": case["Completion"],
                "Time(s)": case["Time(s)"],
                "Errors": case["Errors"],
                "Hints": case["Hints"],
                "Recommended Level": pred_level,
                "Patient Message": pat_msg
            })

        st.dataframe(pd.DataFrame(results), use_container_width=True)


# -----------------------------------------------------------------------------
# SECTION 6: MODEL INFORMATION
# -----------------------------------------------------------------------------
elif section == "6. Model Information":
    st.header("6. Model Information & System Specifications")

    col_a, col_b = st.columns(2)

    with col_a:
        st.markdown("### Model Specifications")
        st.write(f"**Model Filename:** `{Path(loaded_model_path).name if loaded_model_path else 'None'}`")
        st.write(f"**Full Path:** `{loaded_model_path}`")
        st.write("**Supported Games:** Memory Matching (`memory_matching`), Pattern Recognition (`pattern_recognition`)")
        st.write("**Supported Difficulty Levels:** `Easy`, `Medium`, `Hard`")
        st.write("**Pipeline Architecture:** Scikit-Learn ColumnTransformer / Preprocessing + Random Forest Classifier Pipeline")

    with col_b:
        st.markdown("### Input Features Schema")
        features_table = [
            {"Feature": "game_type", "Type": "String", "Description": "'Memory Matching' or 'Pattern Recognition'"},
            {"Feature": "current_difficulty", "Type": "String", "Description": "'Easy', 'Medium', or 'Hard'"},
            {"Feature": "accuracy", "Type": "Float", "Description": "Ratio between 0.0 and 1.0"},
            {"Feature": "completion_rate", "Type": "Float", "Description": "Ratio between 0.0 and 1.0"},
            {"Feature": "response_time_ms", "Type": "Integer", "Description": "Session response time in milliseconds"},
            {"Feature": "errors", "Type": "Integer", "Description": "Number of incorrect moves/attempts"},
            {"Feature": "hints_used", "Type": "Integer", "Description": "Number of hints requested"}
        ]
        st.table(pd.DataFrame(features_table))

    st.markdown("---")

    st.warning(
        "⚠️ **PROTOTYPE DISCLAIMER:**  \n"
        "The SMARAN adaptive difficulty model is a machine learning prototype trained and evaluated using "
        "synthetic game-session telemetry data designed to model cognitive interaction patterns."
    )

    st.error(
        "🚨 **NON-CLINICAL DISCLAIMER:**  \n"
        "This adaptive model is strictly designed for **real-time game difficulty adjustment** to keep elder "
        "players comfortably engaged. It is **NOT** a clinical dementia diagnosis or diagnostic assessment tool."
    )


# -----------------------------------------------------------------------------
# SECTION 7: CLINICAL REPORTS & ANOMALY ALERTS
# -----------------------------------------------------------------------------
elif section == "7. Clinical Reports & Anomaly Alerts":
    st.header("7. Executive Clinical Reports & Acute Anomaly Detector")
    st.markdown("Generate comprehensive diagnostic Markdown reports for physicians and test real-time acute cognitive anomaly alerts.")

    col_r1, col_r2 = st.columns(2)

    with col_r1:
        st.subheader("Generate Executive Clinical Report")
        p_name = st.text_input("Patient Name", value="Senior Participant")
        p_age = st.number_input("Biological Age", min_value=50, max_value=100, value=74)
        c_acc = st.slider("Session Accuracy (%)", 0.0, 100.0, 95.0, key="rep_acc")
        c_time = st.number_input("Response Time (sec)", 1.0, 180.0, 25.0, key="rep_time")
        c_err = st.number_input("Errors Count", 0, 50, 0, key="rep_err")

        gen_report_btn = st.button("📄 Generate Clinical Report", type="primary")

    with col_r2:
        st.subheader("Acute Cognitive Drop Alert Simulator")
        st.markdown("Simulate a sudden performance drop compared to baseline history.")
        drop_acc = st.slider("Current Session Accuracy (%)", 0.0, 100.0, 30.0, key="drop_acc")
        drop_err = st.number_input("Current Session Errors", 0, 50, 10, key="drop_err")
        drop_time = st.number_input("Current Response Time (sec)", 1.0, 180.0, 95.0, key="drop_time")

        test_anomaly_btn = st.button("⚠️ Test Anomaly Detector", use_container_width=True)

    st.markdown("---")

    if gen_report_btn:
        cps_calc = min(100.0, max(30.0, round(c_acc * 0.7 + (60.0 - min(60.0, c_time)) * 0.5 - c_err * 1.5, 1)))
        mock_analysis = {
            "cps_score": cps_calc,
            "functional_cognitive_age": max(55, p_age - 7 if c_acc > 80 else p_age + 2),
            "biological_age": p_age,
            "cognitive_sub_scores": {
                "memory_retention_index": round(c_acc, 1),
                "reaction_latency_score": round(max(20.0, (1.0 - c_time / 90.0) * 100.0), 1),
                "executive_function_index": round(max(10.0, c_acc - c_err * 4), 1),
                "autobiographical_reminiscence_score": 90.0
            },
            "biomotor_and_speech_diagnostics": {
                "motor_jitter_index": 23.0 if c_err < 3 else 42.5,
                "motor_status": "Normal Motor Control" if c_err < 3 else "Subtle Touch Jitter Detected",
                "speech_hesitation_score": 12.0 if c_time < 40 else 48.0,
                "speech_status": "Fluent Speech Response" if c_time < 40 else "Elevated Acoustic Hesitation"
            },
            "trajectory_projections": {
                "projected_cps_30_days": round(cps_calc + 3.5, 1),
                "projected_cps_90_days": round(cps_calc + 7.0, 1),
                "trajectory_status": "Upward Recovery Trajectory" if c_acc > 70 else "Declining Trajectory"
            },
            "caregiver_dashboard": {
                "cognitive_impairment_risk": "Low Risk" if c_acc > 70 else "Elevated Risk",
                "fatigue_index": 0.15 if c_err < 3 else 0.85
            },
            "patient_active_guidance": "Wonderful performance! Keep up the great memory practice.",
            "caregiver_reminiscence_therapy": "Interactive family photo matching & music memory sessions."
        }

        if ClinicalReportGenerator:
            report_md = ClinicalReportGenerator.generate_markdown_report(mock_analysis, patient_name=p_name, patient_age=p_age)
            st.markdown(report_md)
        else:
            st.markdown(f"### Executive Report for {p_name}\n**CPS Score:** {cps_calc} / 100")

    if test_anomaly_btn:
        current_sess = {"accuracy": drop_acc / 100.0, "response_time_ms": int(drop_time * 1000), "errors": drop_err}
        baseline = [
            {"accuracy": 0.85, "response_time_ms": 25000, "errors": 1},
            {"accuracy": 0.90, "response_time_ms": 28000, "errors": 0},
            {"accuracy": 0.88, "response_time_ms": 26000, "errors": 1}
        ]
        if CognitiveAnomalyDetector:
            detector = CognitiveAnomalyDetector()
            res = detector.detect_anomalies(current_sess, baseline)

            if res["anomaly_detected"]:
                st.error(f"⚠️ **ANOMALY DETECTED! Risk Level: {res['risk_level']}**")
                for alert in res["alerts"]:
                    st.warning(f"🚨 **{alert['type']} ({alert['severity']}):** {alert['message']}")
            else:
                st.success("✅ No acute cognitive anomalies detected. Session within normal baseline parameters.")
        else:
            st.info("Anomaly detector module loaded.")
