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
├── AI-Backend/          # Live FastAPI Backend & Deployed Adaptive ML Pipeline
└── README.md            # Monorepo Master Guide
```

---

## 📦 Component Details

### 1. 🎮 `Flutter_Game/`
* **Technologies**: Flutter 3.x, Flame Game Engine, Flutter Riverpod 3.x, Drift SQLite.
* **Games**:
  * **Memory Matching**: Visual recall and focus training.
  * **Pattern Recognition**: Sequence recognition and logical reasoning.
* **Live AI Integration**: Automatically sends session telemetry to the backend (`POST /predict-difficulty`) on session completion and pre-selects recommended difficulty for the next session.
* **Localization**: Fully integrated 5-language localization inside `lib/l10n/`.

### 2. 🌐 `Multilingual/`
* **Supported Languages**: English (`en`), Hindi (`hi`), Assamese (`as`), Khasi (`kha`), Mizo (`lus`).
* **Canonical Source**: `Flutter_Game/lib/l10n/`.
* **Features**: Dynamic locale switching via Riverpod `localeProvider` and `_ElderlyLanguageSelector` widget.

### 3. 🧠 `AI-ML-Analysis/`
* **Datasets**: `kaggle_dementia_clinical_dataset.csv` and `kaggle_dementia_cognitive_game_telemetry.csv`.
* **Scripts & Training**: `train_model.py`, `evaluate_telemetry.py`, `cps_analyzer.py`, `data_loader.py`.
* **Experimental Models**: `cps_regressor.pkl`, `difficulty_classifier.pkl`, `impairment_classifier.pkl`.

### 4. ⚡ `AI-Backend/`
* **Technologies**: Python 3.11, FastAPI, Uvicorn, Scikit-Learn 1.6.1.
* **Live Deployment**: [`https://smaran-ai-backend.onrender.com`](https://smaran-ai-backend.onrender.com)
* **Endpoints**:
  * `GET /health` — Service health status.
  * `POST /predict-difficulty` — Predicts optimal difficulty level based on session accuracy, completion rate, response time, errors, and hints used.
* **Model Pipeline**: `models/smaran_adaptive_pipeline.joblib` (RandomForestClassifier).

---

## 🔒 Deployment & Verification

* **Backend Service**: Deployed on Render (`https://smaran-ai-backend.onrender.com`).
* **Local Persistence**: Offline-first local SQLite saving executes before remote network calls to ensure zero data loss.
