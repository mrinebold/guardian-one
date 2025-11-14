# Flight Logs Router
# Endpoints for flight logging and engine parameter tracking
# Built by Byte (Backend Agent) - Day 8-9
# Requirement: Dustin's Feature #3 (Engine Parameter Trend Analysis)

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from uuid import UUID, uuid4

router = APIRouter()

# Models
class EngineDataPoint(BaseModel):
    """Engine parameter data point"""
    timestamp: datetime = Field(default_factory=datetime.now)
    oil_pressure: Optional[float] = Field(None, description="Oil pressure (PSI)")
    oil_temperature: Optional[float] = Field(None, description="Oil temperature (°F)")
    cht: Optional[float] = Field(None, description="Cylinder head temperature (°F)")
    egt: Optional[float] = Field(None, description="Exhaust gas temperature (°F)")
    rpm: Optional[float] = Field(None, description="Engine RPM")
    fuel_quantity: Optional[float] = Field(None, description="Fuel quantity (gallons)")

class FlightCreate(BaseModel):
    """Create new flight log"""
    departure_airport: Optional[str] = None
    arrival_airport: Optional[str] = None
    aircraft_type: str
    departure_time: datetime
    notes: Optional[str] = None

class FlightResponse(BaseModel):
    """Flight log response"""
    id: str
    user_id: str
    departure_airport: Optional[str]
    arrival_airport: Optional[str]
    aircraft_type: str
    departure_time: datetime
    arrival_time: Optional[datetime]
    duration_minutes: Optional[int]
    notes: Optional[str]
    created_at: datetime

class EngineTrendResponse(BaseModel):
    """Engine parameter trend data"""
    parameter: str
    values: List[float]
    timestamps: List[datetime]
    average: float
    trend: str  # "stable", "increasing", "decreasing"
    alert: Optional[str] = None

# In-memory storage for M2 demo (replace with Supabase in Day 8-9)
flights_db = {}
engine_data_db = {}

@router.post("/", response_model=FlightResponse)
async def create_flight(flight: FlightCreate):
    """
    Create new flight log

    TODO (Day 8-9):
    - Store in Supabase flights table
    - Associate with authenticated user
    - Initialize engine_parameters table
    """
    flight_id = str(uuid4())

    flight_data = {
        "id": flight_id,
        "user_id": "mock_user_id",
        "departure_airport": flight.departure_airport,
        "arrival_airport": flight.arrival_airport,
        "aircraft_type": flight.aircraft_type,
        "departure_time": flight.departure_time,
        "arrival_time": None,
        "duration_minutes": None,
        "notes": flight.notes,
        "created_at": datetime.now()
    }

    flights_db[flight_id] = flight_data
    engine_data_db[flight_id] = []

    return FlightResponse(**flight_data)

@router.post("/{flight_id}/engine-data")
async def add_engine_data(flight_id: str, data: EngineDataPoint):
    """
    Add engine parameter data point to flight

    Dustin's requirement: Manual entry for M2, camera OCR in M7
    """
    if flight_id not in flights_db:
        raise HTTPException(status_code=404, detail="Flight not found")

    # TODO (Day 8-9): Store in Supabase engine_parameters table
    engine_data_db[flight_id].append(data.dict())

    return {"message": "Engine data recorded", "data_point": data}

@router.get("/{flight_id}/engine-data")
async def get_engine_data(flight_id: str):
    """Get all engine data for a flight"""
    if flight_id not in flights_db:
        raise HTTPException(status_code=404, detail="Flight not found")

    return {
        "flight_id": flight_id,
        "data_points": engine_data_db.get(flight_id, [])
    }

@router.get("/{flight_id}/trends", response_model=List[EngineTrendResponse])
async def get_engine_trends(flight_id: str):
    """
    Get engine parameter trends (last 10 flights)

    Dustin's requirement: Trend graph, alert for out-of-range values

    Algorithm:
    1. Get last 10 flights with engine data for this aircraft
    2. Calculate average for each parameter
    3. Detect trend (increasing/decreasing/stable)
    4. Alert if values exceed normal range or show concerning trends
    """
    if flight_id not in flights_db:
        raise HTTPException(status_code=404, detail="Flight not found")

    # TODO (Day 8-9): Query actual database for last 10 flights
    # For M2 demo, generate realistic mock data based on flight_id

    # Mock data simulates 10 flights with gradual CHT increase
    # (Dustin's scenario: detect engine problems early)
    mock_trends = [
        EngineTrendResponse(
            parameter="oil_pressure",
            values=[55.0, 54.5, 56.0, 55.0, 54.0, 55.5, 54.0, 53.5, 54.0, 53.0],
            timestamps=[datetime.now() for _ in range(10)],
            average=54.5,
            trend="stable",
            alert=None
        ),
        EngineTrendResponse(
            parameter="oil_temperature",
            values=[180.0, 185.0, 183.0, 187.0, 190.0, 192.0, 195.0, 197.0, 200.0, 203.0],
            timestamps=[datetime.now() for _ in range(10)],
            average=191.2,
            trend="increasing",
            alert="⚠️ Oil temperature trending up - monitor closely (normal: 100-245°F)"
        ),
        EngineTrendResponse(
            parameter="cht",
            values=[350.0, 355.0, 358.0, 362.0, 368.0, 372.0, 378.0, 385.0, 390.0, 398.0],
            timestamps=[datetime.now() for _ in range(10)],
            average=371.6,
            trend="increasing",
            alert="⚠️ CHT increasing rapidly - possible cylinder issue (normal: 200-500°F, ideal: <400°F)"
        ),
        EngineTrendResponse(
            parameter="egt",
            values=[1350.0, 1360.0, 1355.0, 1365.0, 1370.0, 1368.0, 1375.0, 1372.0, 1380.0, 1378.0],
            timestamps=[datetime.now() for _ in range(10)],
            average=1367.3,
            trend="stable",
            alert=None
        ),
        EngineTrendResponse(
            parameter="rpm",
            values=[2400.0, 2420.0, 2410.0, 2400.0, 2415.0, 2405.0, 2410.0, 2400.0, 2405.0, 2410.0],
            timestamps=[datetime.now() for _ in range(10)],
            average=2407.5,
            trend="stable",
            alert=None
        ),
        EngineTrendResponse(
            parameter="fuel_quantity",
            values=[42.0, 40.5, 41.0, 39.5, 40.0, 38.5, 39.0, 37.5, 38.0, 36.5],
            timestamps=[datetime.now() for _ in range(10)],
            average=39.3,
            trend="decreasing",
            alert="📊 Normal consumption - refuel before next long flight"
        )
    ]

    return mock_trends

@router.get("/")
async def get_flights(user_id: str, limit: int = 20):
    """Get user's flight logs"""
    # TODO (Day 8-9): Query Supabase flights table with pagination
    user_flights = [f for f in flights_db.values() if f["user_id"] == user_id]
    return {"flights": user_flights[:limit], "total": len(user_flights)}

@router.delete("/{flight_id}")
async def delete_flight(flight_id: str):
    """Delete a flight log"""
    if flight_id not in flights_db:
        raise HTTPException(status_code=404, detail="Flight not found")

    del flights_db[flight_id]
    if flight_id in engine_data_db:
        del engine_data_db[flight_id]

    return {"message": "Flight deleted"}
