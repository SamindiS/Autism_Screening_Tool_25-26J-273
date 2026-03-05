cd senseai_backend\ml_engine
if (Test-Path "venv\Scripts\activate.ps1") {
    .\venv\Scripts\activate.ps1
}
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
