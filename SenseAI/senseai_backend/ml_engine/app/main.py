"""
SenseAI ML Engine - FastAPI Application
ASD Screening Inference Service

This module acts as the entry point and API Gateway for the SenseAI machine 
learning backend. It utilizes FastAPI to expose endpoints for health checking 
and model inference. 

Key Responsibilities:
1. Application Initialization: Configures FastAPI with metadata and CORS rules.
2. Startup Event Handling: Upon service start, it proactively calls `load_models()` 
   and `check_age_specific_models()` to cache the ML models (unified and age-banded) 
   into memory. This ensures minimal latency during actual inference requests.
3. Route Registration: Mounts the `/health` and `/predict` endpoints.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import API_TITLE, API_DESCRIPTION, API_VERSION
from app.core.logger import logger
from app.api import predict, health

app = FastAPI(
    title=API_TITLE,
    description=API_DESCRIPTION,
    version=API_VERSION,
    docs_url="/docs",
    redoc_url="/redoc"
)

# Startup event
@app.on_event("startup")
async def startup_event():
    """Initialize ML models on startup"""
    logger.info("=" * 50)
    logger.info(f"Starting {API_TITLE} v{API_VERSION}")
    logger.info("=" * 50)
    try:
        from app.ml.model_loader import load_models
        load_models()
        logger.info("[OK] ML Engine ready")
        
        # Check age-specific models
        from app.ml.age_specific_loader import check_age_specific_models
        age_models_status = check_age_specific_models()
        ready_count = sum(1 for status in age_models_status.values() if status['ready'])
        logger.info(f"Age-specific models: {ready_count}/3 ready")
    except Exception as e:
        logger.error(f"[ERROR] Failed to load models: {e}")
        logger.warning("Service will start but predictions will fail until models are available")

# CORS middleware (allow backend to call this service)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your backend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, prefix="/health", tags=["Health"])
app.include_router(predict.router, prefix="/predict", tags=["Prediction"])

@app.get("/")
def root():
    """Root endpoint with service information"""
    return {
        "service": API_TITLE,
        "status": "running",
        "version": API_VERSION,
        "docs": "/docs",
        "health": "/health"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)

