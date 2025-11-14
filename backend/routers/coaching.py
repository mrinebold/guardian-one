# AI Coaching Router
# Endpoints for AI weather analysis and safety coaching
# Built by Byte (Backend Agent) - Day 6-7
# Requirement: Dustin's Feature #2 - Response time <3 seconds

from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from services.openai_service import OpenAIService
from services.weather_service import WeatherService
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

# Request/Response models
class WeatherAnalysisRequest(BaseModel):
    """Request for AI weather analysis"""
    departure_airport: str = Field(..., description="Departure ICAO code (e.g., KAUS)")
    arrival_airport: str = Field(..., description="Arrival ICAO code (e.g., KSAT)")
    current_position: Optional[Dict[str, float]] = Field(None, description="Current lat/lon if enroute")
    fuel_remaining: Optional[float] = Field(None, description="Fuel in gallons")
    pilot_experience_hours: Optional[int] = Field(None, description="Total flight hours")
    aircraft_type: Optional[str] = Field(None, description="Aircraft type (e.g., C172)")
    custom_question: Optional[str] = Field(None, description="Custom weather question")

class WeatherAnalysisResponse(BaseModel):
    """AI weather analysis response"""
    recommendation: str = Field(..., description="Go/No-Go recommendation")
    reasoning: str = Field(..., description="Detailed reasoning")
    weather_summary: str = Field(..., description="Current weather summary")
    hazards: list[str] = Field(default_factory=list, description="Identified hazards")
    alternatives: list[str] = Field(default_factory=list, description="Alternative actions")
    confidence: str = Field(..., description="AI confidence level")
    response_time_ms: int = Field(..., description="Processing time in milliseconds")

class ChatMessage(BaseModel):
    """General AI coaching chat message"""
    user_id: str = Field(..., description="User ID for context")
    message: str = Field(..., description="User's question")
    context: Optional[Dict[str, Any]] = Field(None, description="Flight context")

class ChatResponse(BaseModel):
    """AI coaching chat response"""
    response: str = Field(..., description="AI assistant response")
    response_time_ms: int = Field(..., description="Processing time")

# Dependency for services
openai_service = OpenAIService()
weather_service = WeatherService()

@router.post("/weather-analysis", response_model=WeatherAnalysisResponse)
async def analyze_weather(request: WeatherAnalysisRequest):
    """
    AI-powered weather decision support

    Analyzes current weather conditions and provides tactical recommendations.
    Dustin's requirement: <3 second response time, conservative advice, explains reasoning.

    Example request:
    {
        "departure_airport": "KAUS",
        "arrival_airport": "KSAT",
        "fuel_remaining": 30.5,
        "pilot_experience_hours": 150,
        "aircraft_type": "C172",
        "custom_question": "Should I fly this route today?"
    }
    """
    start_time = datetime.now()

    try:
        logger.info(f"🌤️ Weather analysis requested: {request.departure_airport} → {request.arrival_airport}")

        # Fetch weather data (METARs/TAFs)
        departure_weather = await weather_service.get_metar(request.departure_airport)
        arrival_weather = await weather_service.get_metar(request.arrival_airport)

        if not departure_weather or not arrival_weather:
            raise HTTPException(
                status_code=503,
                detail="Unable to fetch weather data. Try again in a few moments."
            )

        # Build context for AI
        context = {
            "departure": {
                "airport": request.departure_airport,
                "metar": departure_weather
            },
            "arrival": {
                "airport": request.arrival_airport,
                "metar": arrival_weather
            },
            "aircraft": request.aircraft_type or "Single-engine piston",
            "pilot_hours": request.pilot_experience_hours or "Not specified",
            "fuel_remaining": f"{request.fuel_remaining} gallons" if request.fuel_remaining else "Not specified",
            "current_position": request.current_position
        }

        # Get AI analysis
        analysis = await openai_service.analyze_weather_decision(
            context=context,
            custom_question=request.custom_question
        )

        # Calculate response time
        elapsed_ms = int((datetime.now() - start_time).total_seconds() * 1000)

        logger.info(f"✅ Weather analysis completed in {elapsed_ms}ms")

        # Warn if response time exceeds Dustin's requirement
        if elapsed_ms > 3000:
            logger.warning(f"⚠️ Response time {elapsed_ms}ms exceeds 3-second target!")

        return WeatherAnalysisResponse(
            recommendation=analysis["recommendation"],
            reasoning=analysis["reasoning"],
            weather_summary=analysis["weather_summary"],
            hazards=analysis.get("hazards", []),
            alternatives=analysis.get("alternatives", []),
            confidence=analysis.get("confidence", "Medium"),
            response_time_ms=elapsed_ms
        )

    except Exception as e:
        logger.error(f"❌ Weather analysis failed: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Weather analysis failed: {str(e)}"
        )

@router.post("/chat", response_model=ChatResponse)
async def ai_coaching_chat(message: ChatMessage):
    """
    General AI safety coaching chat

    For non-weather questions (e.g., "What's the best descent rate for my aircraft?")
    """
    start_time = datetime.now()

    try:
        logger.info(f"💬 AI chat: {message.message[:50]}...")

        # Get AI response
        response_text = await openai_service.get_coaching_response(
            user_message=message.message,
            context=message.context
        )

        elapsed_ms = int((datetime.now() - start_time).total_seconds() * 1000)

        return ChatResponse(
            response=response_text,
            response_time_ms=elapsed_ms
        )

    except Exception as e:
        logger.error(f"❌ Chat failed: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"AI chat failed: {str(e)}"
        )

@router.get("/usage/{user_id}")
async def get_ai_usage(user_id: str):
    """
    Get AI usage statistics for subscription enforcement

    Returns:
    - queries_this_month: Number of AI queries used
    - queries_remaining: Remaining queries (based on subscription tier)
    - subscription_tier: free/pro/ultimate
    """
    # TODO: Implement database query for actual usage
    # For M2 demo, return mock data
    return {
        "user_id": user_id,
        "queries_this_month": 3,
        "queries_remaining": 7,
        "subscription_tier": "free",
        "limit": 10
    }
