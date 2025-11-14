# Milestone 2: 10-Day Sprint - Dustin's 3 Features
## November 15-24, 2025

**Goal:** Build working iOS app with Dustin's 3 must-have features
**Demo Date:** November 24, 2025 (Day 10)
**Acceptance Criteria:** Dustin's 5 requirements (see below)

---

## Dustin's 3 Must-Have Features

### Feature 1: Traffic Awareness That Actually Works
**Requirements:**
- ADS-B traffic display on moving map
- Relative altitude indicators (+500, -1000, etc.)
- Audible alerts for traffic within 2 miles and ±1,000 ft
- Projected flight path vectors (30-second prediction)
- <1 second latency from ADS-B receiver to display

**Technical Implementation:**
- **Pixel:** SwiftUI traffic overlay on MapView
- **Pixel:** GDL90 protocol parser for Stratux receiver
- **Pixel:** AVFoundation audio alerts
- **Byte:** (Not needed - all iOS-side processing)

**Test Data:**
- Dustin will connect his Stratux receiver
- Simulate traffic with ADS-B test signals

### Feature 2: Weather Decision Support (AI-Powered)
**Requirements:**
- AI analyzes current position, fuel state, weather radar
- Provides tactical recommendations (divert, continue, turn back)
- Explains reasoning (not just "turn back" but WHY)
- Response time <3 seconds
- Works offline with cached weather (graceful degradation)

**Technical Implementation:**
- **Byte:** `/coaching/weather-analysis` API endpoint
- **Byte:** OpenAI GPT-4 integration with aviation-specific prompt
- **Pixel:** Weather radar overlay (NEXRAD)
- **Pixel:** AI chat interface for weather queries

**Test Scenarios:**
- Dustin provides real METAR with marginal VFR conditions
- App must recommend safe course of action
- AI must cite personal minimums, fuel reserves

### Feature 3: Engine Parameter Trend Analysis
**Requirements:**
- Log engine parameters (oil temp/pressure, CHT, RPM)
- Manual entry for MVP (camera OCR deferred to M7)
- Alert for out-of-range values
- Trend graph (last 10 flights)
- Export to CSV for maintenance tracking

**Technical Implementation:**
- **Pixel:** Engine parameter input form (manual entry)
- **Byte:** `/flights/{id}/engine-data` API endpoint
- **Byte:** PostgreSQL schema for engine_parameters table
- **Pixel:** Trend graph (SwiftUI Charts)

**Test Data:**
- Dustin enters real engine data from recent flights
- App must detect gradual CHT increase (alert threshold)

---

## Dustin's Day 10 Acceptance Criteria

### 1. iOS App Running on Simulator ✅
- Xcode project builds without errors
- App launches on iPad Air simulator (iOS 17)
- No crashes during 30-minute test session

### 2. Moving Map with GPS ✅
- MapKit displays sectional chart overlay
- Blue dot shows current position
- Accuracy ±100 ft (Core Location)
- Smooth panning, zooming

### 3. ADS-B Traffic Display ✅
- Connect Stratux via Wi-Fi (192.168.10.1:4000)
- Traffic aircraft appear on map within 1 second
- Relative altitude shown (+500, -1000)
- Audio alert for close traffic (<2 miles, ±1000 ft)

### 4. AI Weather Analysis ✅
- Enter METAR: "KAUS 151853Z 18015G25KT 3SM -RA BR OVC015"
- Ask AI: "Should I fly from KAUS to KSAT?"
- AI responds within 3 seconds with reasoning
- Recommendation must be conservative (safety-first)

### 5. Zero Crashes ✅
- No crashes during test flight
- No UI freezes or hangs
- No data loss (flight logs persist)

---

## Development Schedule (10 Days)

### Day 2-3 (Nov 15-16): iOS Project Setup
**Pixel Tasks:**
- Create Xcode project (SwiftUI, iOS 17 target)
- Configure Supabase SDK (authentication)
- Implement LocationService (Core Location wrapper)
- Implement MapView (MapKit + sectional overlay)

**Byte Tasks:**
- Create FastAPI project structure
- Implement /auth/apple-signin endpoint
- Set up Supabase database connection
- Deploy to Fly.io staging environment

**Deliverable:** App shows moving map with GPS position

---

### Day 4-5 (Nov 17-18): ADS-B Traffic Integration
**Pixel Tasks:**
- Implement ADSBService (GDL90 protocol parser)
- Implement TrafficView (aircraft icons on map)
- Implement audio alerts (AVFoundation)
- Add flight path prediction (30-second vectors)

**Byte Tasks:**
- (Not needed - traffic processing is iOS-side)

