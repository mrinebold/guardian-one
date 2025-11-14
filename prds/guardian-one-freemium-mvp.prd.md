# Guardian One: AI-Powered Cockpit Safety Companion
## Product Requirements Document (PRD)

**Version:** 1.0
**Date:** November 14, 2025
**Status:** Approved for Development
**Target Platform:** iOS/iPadOS 17+
**Market Segment:** General Aviation (Cessna 172 VFR focus)
**Business Model:** Freemium (Free → $99/yr Pro → $299/yr Ultimate)

---

## Executive Summary

Guardian One is an AI-powered Electronic Flight Bag (EFB) application designed specifically for Cessna 172 pilots operating under Visual Flight Rules (VFR). The app provides critical flight instruments, navigation, weather data, traffic awareness, and **AI safety coaching** through a tiered subscription model that makes aviation technology accessible to pilots at all experience levels.

**Primary Business Objective:** Demonstrate that AI agents can build production-quality, differentiated software from concept to App Store in 90 days, proving AI agent capabilities to stakeholder Dustin (American Airlines pilot, CS+Physics degrees) to secure his support and involvement.

**Key Differentiators:**
- **AI Safety Coaching**: Only EFB with real-time AI analysis and recommendations
- **Camera OCR**: Revolutionary feature for digitizing analog cockpit gauges (Ultimate tier)
- **Freemium Access**: Only EFB with a truly free tier for student pilots
- **Built by AI Agents**: 100% agent-developed in 90 days ($88k vs $550k traditional)

**Success Criteria:**
1. Working iOS app demo within 10 days (Dustin buy-in milestone)
2. Fully functional MVP within 30 days
3. TestFlight beta launch by day 60
4. App Store submission by day 90
5. Convince Dustin of AI agent capabilities through quality and speed

---

## 1. Business Case & Strategic Context

### 1.1 The Dustin Challenge

