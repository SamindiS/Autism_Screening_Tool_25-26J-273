"""
SenseAI ML Engine - FastAPI Application
ASD Screening Inference Service
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import predict, health

app = FastAPI(
    title="SenseAI ASD ML Engine",
    description="Machine Learning Inference Service for Autism Spectrum Disorder Screening",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

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
    return {
        "service": "SenseAI ML Engine",
        "status": "running",
        "version": "1.0.0",
        "docs": "/docs"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)