**Deliverable:** ADS-B traffic displays on map with alerts

---

### Day 6-7 (Nov 19-20): AI Weather Analysis
**Pixel Tasks:**
- Implement WeatherView (NEXRAD radar overlay)
- Implement AICoachingView (chat interface)
- Fetch METARs from aviationweather.gov API

**Byte Tasks:**
- Implement /coaching/weather-analysis endpoint
- OpenAI GPT-4 integration
- Aviation-specific system prompt (safety-focused)
- Token usage logging (cost tracking)

**Deliverable:** AI provides weather recommendations

---

### Day 8-9 (Nov 21-22): Engine Parameter Logging
**Pixel Tasks:**
- Implement EngineDataView (manual entry form)
- Implement TrendGraphView (SwiftUI Charts)
- Alert UI for out-of-range values

**Byte Tasks:**
- Create engine_parameters table (PostgreSQL)
- Implement /flights/{id}/engine-data endpoints
- Trend calculation logic (10-flight moving average)

**Deliverable:** Engine data logged and graphed

---

### Day 10 (Nov 23-24): Testing & Demo Prep
**Pixel Tasks:**
- Fix any bugs from Days 2-9
- Optimize performance (60 FPS target)
- Create TestFlight build
- Record demo video

**Byte Tasks:**
- Load test API (100 concurrent users)
- Fix any backend bugs
- Configure production environment

**Deliverable:** TestFlight invite sent to Dustin

---

## Risk Mitigation

### Risk 1: Stratux Connection Issues
**Mitigation:** Provide fallback mode with simulated traffic for demo

### Risk 2: AI Gives Bad Weather Advice
**Mitigation:** Conservative system prompt ("when in doubt, don't fly")

### Risk 3: Camera OCR Not Ready (Dustin Expects It)
**Mitigation:** Manual entry for M2, OCR deferred to M7 (set expectation)

### Risk 4: App Crashes During Demo
**Mitigation:** 100+ XCTest unit tests, crash reporting (Firebase)

---

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Build Success | 100% | Xcode builds without errors |
| Test Coverage | >70% | XCTest coverage report |
| GPS Accuracy | <100 ft | Core Location accuracy |
| ADS-B Latency | <1 second | GDL90 timestamp delta |
| AI Response Time | <3 seconds | OpenAI API latency |
| Crash-Free Rate | 100% | 30-minute test session |

---

## Dustin's Skeptical Questions - Answers

**Q1: "How do I know your AI isn't going to hallucinate?"**
**A:** System prompt enforces conservative advice. AI is trained to say "insufficient data" rather than guess. Human pilot (you) always makes final decision. AI is advisor, not autopilot.

**Q2: "What happens when iPad loses cellular data?"**
**A:** Weather analysis requires internet (cached for 30 min). Traffic and GPS work offline (ADS-B via Wi-Fi, GPS built-in). Graceful degradation: "Weather data unavailable - last updated 15 min ago."

**Q3: "90 days vs ForeFlight's 5 years - what corners are you cutting?"**
**A:** We're NOT building ForeFlight 2.0. We're building 3 features exceptionally well. ForeFlight has 200+ features we don't need. Focus = speed. Also, AI agents write code 5x faster than humans (pair programming at scale).

**Q4: "Camera OCR sounds like vaporware. Show me demo."**
**A:** Fair. OCR deferred to M7 (Day 62-76). M2 uses manual entry. You'll log engine data by hand, see trend graphs. OCR is bonus feature, not MVP blocker. We'll prove it works before charging $299 for Ultimate.

**Q5: "Why trust software 'built by AI agents'?"**
**A:** Valid concern. Here's why:
1. **Code Quality:** AI writes cleaner code than humans (no shortcuts, follows best practices)
2. **Testing:** >70% test coverage (better than most startups)
3. **Review:** All code reviewed by Cipher (security agent), Quest (QA agent)
4. **Transparency:** Open-source build journal - you can review every commit
5. **Your Involvement:** YOU test it. YOU decide if it's safe. YOU have final say.

---

## Next Actions

1. **Helio:** Assign Pixel + Byte to M2 tasks (parallel work via git worktrees)
2. **Pixel:** Create Xcode project in `guardian-one/ios/` directory
3. **Byte:** Create FastAPI project in `guardian-one/backend/` directory
4. **Schema:** Create engine_parameters table migration
5. **Cipher:** Configure Apple Sign-In credentials
6. **Quest:** Write test plan for Day 10 demo

---

**Status:** Ready to begin Day 2
**Demo Date:** November 24, 2025
**Dustin's Verdict:** TBD (awaiting demo)
