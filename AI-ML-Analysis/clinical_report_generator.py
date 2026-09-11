"""
SMARAN AI: Executive Clinical & Caregiver Report Generator
Generates comprehensive diagnostic reports with CPS scores, sub-domain analysis, trajectory forecasts, and caregiver guidance.
"""

import json
from datetime import datetime
from typing import Dict, Any

class ClinicalReportGenerator:
    """
    Generates structured Markdown and HTML clinical reports for physicians and caregivers.
    """
    @staticmethod
    def generate_markdown_report(session_analysis: Dict[str, Any], patient_name: str = "Senior Participant", patient_age: int = 74) -> str:
        cps = session_analysis.get("cps_score", 75.0)
        func_age = session_analysis.get("functional_cognitive_age", patient_age)
        bio_age = session_analysis.get("biological_age", patient_age)
        sub = session_analysis.get("cognitive_sub_scores", {})
        bio = session_analysis.get("biomotor_and_speech_diagnostics", {})
        proj = session_analysis.get("trajectory_projections", {})
        caregiver = session_analysis.get("caregiver_dashboard", {})
        guidance = session_analysis.get("patient_active_guidance", "")

        now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        report = f"""# 🧠 SMARAN AI: Executive Cognitive Performance & Clinical Report

**Generated On:** {now_str}  
**Patient Name:** {patient_name} | **Age:** {bio_age} years | **Functional Cognitive Age:** {func_age} years  
**SIH Problem Statement:** SIH26003 (Cognitive Care & Reminiscence Suite)

---

## 1. Executive Cognitive Summary
* **Composite CPS Score:** **`{cps} / 100.0`**
* **Cognitive Trajectory Status:** **{proj.get("trajectory_status", "Stable")}**
* **Clinical Impairment Risk Level:** **{caregiver.get("cognitive_impairment_risk", "Low Risk")}**
* **Session Fatigue Index:** `{caregiver.get("fatigue_index", 0.0)}`

---

## 2. Cognitive Sub-Domain Breakdown (0 - 100 Scale)
| Cognitive Sub-Domain | Score | Evaluation Status |
| :--- | :---: | :--- |
| **Memory Retention Index** | `{sub.get("memory_retention_index", 0.0):.1f}` | Spatial & Visual Pair Memory |
| **Reaction Latency Score** | `{sub.get("reaction_latency_score", 0.0):.1f}` | Processing Speed & Choice Reaction |
| **Executive Function Index** | `{sub.get("executive_function_index", 0.0):.1f}` | Sequence Planning & Inhibition |
| **Reminiscence Score** | `{sub.get("autobiographical_reminiscence_score", 0.0):.1f}` | Familial & Cultural Cue Recall |

---

## 3. Biomotor & Speech Acoustics Diagnostics
* **Motor Jitter Index:** `{bio.get("motor_jitter_index", 0.0):.1f}` — *Status:* **{bio.get("motor_status", "Normal")}**
* **Speech Hesitation Score:** `{bio.get("speech_hesitation_score", 0.0):.1f}` — *Status:* **{bio.get("speech_status", "Normal")}**

---

## 4. AI Predictive Trajectory Forecast (30 & 90 Days)
* **30-Day Projected CPS Score:** **`{proj.get("projected_cps_30_days", cps):.1f} / 100`**
* **90-Day Projected CPS Score:** **`{proj.get("projected_cps_90_days", cps):.1f} / 100`**
* **Forecasted Trend:** {proj.get("trajectory_status", "Stable")}

---

## 5. Active Patient Guidance & Reminiscence Therapy Plan
* **Active Patient Guidance:** *"{guidance}"*
* **Recommended Reminiscence Therapy:** {session_analysis.get("caregiver_reminiscence_therapy", "Interactive family photo matching & music memory sessions.")}

---
*Report automatically compiled by SMARAN AI Multi-Feature Engine v4.0. Confidentially exported for caregiver and physician review.*
"""
        return report
