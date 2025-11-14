# Guardian One Backend API
# FastAPI server for AI coaching, flight logging, and sync
# Built by Byte (Backend Agent) - Day 6-7
# Requirement: Dustin's Feature #2 (AI Weather Decision Support)

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import uvicorn
from routers import coaching, flights, auth
from services.openai_service import OpenAIService
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Lifespan context manager for startup/shutdown
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("🚀 Guardian One Backend starting...")

    # Initialize OpenAI service
    openai_service = OpenAIService()
    await openai_service.validate_api_key()

    logger.info("✅ Backend ready")

    yield

    # Shutdown
    logger.info("⏸️ Backend shutting down...")

# Create FastAPI app
app = FastAPI(
    title="Guardian One API",
    description="AI-Powered Cockpit Safety Companion Backend",
    version="1.0.0",
    lifespan=lifespan
)

# CORS middleware (allow iOS app connections)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict to specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(coaching.router, prefix="/api/coaching", tags=["AI Coaching"])
app.include_router(flights.router, prefix="/api/flights", tags=["Flight Logs"])

# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check for monitoring"""
    return {
        "status": "healthy",
        "service": "guardian-one-backend",
        "version": "1.0.0"
    }

# Root endpoint
@app.get("/")
async def root():
    """API information"""
    return {
        "app": "Guardian One Backend",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health"
    }

if __name__ == "__main__":
    # Development server
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
