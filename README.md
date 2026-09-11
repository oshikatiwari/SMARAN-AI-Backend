# SMARAN — AI-Powered, Multilingual Cognitive Care Platform (SIH 2026)

**SMARAN** is an integrated cognitive engagement and monitoring platform designed for elderly and dementia care. It combines adaptive-difficulty cognitive games, multi-regional Indian language support, offline-first session telemetry persistence, and machine learning models for difficulty prediction and impairment analysis.

---

## 🏗️ Repository Architecture

This monorepo consolidates all project components into a unified structure:

```
SMARAN/
├── Flutter_Game/        # Adaptive Cognitive Games (Flame Engine, Riverpod, Drift Database)
├── Multilingual/        # 5-Language Localization Documentation & Specifications
├── AI-ML-Analysis/      # Kaggle Datasets, Feature Engineering, EDA & Model Training Scripts
├── AI-Backend/          # FastAPI AI Backend & Deployed Adaptive ML Pipeline
└── README.md            # Monorepo Master Guide
```

---

## 📦 Component Details

### 1. 🎮 `Flutter_Game/`
* **Technologies**: Flutter 3.x, Flame Game Engine, Flutter Riverpod 3.x, Drift SQLite.
* **Games**:
  * **Memory Matching**: Visual recall and focus training.
  * **Pattern Recognition**: Sequence recognition and logical reasoning.
* **AI Integration**: Automatically sends session telemetry to the AI backend (`POST /predict-difficulty`) on session completion and pre-selects recommended difficulty for the next session.
* **Localization**: Fully integrated 5-language localization inside `lib/l10n/`.

### 2. 🌐 `Multilingual/`
* **Supported Languages**: English (`en`), Hindi (`hi`), Assamese (`as`), Khasi (`kha`), Mizo (`lus`).
* **Canonical Source**: `Flutter_Game/lib/l10n/`.
* **Features**: Dynamic locale switching via Riverpod `localeProvider` and `_ElderlyLanguageSelector` widget.

### 3. 🧠 `AI-ML-Analysis/`
* **Datasets**: `kaggle_dementia_clinical_dataset.csv` and `kaggle_dementia_cognitive_game_telemetry.csv`.
* **Scripts & Training**: `train_model.py`, `evaluate_telemetry.py`, `cps_analyzer.py`, `data_loader.py`.
* **Interactive Dashboard**: `AI-ML-Analysis/dashboard/app.py` for model stress testing and edge-case validation.

### 4. ⚡ `AI-Backend/`
* **Technologies**: Python 3.11, FastAPI, Uvicorn, Scikit-Learn.
* **Endpoints**:
  * `GET /health` — Service health status.
  * `POST /predict-difficulty` — Predicts optimal difficulty level based on session accuracy, completion rate, response time, errors, and hints used.
  * `POST /analyze-session` — Full diagnostic report, CPS scores, and acute drop anomaly alerts.
* **Model Pipeline**: `models/smaran_adaptive_pipeline.joblib` (RandomForestClassifier).

---

## 🔧 AI API Configuration & Deployment

The AI integration uses a configurable base URL (`SMARAN_API_BASE_URL`) rather than hard-coded hosting endpoints:

### 1. Local Testing (Default)
When running locally, the Flutter app connects to the FastAPI backend running on port 8000:
* **Default Base URL**: `http://127.0.0.1:8000`
* **Command to start local backend**:
  ```bash
  cd AI-Backend
  python -m uvicorn main:app --reload
  ```
* **Command to run Flutter app**:
  ```bash
  cd Flutter_Game
  flutter run
  ```

### 2. Physical Android Device Testing
When testing on a physical Android phone or tablet on the same local Wi-Fi network:
* **Base URL**: `http://<YOUR_LOCAL_IP>:8000` (e.g. `http://192.168.1.50:8000`)
* **Command to run Flutter app**:
  ```bash
  flutter run --dart-define=SMARAN_API_BASE_URL=http://192.168.1.50:8000
  ```

### 3. Production Deployment
For production deployment, pass the custom production API base URL at build/run time:
* **Command**:
  ```bash
  flutter run --dart-define=SMARAN_API_BASE_URL=https://your-production-api-domain.com
  ```

---

## 🔒 Offline-First Resilience & Failure Handling

* **Local Persistence First**: Session metrics are saved to local SQLite (`Drift`) **before** sending remote network requests.
* **Graceful Failure Fallback**: If the API is offline, unreachable, or times out (5s), the AI service returns `null` gracefully. The game continues uninterrupted, retaining the current difficulty level without crashing.
