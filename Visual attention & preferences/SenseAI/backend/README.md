# SenseAI Backend

FastAPI backend for clinical gaze-tracking prototype.

What it does

- Receives child info and gaze event batches
- Runs a simple inference heuristic (placeholder for a trained model)
- Stores tests locally in SQLite
- Generates a PDF report per test in the `reports/` folder

Quick start (Windows PowerShell)

1. Create and activate a venv

```powershell
python -m venv .venv; .\.venv\Scripts\Activate.ps1
```

2. Install dependencies

```powershell
pip install -r requirements.txt
```

3. Run the server

```powershell
uvicorn main:app --reload --port 8000 --host 0.0.0.0
```

Use `--host 0.0.0.0` so the backend is reachable from a physical device on your network.

Notes

- The inference currently uses a simple heuristic in `main.py`. Replace `compute_score_from_events` with calls to your pretrained model when available.
- The mobile app expects the backend at the URL in `frontend/lib/theme.dart` (API_BASE). For a physical device, use your PC's local IP (e.g. 192.168.x.x).