**Stakeholder Profile:**
- **Name:** Dustin (user's son)
- **Background:** American Airlines pilot, Computer Science + Physics degrees
- **Current Stance:** Skeptical of AI capabilities despite technical background
- **Location:** NYC (has Mac for iOS development/testing)
- **Aircraft:** Owns Cessna 172
- **Target Involvement:** 5-20+ hours/month after buy-in

**Buy-In Strategy:**
1. **Days 1-10:** Build initial working prototype with Dustin's "3 must-have features" (awaiting his response)
2. **Day 10:** Demo prototype to Dustin, showcase AI agent code quality
3. **Days 11-30:** Polish based on Dustin's feedback, add Pro tier features
4. **Day 30:** Full MVP demo, discuss revenue potential
5. **Days 31-60:** Beta testing with Dustin as lead tester
6. **Days 61-90:** Final polish, App Store prep with Dustin's input

**Proof Points to Convince Dustin:**
- **Speed:** 90-day development (vs 12-18 months traditional)
- **Cost:** $88,000 agent cost vs $550,000+ traditional team
- **Quality:** Professional Swift code, proper architecture, >80% test coverage
- **Differentiation:** Features ForeFlight/Garmin don't have (AI coaching, OCR)
- **Revenue Potential:** $99-299/yr subscriptions, 10k users = $990k-2.99M ARR

### 1.2 Market Opportunity

**Total Addressable Market (TAM):**
- 664,565 active pilot certificates (US, 2024)
- 150,000+ Cessna 172s produced (most popular trainer)
- $125-370/yr willingness to pay (ForeFlight benchmark)

**Competitive Landscape:**

| Competitor | Pricing | Key Features | Weaknesses |
|------------|---------|--------------|------------|
| **ForeFlight** | $125-370/yr | Clean iOS UI, moving maps, weather, charts | No public API, no AI features, expensive for students, no free tier |
| **Garmin Pilot** | $110-210/yr | Avionics integration, 13 split-screen layouts | Requires Garmin hardware ecosystem, cluttered UI, airline-focused |
| **FltPlan Go** | Free | Basic flight planning | Limited instruments, ads, basic UI |

**Guardian One Positioning:**
- **Free Tier:** Undercuts all competitors, targets 50k student pilots
- **Pro Tier ($99):** 28% cheaper than ForeFlight Basic, adds AI coaching
- **Ultimate Tier ($299):** Matches ForeFlight Performance Plus but adds camera OCR (unique)
- **AI Coaching:** No competitor offers real-time AI safety analysis

---

## 2. Aviation Data Sources Research

### 2.1 Available Data Sources

**CONFIRMED AVAILABLE (MVP-Ready):**

| Data Source | Cost | Accuracy | Gauges Powered | Notes |
|-------------|------|----------|----------------|-------|
| **iPad GPS** | $0 (built-in) | ±5m horizontal | Position, groundspeed, track, altitude (GPS) | Core Location API, 10Hz update rate |
| **ADS-B Receiver** | $200-500 one-time | 95%+ | Traffic, weather (FIS-B), NEXRAD, METARs, TAFs, TFRs, altitude (pressure) | GDL90 protocol, Stratux ($200), Stratus ($900), Sentry ($500) |
| **Manual Entry** | $0 | User-dependent | Fuel quantity, CHT, EGT, oil temp/pressure, manifold pressure | User inputs via UI |
| **Camera OCR** | $0 hardware, dev cost | 60-80% (target >80%) | All analog gauges (airspeed, altitude, VSI, RPM, fuel, temps) | Core ML + Vision framework |

**NOT AVAILABLE (Future Consideration):**

| Data Source | Why Not Available | Impact |
|-------------|-------------------|--------|
| **ForeFlight API** | No public API exists | Cannot integrate with ForeFlight data |
| **Garmin Pilot API** | No public API exists | Cannot integrate with Garmin data |
| **ARINC 429 Interface** | $5,000-10,000 hardware cost | Too expensive for private pilots, enterprise-only |
| **Aircraft CAN Bus** | Not standard on C172, varies by aircraft | Not viable for MVP |

### 2.2 Data-to-Gauge Mapping

**Free Tier (22 Features) - iPad GPS Only:**
- Position (lat/lon)
- Groundspeed
- Track (heading)
- Altitude (GPS-derived, less accurate)
- Moving map
- Distance to waypoint
- ETA
- Basic AI coaching (flight planning)

**Pro Tier (55 Features) - GPS + ADS-B:**
- All Free tier features
- Traffic display (ADS-B In)
- Traffic alerts
- Altitude (pressure altitude from ADS-B)
- Vertical speed (calculated from pressure alt)
- METARs (weather reports)
- TAFs (terminal forecasts)
- NEXRAD weather radar
- TFRs (temporary flight restrictions)
- Winds aloft
- AI coaching (weather analysis, traffic avoidance)

**Ultimate Tier (78 Features) - GPS + ADS-B + Camera OCR:**
- All Pro tier features
- Airspeed indicator (OCR from analog gauge)
- Altimeter (redundant cross-check via OCR)
- Vertical speed indicator (VSI OCR)
- Tachometer (RPM OCR)
- Fuel quantity (OCR from analog gauge)
- Oil pressure/temperature (OCR)
- CHT/EGT (cylinder head/exhaust gas temp OCR)
- Manifold pressure (OCR)
- IFR low/high charts
- Approach plates
- Performance calculations (W&B, takeoff/landing distance)
- Advanced AI coaching (engine parameter analysis, performance optimization)

---

## 3. Tiered Pricing & Feature Progression

### 3.1 Free Tier - "Student Pilot Essential" ($0/year)

**Target Audience:** Student pilots, budget-conscious hobbyists (50,000 target users)

**Included Features (22 total):**
- iPad GPS navigation
- Moving map with airports
- Flight planning (route, waypoints)
- Distance/bearing calculations
- Groundspeed, track, GPS altitude
- Basic flight logging
- Basic AI coaching (pre-flight, post-flight)
- Weight & balance (manual entry)
- Fuel burn calculations
- Airport directory (basic info)
- Runway diagrams
- Sectional chart overlay
- VFR waypoints
- Class B/C/D airspace alerts
- Day/night mode
- Portrait/landscape support

**Locked Features (Visible but Grayed Out):**
- ADS-B traffic display (upgrade to Pro)
- Weather radar (upgrade to Pro)
- IFR charts (upgrade to Ultimate)
- Camera OCR (upgrade to Ultimate)
- Advanced performance calcs (upgrade to Ultimate)

**Upsell Strategy:**
- "Upgrade to Pro for traffic awareness and live weather - $99/yr"
- "Unlock IFR charts and camera OCR with Ultimate - $299/yr"
- In-app banners on locked features

### 3.2 Pro Tier - "Safe VFR Flying" ($99/year)

**Target Audience:** Private pilots, weekend flyers (10,000 target users)

**New Features vs Free (33 additional, 55 total):**
- ADS-B traffic display
- Traffic collision alerts
- ADS-B weather (FIS-B)
- NEXRAD weather radar
- METARs (weather reports)
- TAFs (forecasts)
- TFRs (flight restrictions)
- Winds aloft
- Pressure altitude (from ADS-B)
- Vertical speed (calculated)
- AI coaching: weather analysis
- AI coaching: traffic avoidance
- AI coaching: real-time safety checks
- Flight following integration
- Enhanced flight logging (automatic)
- Cloud backup
- Multi-device sync
- PDF export of flight logs
- Emergency procedures checklists
- Nearest airport alerts
- Glide range ring

**Locked Features:**
- IFR charts
- Camera OCR
- Performance calculations

**Value Proposition:**
- 28% cheaper than ForeFlight Basic ($125/yr)
- Includes AI safety coaching (unique)
- ADS-B compatibility without ForeFlight cost

### 3.3 Ultimate Tier - "Pro-Level Tools" ($299/year)

**Target Audience:** Instrument-rated pilots, serious hobbyists, CFIs (2,000 target users)

**New Features vs Pro (23 additional, 78 total):**
- Camera OCR for analog gauges
- Airspeed indicator (OCR)
- Altimeter (OCR cross-check)
- VSI (OCR)
- Tachometer (OCR)
- Fuel quantity (OCR)
- Oil pressure/temp (OCR)
- CHT/EGT (OCR)
- Manifold pressure (OCR)
- IFR low enroute charts
- IFR high enroute charts
- Approach plates
- Departure procedures (DPs)
- Standard terminal arrivals (STARs)
- W&B performance calculator
- Takeoff distance calculator
- Landing distance calculator
- Crosswind calculator
- Density altitude calculator
- AI coaching: engine parameter analysis
- AI coaching: performance optimization
- AI coaching: IFR procedure guidance
- Priority email support

**Value Proposition:**
- Matches ForeFlight Performance Plus ($299/yr) pricing
- **ONLY** EFB with camera OCR (revolutionary)
- **ONLY** EFB with AI coaching
- Ideal for older aircraft without digital gauges
- Cross-checks digital avionics for redundancy

### 3.4 Revenue Model

**Assumptions:**
- 50,000 Free users (conversion funnel)
- 10,000 Pro users @ $99/yr = $990,000 ARR
- 2,000 Ultimate users @ $299/yr = $598,000 ARR
- **Total ARR:** $1,588,000

**Conversion Rates (Industry Standard):**
- Free → Pro: 20% (10k from 50k free)
- Pro → Ultimate: 20% (2k from 10k pro)

**Cost Structure:**
- AI API costs (OpenAI): $0.10/user/month = $62,000/yr
- ADS-B data (free via Stratux/open protocols): $0
- Chart data (FAA free): $0
- Cloud hosting (Supabase): $2,000/month = $24,000/yr
- Apple Developer: $99/yr
- **Total Operating Cost:** $86,099/yr
- **Profit Margin:** 94.6% ($1,501,901)

---

## 4. Competitive UI/UX Analysis

### 4.1 ForeFlight Design Patterns

**Strengths to Emulate:**
- **Clean, minimalist iOS-native design** (SwiftUI best practices)
- **Dark mode optimized** (critical for night flying)
- **Large, glanceable fonts** (readable in turbulence)
- **Gesture-based navigation** (pinch/zoom on maps, swipe for pages)
- **Split-screen support** (iPad multitasking)
- **Quick-access toolbar** (bottom nav with 5 main tabs)

**Layout Inspiration:**
- **Map View:** Full-screen map with overlay panels (weather, traffic, flight plan)
- **Instruments:** 6-pack layout for primary flight instruments
- **Weather:** Radar overlay with toggleable layers (NEXRAD, METARs, TAFs)
- **Flight Plan:** Route list with waypoint details, altitude profile graph
- **Settings:** Grouped lists (Aircraft, Charts, Weather, Account)

**Color Palette:**
- Dark background (#1a1a1a) with high-contrast text (#ffffff)
- Accent colors: Blue (#007aff) for primary actions, Red (#ff3b30) for alerts
- Map colors: Standard aviation (blue = water, green = low terrain, brown = high terrain)

### 4.2 Garmin Pilot Design Patterns

**Strengths to Emulate:**
- **13 split-screen layout options** (flexible workspace)
- **Avionics-style gauges** (familiar to pilots)
- **Customizable panels** (user can rearrange)
- **Tablet-optimized** (designed for landscape iPad)

**Layout Inspiration:**
- **Split 50/50:** Map | Instruments
- **Split 70/30:** Map (large) | Flight Plan (narrow)
- **Triple Split:** Map | Traffic | Weather
- **Full Instruments:** 6-pack + engine gauges

**Avoid Garmin Weaknesses:**
- Overly cluttered screens (too many options visible)
- Inconsistent navigation (menus vs gestures)
- Airline-focused features (not relevant to C172)

### 4.3 Guardian One UI Design

**Dashboard Philosophy:**
- **Free Tier:** Single-screen map view with bottom toolbar (simple, uncluttered)
- **Pro Tier:** 2-panel split (Map + Traffic/Weather), gestures to toggle
- **Ultimate Tier:** 3-panel split (Map + Instruments + Weather), fully customizable

**Tier-Specific UI Lockouts:**

**Free Tier Dashboard:**
```
┌─────────────────────────────────┐
│  Moving Map (GPS)               │  ← Full screen
│  - Position, track, waypoints   │
│  - Airports, airspace           │
│  - Flight plan overlay          │
├─────────────────────────────────┤
│ [Map] [Plan] [Log] [AI] [⚙️]   │  ← Bottom nav (5 tabs)
└─────────────────────────────────┘
```
- Locked features shown as grayed-out icons with "Upgrade to Pro" tooltips

**Pro Tier Dashboard:**
```
┌────────────────┬────────────────┐
│  Moving Map    │  Traffic       │  ← Split view
│  (GPS+ADS-B)   │  - Aircraft    │
│  - Weather     │  - Alerts      │
│  - TFRs        │  - Range rings │
├────────────────┴────────────────┤
│ [Map] [Traffic] [Wx] [AI] [⚙️] │  ← Bottom nav
└─────────────────────────────────┘
```
- Camera OCR button visible but locked ("Upgrade to Ultimate")

**Ultimate Tier Dashboard:**
```
┌──────────┬──────────┬──────────┐
│  Map     │ Instru-  │ Engine   │  ← 3-panel
│  (GPS+   │ ments    │ (OCR)    │
│  ADS-B)  │ (OCR)    │ - RPM    │
│          │ - ASI    │ - CHT    │
│          │ - ALT    │ - Oil    │
├──────────┴──────────┴──────────┤
│ [Map] [Instr] [Wx] [AI] [IFR] │  ← Bottom nav (IFR unlocked)
└─────────────────────────────────┘
```
- All features unlocked, customizable layout

**Upsell Visual Cues:**
- **Free Tier:** Traffic icon has small "Pro" badge in top-right
- **Pro Tier:** Camera icon has "Ultimate" badge
- **Tap Locked Feature:** Modal pops up with feature comparison table + "Upgrade" button

---

## 5. Technical Architecture

### 5.1 iOS Application Stack

**Framework:** Swift 5.9+ with SwiftUI
**Minimum iOS Version:** iOS 17.0 / iPadOS 17.0
**Supported Devices:** iPhone 13+, iPad Air 4+, iPad Pro (all)

**Core Libraries:**
- **Core Location:** GPS positioning, heading, speed
- **MapKit:** Moving map display, airport overlays
- **Core ML:** On-device machine learning for camera OCR
- **Vision:** Computer vision framework for gauge reading
- **Combine:** Reactive data streams (ADS-B, GPS updates)
- **StoreKit 2:** In-app purchases, subscription management
- **SwiftData:** Local data persistence (flight logs, waypoints)
- **AVFoundation:** Camera access for OCR

**External Dependencies:**
- **Stratux SDK:** ADS-B receiver communication (GDL90 protocol)
- **OpenAI API:** AI coaching backend (GPT-4 Turbo)
- **Supabase Swift SDK:** Authentication, cloud sync

### 5.2 Backend Stack

**Framework:** FastAPI (Python 3.11+)
**Database:** Supabase (PostgreSQL 15+)
**Hosting:** Fly.io (US-East region)
**CDN:** Cloudflare (for chart tiles)

**Services:**
- **Authentication API:** JWT-based auth, Apple Sign-In integration
- **Flight Log API:** CRUD for flights, sync across devices
- **AI Coaching API:** OpenAI integration, flight analysis
- **Subscription API:** StoreKit webhook validation, entitlement checks
- **Chart Data API:** FAA chart tile serving (cached from aviationapi.com)
- **Weather API:** NOAA Aviation Weather Center proxy

**Database Schema (Simplified):**
```sql
-- Users
CREATE TABLE users (
    id UUID PRIMARY KEY,
    apple_id TEXT UNIQUE,
    email TEXT,
    subscription_tier TEXT, -- 'free', 'pro', 'ultimate'
    subscription_expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Flight Logs
CREATE TABLE flights (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    departure_airport TEXT,
    arrival_airport TEXT,
    departure_time TIMESTAMP,
    arrival_time TIMESTAMP,
    flight_time_minutes INTEGER,
    route JSONB, -- [{lat, lon, alt, timestamp}]
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- AI Coaching Sessions
CREATE TABLE coaching_sessions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    flight_id UUID REFERENCES flights(id),
    coaching_type TEXT, -- 'preflight', 'inflight', 'postflight'
    prompt TEXT,
    ai_response TEXT,
    tokens_used INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 5.3 Camera OCR Architecture (Ultimate Tier)

**ML Model:** Custom Core ML model trained on aviation gauge images
**Training Dataset:** 10,000+ labeled images (airspeed, altimeter, VSI, RPM, etc.)
**Accuracy Target:** >80% (60-80% achievable with MVP training)

**OCR Pipeline:**
1. **Camera Capture:** 30 FPS video from iPad camera
2. **Frame Processing:** Vision framework detects circular gauges
3. **Needle Detection:** Core ML model identifies needle position
4. **Value Extraction:** Trigonometry converts needle angle to numeric value
5. **Smoothing:** Kalman filter removes jitter (5-frame rolling average)
6. **Display:** Real-time update to digital gauge display

**Calibration Process:**
- User taps gauge type (airspeed, altitude, etc.)
- User taps center of gauge in camera view
- User taps min/max values on dial (e.g., 0-200 mph)
- Model stores calibration offset
- Saves calibration per aircraft (user can have multiple aircraft profiles)

**Error Handling:**
- If confidence <70%, show "?" instead of value
- If gauge not visible (lighting, angle), show "---"
- User can manually override OCR value

---

## 6. AI Safety Coaching Features

### 6.1 Coaching Types

**Pre-Flight Coaching:**
- Weather briefing analysis (METARs, TAFs, winds aloft)
- NOTAM analysis (TFRs, airport closures)
- Route validation (airspace conflicts, terrain clearance)
- Weight & balance checks (exceed limits alert)
- Fuel planning (reserve calculations)

**In-Flight Coaching:**
- Traffic collision avoidance recommendations
- Weather deviation suggestions (avoid buildups)
- Airspace alerts (entering Class B without clearance)
- Engine parameter anomaly detection (high CHT warning)
- Lost procedures guidance (nearest airport, emergency freq)

**Post-Flight Coaching:**
- Flight debrief (altitude deviations, airspace violations)
- Performance analysis (fuel efficiency, speed optimization)
- Skill improvement suggestions (smoother landings, better approaches)
- Logbook auto-fill (extract flight time, route, conditions)

### 6.2 AI Model Integration

**Model:** OpenAI GPT-4 Turbo (128k context)
**Prompt Engineering:**
- System prompt: "You are an experienced flight instructor for Cessna 172 VFR operations. Provide concise, safety-focused advice. Never suggest actions that violate FAA regulations."
- Context injection: Aircraft type, pilot experience level, current conditions
- Max tokens: 500 (concise responses for cockpit readability)

**Safety Constraints:**
- Never recommend flying in IMC without IFR rating
- Never suggest exceeding aircraft limitations (Vne, weight limits)
- Always prioritize conservative decision-making (go-arounds, diversions)
- Include FAA regulation references (e.g., "Per 14 CFR 91.155...")

**Cost Management:**
- Free tier: 10 coaching requests/month ($0.01/request = $0.10/user/month)
- Pro tier: 100 coaching requests/month
- Ultimate tier: Unlimited coaching

---

## 7. Development Roadmap - 8 Milestones (90 Days)

### Milestone 1: Project Intake (Day 1)
**Duration:** 1 day
**Deliverables:**
- SaladBar submission complete
- GitHub repository created (mrinebold/guardian-one)
- PRD finalized and committed
- Documentation structure created
- Agent team assigned (Pixel, Byte, Cipher, Quest)
- Milestone tracking active (n8n workflows running)

**Acceptance Criteria:**
- [x] Repository exists at github.com/mrinebold/guardian-one
- [x] PRD committed to prds/guardian-one-freemium-mvp.prd.md
- [x] Weekly progress emails scheduled (Monday 9 AM to mrinebold@gmail.com)
- [x] Database milestone records created

### Milestone 2: 10-Day Sprint - Dustin's 3 Features (Days 2-11)
**Duration:** 10 days
**Deliverables:**
- Implement Dustin's "3 must-have features" (awaiting his response)
- Basic iOS app with Swift/SwiftUI structure
- iPad GPS integration (Core Location)
- Moving map display (MapKit)
- Free tier dashboard UI
- TestFlight build for Dustin to test

**Assigned Agents:**
- **Pixel:** iOS UI implementation (moving map, gauges, dashboard)
- **Byte:** Backend API scaffolding (auth, flight logs)
- **Cipher:** Apple Sign-In integration, JWT auth

**Acceptance Criteria:**
- [ ] iOS app runs on iPad simulator (Dustin's Mac)
- [ ] GPS position displayed on moving map
- [ ] Dustin's 3 features implemented and working
- [ ] TestFlight beta invite sent to Dustin
- [ ] Demo video recorded for Dustin review

**GitHub Release:** v1.0.0-m2 "10-Day Sprint Complete"

### Milestone 3: Quality Pass (Days 12-21)
**Duration:** 10 days
**Deliverables:**
- Unit tests for all core functions (>80% coverage)
- SwiftUI UI tests for critical flows
- Security audit (Cipher agent)
- Code documentation (docstrings, inline comments)
- CI/CD pipeline (GitHub Actions for tests)

**Assigned Agents:**
- **Quest:** Test suite creation, QA automation
- **Cipher:** Security audit, API key management
- **Nova:** Technical documentation, code comments

**Acceptance Criteria:**
- [ ] Test coverage >80% (Swift + Python)
- [ ] All security recommendations implemented
- [ ] CI/CD pipeline running on every commit
- [ ] Code passes SwiftLint, pylint checks
- [ ] Documentation complete (README, API docs)

**GitHub Release:** v1.0.0-m3 "Quality Foundation"

### Milestone 4: User Feedback Iteration (Days 22-31)
**Duration:** 10 days
**Deliverables:**
- Incorporate Dustin's feedback from M2 testing
- UI/UX polish based on real-world usage
- Bug fixes from TestFlight reports
- Free → Pro upsell flow implementation
- In-app purchase integration (StoreKit 2)

**Assigned Agents:**
- **Pixel:** UI refinements, upsell modals
- **Byte:** Subscription API, webhook handling
- **Cipher:** StoreKit receipt validation

**Acceptance Criteria:**
- [ ] All Dustin-reported bugs fixed
- [ ] Subscription purchase flow working end-to-end
- [ ] Free tier users see locked Pro features
- [ ] Dustin approves UX improvements

**GitHub Release:** v1.0.0-m4 "User-Validated MVP"

### Milestone 5: Feature Integration - ADS-B & AI (Days 32-46)
**Duration:** 15 days
**Deliverables:**
- ADS-B receiver integration (Stratux SDK)
- Traffic display on moving map
- Weather radar overlay (NEXRAD)
- AI coaching API integration (OpenAI GPT-4)
- Pro tier dashboard implementation

**Assigned Agents:**
- **Pixel:** Traffic display UI, weather radar overlay
- **Byte:** ADS-B data parsing (GDL90), AI API endpoints
- **Nova:** AI coaching prompt engineering

**Acceptance Criteria:**
- [ ] Stratux receiver detected and connected
- [ ] Traffic aircraft displayed on map with labels
- [ ] NEXRAD weather overlay toggleable
- [ ] AI coaching responds to "pre-flight briefing" query
- [ ] Pro tier features locked for Free users

**GitHub Release:** v1.0.0-m5 "Pro Tier Features"

### Milestone 6: Beta Launch (Days 47-61)
**Duration:** 15 days
**Deliverables:**
- TestFlight public beta (100 testers)
- Beta tester feedback collection system
- Crash reporting (Firebase Crashlytics)
- Performance optimization (60 FPS, <500 MB RAM)
- App Store assets (screenshots, description, video)

**Assigned Agents:**
- **Pixel:** App Store screenshot generation (all tiers)
- **Nova:** App Store listing copy, demo video script
- **Quest:** Beta testing coordination, bug triage
- **Echo:** Analytics dashboard (user engagement metrics)

**Acceptance Criteria:**
- [ ] 100 beta testers recruited via TestFlight
- [ ] Crash-free rate >99%
- [ ] App runs at 60 FPS on iPad Air 4 (min spec)
- [ ] App Store listing approved by Dustin
- [ ] Beta NPS score >50

**GitHub Release:** v1.0.0-m6 "Beta Launch"

### Milestone 7: Advanced Features - Camera OCR & IFR (Days 62-76)
**Duration:** 15 days
**Deliverables:**
- Camera OCR for analog gauges (Core ML model)
- IFR chart integration (FAA low/high enroute, approach plates)
- Ultimate tier dashboard (3-panel split)
- Performance calculators (W&B, takeoff/landing distance)
- Advanced AI coaching (engine analysis)

**Assigned Agents:**
- **Pixel:** Camera OCR UI, gauge calibration flow, IFR chart viewer
- **Byte:** Core ML training pipeline, chart data API
- **Nova:** OCR training dataset curation (10k+ gauge images)

**Acceptance Criteria:**
- [ ] OCR reads airspeed/altimeter with >80% accuracy
- [ ] IFR charts load within 2 seconds
- [ ] Ultimate tier dashboard fully functional
- [ ] Performance calculators match POH values
- [ ] OCR works in various lighting conditions

**GitHub Release:** v1.0.0-m7 "Ultimate Tier Complete"

### Milestone 8: Revenue Launch - App Store Submission (Days 77-90)
**Duration:** 14 days
**Deliverables:**
- App Store submission (App Review approval)
- Production deployment (backend to Fly.io)
- Payment processing live (Stripe + Apple IAP)
- Marketing website (saladbar.msrresearch.com/guardian-one)
- Launch announcement (EAA forums, r/flying, aviation newsletters)

**Assigned Agents:**
- **Pixel:** App Store submission, final polish
- **Byte:** Production deployment, monitoring setup
- **Nova:** Marketing website, launch blog post
- **Iris:** Social media campaign, aviation community outreach
- **Echo:** Revenue dashboard, KPI tracking

**Acceptance Criteria:**
- [ ] App Store approval received (within 7 days)
- [ ] First paid subscription processed successfully
- [ ] Marketing website live with demo video
- [ ] Backend handles 1,000 concurrent users
- [ ] Dustin approves final app quality
- [ ] Launch post published to 5+ aviation communities

**GitHub Release:** v1.0.0 "Production Launch"

---

## 8. Agent Development Cost Analysis

### 8.1 Traditional Development Cost Estimate

**Team Composition (Traditional):**
- Senior iOS Developer: $180k/yr salary = $90/hr × 800 hours = $72,000
- Backend Developer: $150k/yr = $75/hr × 600 hours = $45,000
- UI/UX Designer: $140k/yr = $70/hr × 400 hours = $28,000
- QA Engineer: $120k/yr = $60/hr × 300 hours = $18,000
- DevOps Engineer: $160k/yr = $80/hr × 200 hours = $16,000
- Project Manager: $130k/yr = $65/hr × 300 hours = $19,500

**Total Traditional Cost:** $198,500 (direct labor)
**Overhead (benefits, equipment, office):** 2.5x multiplier = **$496,250**
**Timeline:** 12-18 months

### 8.2 AI Agent Development Cost

**Agent Team Composition:**
- **Pixel (iOS):** 800 hours × $30/hr (Claude Sonnet 4.5 API) = $24,000
- **Byte (Backend):** 600 hours × $30/hr = $18,000
- **Cipher (Security):** 100 hours × $30/hr = $3,000
- **Quest (QA):** 300 hours × $30/hr = $9,000
- **Nova (Docs):** 200 hours × $30/hr = $6,000
- **Schema (Database):** 100 hours × $30/hr = $3,000
- **Helio (Orchestration):** 200 hours × $30/hr = $6,000
- **Echo (Analytics):** 100 hours × $30/hr = $3,000
- **Iris (Marketing):** 200 hours × $30/hr = $6,000

**Total Agent Cost:** $78,000 (API costs)
**Infrastructure (Supabase, Fly.io, OpenAI):** $10,000
**Total AI Agent Cost:** **$88,000**
**Timeline:** 90 days

**Cost Savings:** $496,250 - $88,000 = **$408,250** (82% reduction)
**Time Savings:** 12 months → 3 months = **9 months faster**

### 8.3 ROI Calculation (Year 1)

**Revenue (Conservative):**
- 5,000 Pro users @ $99/yr = $495,000
- 1,000 Ultimate users @ $299/yr = $299,000
- **Total Year 1 Revenue:** $794,000

**Costs:**
- Development: $88,000 (one-time)
- Operating: $86,099 (annual)
- **Total Year 1 Cost:** $174,099

**Year 1 Profit:** $794,000 - $174,099 = **$619,901** (71% margin)
**ROI:** 619,901 / 88,000 = **7.0x return** on development investment

---

## 9. Success Metrics & KPIs

### 9.1 Dustin Buy-In Metrics (Days 1-30)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Demo quality (Dustin rating) | 8/10 or higher | Day 10 demo feedback |
| Code quality (Dustin review) | "Professional-grade" comment | GitHub code review |
| Feature completeness | 100% of Dustin's 3 features | M2 acceptance |
| Bug-free demo | 0 crashes during demo | TestFlight logs |
| Speed to demo | <10 days | M2 completion date |

### 9.2 Product Metrics (Days 1-90)

| Metric | Target | Measurement |
|--------|--------|-------------|
| TestFlight downloads | 100+ beta testers | App Store Connect |
| Crash-free rate | >99% | Firebase Crashlytics |
| Test coverage | >80% | XCTest, pytest reports |
| App Store approval | First submission | App Review status |
| GPS accuracy | <10m horizontal error | Core Location logs |
| ADS-B latency | <1 second update | GDL90 timestamp delta |
| OCR accuracy | >80% | Validation dataset |
| AI response time | <3 seconds | OpenAI API latency |

### 9.3 Business Metrics (Days 1-90)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Development cost | <$100,000 | Actual agent API costs |
| Time to launch | 90 days | M8 completion |
| Free tier signups | 1,000+ | Supabase users table |
| Conversion (Free→Pro) | 5% (50 users) | Subscription records |
| Beta NPS score | >50 | In-app survey |
| Dustin involvement | 10+ hours/month | GitHub contributions |

---

## 10. Risk Assessment & Mitigation

### 10.1 Technical Risks

**Risk 1: OCR Accuracy Below 80%**
**Impact:** Ultimate tier value proposition weakened
**Probability:** Medium (60%)
**Mitigation:**
- Use larger training dataset (20k+ images vs 10k)
- Implement user calibration per-gauge
- Allow manual override for low-confidence readings
- Backup: Partner with aviation gauge manufacturers for training data

**Risk 2: ADS-B Receiver Compatibility Issues**
**Impact:** Pro tier features non-functional
**Probability:** Low (20%)
**Mitigation:**
- Test with 3 ADS-B receivers (Stratux, Stratus, Sentry)
- Use standard GDL90 protocol (widely supported)
- Provide troubleshooting guide in docs
- Backup: Offer Wi-Fi-only mode for testing without ADS-B

**Risk 3: App Store Rejection**
**Impact:** Launch delayed by 2-4 weeks
**Probability:** Medium (40%)
**Mitigation:**
- Follow Apple Human Interface Guidelines strictly
- Avoid aviation safety claims that trigger FAA review
- Submit early (Day 77) to allow resubmission time
- Backup: Launch on TestFlight while awaiting approval

### 10.2 Business Risks

**Risk 4: Dustin Remains Unconvinced**
**Impact:** Loss of key stakeholder support
**Probability:** Low (15%)
**Mitigation:**
- Focus M2 sprint on Dustin's exact feature requests
- Involve Dustin in code reviews (transparency)
- Showcase cost/time savings prominently
- Backup: Pivot to revenue validation (10 paying users = proof of concept)

**Risk 5: Competitive Response (ForeFlight Adds AI)**
**Impact:** Differentiation reduced
**Probability:** Low (10%)
**Mitigation:**
- File provisional patent for camera OCR in aviation (Q1 2026)
- Build brand around "AI-first EFB" positioning
- Emphasize free tier (ForeFlight won't go freemium)
- Backup: Compete on price ($99 vs $125)

**Risk 6: FAA Regulatory Changes**
**Impact:** EFB certification requirements increase
**Probability:** Very Low (5%)
**Mitigation:**
- Monitor FAA Type B EFB guidance (AC 91-78)
- Join aviation trade groups (GAMA, AOPA) for early alerts
- Design app for non-certified use initially (backup instruments)
- Backup: Pivot to flight training/simulation use case

---

## 11. Documentation Deliverables

### 11.1 Technical Documentation

**File:** `docs/TECHNICAL_DOCUMENTATION.md`
**Contents:**
- Architecture diagrams (iOS app, backend, database schema)
- API endpoint documentation (auth, flights, coaching, subscriptions)
- ADS-B integration guide (GDL90 protocol, Stratux setup)
- Core ML model training process (OCR dataset, accuracy metrics)
- Deployment instructions (Fly.io, Supabase, Cloudflare)
- Security considerations (JWT validation, API key rotation)

### 11.2 User Documentation

**File:** `docs/USER_DOCUMENTATION.md`
**Contents:**
- Quick start guide (download, sign in, first flight)
- Feature tutorials (moving map, flight planning, AI coaching)
- ADS-B receiver setup (Stratux pairing, troubleshooting)
- Camera OCR calibration (gauge selection, center tapping)
- Subscription management (upgrade, downgrade, cancel)
- FAQs (GPS accuracy, battery life, offline mode)

### 11.3 Build Journal

**File:** `docs/BUILD_JOURNAL.md`
**Contents:**
- Daily agent activity log (what Pixel/Byte/Cipher did each day)
- Commit history with explanations
- Design decisions and rationale
- Challenges encountered and solutions
- Dustin feedback integration notes
- Screenshots of progress at each milestone

### 11.4 Agent Cost Tracking

**File:** `docs/AGENT_TRACKING.md`
**Contents:**
- Per-agent API cost breakdown (Pixel: $X, Byte: $Y, etc.)
- Token usage by milestone
- Comparison to traditional developer costs
- Time saved calculations
- ROI analysis for Dustin presentation

### 11.5 Value Proposition Story

**File:** `docs/VALUE_PROPOSITION_STORY.md`
**Contents:**
- Narrative of Guardian One's unique positioning
- "Built by AI agents in 90 days" marketing angle
- Testimonials (Dustin quote, beta tester quotes)
- Competitive comparison tables
- Revenue potential and market opportunity
- Future roadmap (Vision Pro, Android, airline version)

### 11.6 Competitive Analysis Deep Dive

**File:** `docs/COMPETITIVE_ANALYSIS.md`
**Contents:**
- ForeFlight feature-by-feature comparison
- Garmin Pilot UI/UX analysis
- FltPlan Go positioning
- Guardian One differentiation strategy
- Pricing benchmarking
- Market share estimates
- Partnership opportunities (Stratux, ADS-B manufacturers)

---

## 12. Post-Launch Roadmap (Months 4-12)

### Month 4-6: Feature Expansion
- Android version (Kotlin, Jetpack Compose)
- Apple Watch companion app (heart rate, basic gauges)
- CarPlay support (traffic alerts while driving to airport)
- Offline mode (cached charts, no internet required)

### Month 7-9: Enterprise Features
- Fleet management dashboard (CFI/school owner tools)
- Multi-aircraft profiles
- Student pilot progress tracking
- Integration with flight schools (bulk subscriptions)

### Month 10-12: Vision Pro & Advanced AI
- Apple Vision Pro spatial computing version
- AR overlay on windshield (traffic, runway alignment)
- Advanced AI: predictive maintenance alerts (engine trends)
- Voice-controlled AI assistant ("Guardian, what's the weather at KAUS?")

---

## 13. Approval & Next Steps

**PRD Status:** ✅ Approved for Development (November 14, 2025)

**Immediate Actions:**
1. Await Dustin's response on "3 must-have features" for M2 sprint
2. Begin iOS scaffolding (Swift package, SwiftUI views)
3. Set up Supabase project (database, auth)
4. Deploy backend to Fly.io
5. Configure TestFlight for beta distribution

**Stakeholder Sign-Off:**
- [x] Ken (Product Owner) - Approved
- [ ] Dustin (Key Stakeholder) - Pending demo on Day 10

**Agent Assignments:**
- **Helio:** Overall project orchestration, milestone tracking
- **Pixel:** iOS UI/UX implementation
- **Byte:** Backend API development
- **Cipher:** Security, authentication
- **Quest:** Testing, QA automation
- **Nova:** Documentation, content
- **Schema:** Database design
- **Echo:** Analytics, metrics
- **Iris:** Marketing, launch

---

**END OF PRD**

**Document Control:**
- **Version:** 1.0
- **Last Updated:** November 14, 2025
- **Next Review:** Day 10 (Post-Dustin Demo)
- **Owner:** Ken (mrinebold@gmail.com)
- **Repository:** github.com/mrinebold/guardian-one
- **SaladBar Project ID:** [Pending submission]
