"""
SMARAN AI: Acute Cognitive Anomaly & Sudden Drop Detection Engine
Identifies sudden performance spikes or drops (delirium indicators, fatigue spikes, motor tremors).
"""

from typing import Dict, Any, List

class CognitiveAnomalyDetector:
    """
    Monitors session-over-session cognitive telemetry to detect acute anomalies.
    """
    def __init__(self, accuracy_drop_threshold: float = 0.25, time_surge_factor: float = 1.8):
        self.accuracy_drop_threshold = accuracy_drop_threshold
        self.time_surge_factor = time_surge_factor

    def detect_anomalies(self, current_session: Dict[str, Any], baseline_history: List[Dict[str, Any]]) -> Dict[str, Any]:
        if not baseline_history:
            return {
                "anomaly_detected": False,
                "risk_level": "Normal",
                "alerts": [],
                "caregiver_action_required": False
            }

        # Calculate historical baselines
        avg_acc = sum(s.get("accuracy", 0.7) for s in baseline_history) / len(baseline_history)
        avg_time = sum(s.get("response_time_ms", 30000) for s in baseline_history) / len(baseline_history)
        avg_errors = sum(s.get("errors", 2) for s in baseline_history) / len(baseline_history)

        curr_acc = current_session.get("accuracy", 0.7)
        curr_time = current_session.get("response_time_ms", 30000)
        curr_errors = current_session.get("errors", 2)

        alerts = []

        # Check sudden accuracy drop
        acc_diff = avg_acc - curr_acc
        if acc_diff >= self.accuracy_drop_threshold:
            alerts.append({
                "type": "ACUTE_ACCURACY_DROP",
                "severity": "HIGH",
                "message": f"Accuracy dropped by {acc_diff*100:.1f}% compared to baseline average ({avg_acc*100:.1f}%)."
            })

        # Check sudden reaction latency surge
        if avg_time > 0 and curr_time >= (avg_time * self.time_surge_factor):
            alerts.append({
                "type": "LATENCY_SURGE",
                "severity": "MEDIUM",
                "message": f"Response time surged to {curr_time/1000:.1f}s vs baseline average {avg_time/1000:.1f}s."
            })

        # Check error surge
        if curr_errors >= avg_errors + 4:
            alerts.append({
                "type": "ERROR_SPIKE",
                "severity": "MEDIUM",
                "message": f"High error count ({curr_errors} errors vs baseline average {avg_errors:.1f})."
            })

        anomaly_detected = len(alerts) > 0
        risk_level = "High" if any(a["severity"] == "HIGH" for a in alerts) else ("Moderate" if anomaly_detected else "Normal")

        return {
            "anomaly_detected": anomaly_detected,
            "risk_level": risk_level,
            "alerts": alerts,
            "caregiver_action_required": risk_level in ["High", "Moderate"]
        }
