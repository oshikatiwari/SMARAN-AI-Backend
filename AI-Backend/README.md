\# SMARAN AI Backend



AI-powered adaptive difficulty backend for the SMARAN cognitive gaming platform.



\## What it does



The backend receives cognitive game session metrics from the SMARAN Flutter application and uses a trained machine learning pipeline to recommend the next difficulty level.



Supported games:



\- Memory Matching

\- Pattern Recognition



Supported difficulty levels:



\- Easy

\- Medium

\- Hard



\## Architecture



Flutter Game

&#x20;     ↓

Game Session Metrics

&#x20;     ↓

FastAPI Backend

&#x20;     ↓

Trained ML Pipeline

&#x20;     ↓

Difficulty Recommendation

&#x20;     ↓

Flutter Application



\## Input



The `/predict-difficulty` endpoint accepts:



\- game\_type

\- current\_difficulty

\- accuracy

\- completion\_rate

\- response\_time\_ms

\- errors

\- hints\_used



The API does not require patient\_id or attempts.



\## Output



Example:



```json

{

&#x20; "recommended\_level": "Hard",

&#x20; "patient\_message": "Wonderful! You're getting better at this activity. Would you like to try a little more?",

&#x20; "caregiver\_summary": "Performance supports increasing the challenge level."

}

