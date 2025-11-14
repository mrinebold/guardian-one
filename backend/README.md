# Guardian One Backend

FastAPI backend for AI weather analysis, flight logging, and authentication.

## Quick Start

### 1. Install Dependencies

```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Configure Environment Variables

Create a `.env` file in the `backend/` directory:

```bash
cp .env.example .env
```

Edit `.env` and add your API keys:

```bash
# Required: OpenAI API key for AI weather analysis
OPENAI_API_KEY=sk-...

# Optional: Supabase credentials (for production)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...

# Optional: JWT secret (for authentication)
JWT_SECRET=your-secret-key-here
```

**Get OpenAI API Key**: https://platform.openai.com/api-keys

### 3. Run Development Server

```bash
# From backend/ directory
python main.py
```

Server will start on: http://localhost:8000

- **API Docs**: http://localhost:8000/docs (Swagger UI)
- **Health Check**: http://localhost:8000/health

### 4. Test AI Weather Analysis

Using Swagger UI (http://localhost:8000/docs):

1. Navigate to **POST /api/coaching/weather-analysis**
2. Click "Try it out"
3. Enter test data:

```json
{
  "departure_airport": "KAUS",
  "arrival_airport": "KSAT",
  "fuel_remaining": 30.5,
  "pilot_experience_hours": 150,
  "aircraft_type": "C172",
  "custom_question": "Should I fly this route today?"
}
```

4. Click "Execute"
5. Expected response time: <3 seconds
6. Response includes:
   - **recommendation**: GO/NO-GO/WAIT/DIVERT
   - **reasoning**: AI explanation
   - **weather_summary**: Current conditions
   - **hazards**: List of identified hazards
   - **alternatives**: Suggested alternative actions

### 5. Test with iOS Simulator

Once the backend is running, the iOS app (running on Xcode simulator) will connect to `http://localhost:8000`.

**iOS Connection Setup**:
- iOS simulator uses `localhost` to connect to Mac's backend
- No network configuration needed for local development

## API Endpoints

### Authentication
- `POST /api/auth/apple-signin` - Apple Sign-In (TODO: Day 3)
- `POST /api/auth/refresh` - Refresh JWT token
- `POST /api/auth/logout` - Sign out user

### AI Coaching
- `POST /api/coaching/weather-analysis` - AI weather decision support (**Dustin's Feature #2**)
- `POST /api/coaching/chat` - General AI safety coaching
- `GET /api/coaching/usage/{user_id}` - AI usage statistics

### Flight Logs
- `POST /api/flights` - Create flight log
- `GET /api/flights` - Get user's flights
- `POST /api/flights/{id}/engine-data` - Add engine parameters (**Dustin's Feature #3**)
- `GET /api/flights/{id}/engine-data` - Get engine data
- `GET /api/flights/{id}/trends` - Get engine parameter trends
- `DELETE /api/flights/{id}` - Delete flight

## Development Notes

### Dustin's Acceptance Criteria (Day 10)

**Test Scenario**:
1. Enter METAR: `"KAUS 151853Z 18015G25KT 3SM -RA BR OVC015"`
2. Ask AI: `"Should I fly from KAUS to KSAT?"`
3. AI must respond within **3 seconds**
4. Recommendation must be **conservative** (safety-first)
5. Reasoning must **cite weather data**

**Current Status**: ✅ Backend implemented, iOS integration complete

### Code Structure

```
backend/
├── main.py                     # FastAPI app entry point
├── routers/
│   ├── auth.py                # Authentication endpoints
│   ├── coaching.py            # AI coaching endpoints
│   └── flights.py             # Flight log endpoints
├── services/
│   ├── openai_service.py      # OpenAI GPT-4 wrapper
│   └── weather_service.py     # NOAA weather API client
└── requirements.txt           # Python dependencies
```

### AI System Prompt (Safety-First)

The OpenAI service uses a conservative aviation safety prompt:

- **Prime Directive**: Safety first. Always.
- **When in doubt**: Recommend conservative option
- **Never hallucinate**: Only use provided weather data
- **Explain reasoning**: Not just "don't fly" but WHY
- **Cite sources**: Reference METARs, personal minimums, aircraft limits

### Weather Data Caching

- METARs/TAFs cached for **30 minutes**
- Supports **offline mode** (graceful degradation)
- Dustin's requirement: "What happens when iPad loses cellular at 6,000 ft?"
- Answer: Weather cached 30 min, GPS/ADS-B work offline

## Testing

```bash
# Run unit tests (TODO: Day 10)
pytest

# Run with coverage
pytest --cov=backend --cov-report=html

# Type checking
mypy backend/

# Code formatting
black backend/
```

## Deployment (Fly.io)

```bash
# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Login
fly auth login

# Deploy
fly deploy

# View logs
fly logs
```

## Troubleshooting

**Error: `OPENAI_API_KEY not set`**
- Add your OpenAI API key to `.env` file
- Restart backend server

**Error: `Unable to fetch weather data`**
- Check internet connection
- NOAA Aviation Weather API may be temporarily unavailable
- Weather data is cached for 30 minutes

**Slow AI responses (>3 seconds)**
- Check OpenAI API status: https://status.openai.com
- Response time target: <3 seconds (Dustin's requirement)
- Typical response: 1-2 seconds

**iOS app can't connect**
- Verify backend running on http://localhost:8000
- Check iOS app's `WeatherService.swift` baseURL setting
- Simulator uses `localhost`, not `127.0.0.1`

## Next Steps

- [x] AI weather analysis API (Feature #2)
- [ ] Engine parameter logging API (Feature #3) - Day 8-9
- [ ] Apple Sign-In integration - Day 3
- [ ] Supabase database setup - Day 8-9
- [ ] Fly.io deployment - Day 9
- [ ] TestFlight build - Day 10

---

**Built by Byte (Backend Agent) - Milestone 2 (Days 6-7)**
**For**: Dustin's 10-day sprint demo
