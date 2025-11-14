# Guardian One - Technical Documentation

**Version:** 1.0
**Last Updated:** November 14, 2025
**Audience:** Developers, Technical Stakeholders

---

## Table of Contents

1. [System Architecture](#system-architecture)
2. [iOS Application](#ios-application)
3. [Backend Services](#backend-services)
4. [Database Schema](#database-schema)
5. [External Integrations](#external-integrations)
6. [Deployment](#deployment)
7. [Security](#security)
8. [Monitoring & Analytics](#monitoring--analytics)

---

## 1. System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────┐
│          iOS App (Swift/SwiftUI)             │
│  ┌─────────┬─────────┬─────────┬──────────┐ │
│  │ Core    │ MapKit  │ Core ML │ StoreKit │ │
│  │ Location│         │ (OCR)   │ (IAP)    │ │
│  └─────────┴─────────┴─────────┴──────────┘ │
└───────────────┬─────────────────────────────┘
                │ HTTPS/JSON
┌───────────────┴─────────────────────────────┐
│       FastAPI Backend (Python 3.11+)        │
│  ┌─────────┬─────────┬─────────┬──────────┐ │
│  │ Auth    │ Flights │ AI      │ Charts   │ │
│  │ API     │ API     │ Coach   │ API      │ │
│  └─────────┴─────────┴─────────┴──────────┘ │
└───────────────┬─────────────────────────────┘
                │ PostgreSQL Protocol
┌───────────────┴─────────────────────────────┐
│         Supabase (PostgreSQL 15+)           │
│  - User authentication                      │
│  - Flight log storage                       │
│  - Subscription management                  │
│  - Real-time sync                           │
└─────────────────────────────────────────────┘

External Data Sources:
- ADS-B Receiver (Stratux) → GDL90 protocol → iOS app
- OpenAI API → GPT-4 Turbo → Backend
- FAA Aviation Weather → NOAA API → Backend → iOS
```

### Technology Stack

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| iOS Framework | Swift | 5.9+ | Application logic |
| UI Framework | SwiftUI | iOS 17+ | User interface |
| Backend Framework | FastAPI | 0.104+ | REST API |
| Database | PostgreSQL (Supabase) | 15+ | Data persistence |
| Authentication | JWT + Apple Sign-In | - | User auth |
| Mapping | MapKit | iOS 17+ | Moving map display |
| Computer Vision | Core ML + Vision | iOS 17+ | Camera OCR |
| Real-time Data | Combine | iOS 17+ | ADS-B streams |
| Subscriptions | StoreKit 2 | iOS 17+ | In-app purchases |
| AI | OpenAI GPT-4 Turbo | Latest | Coaching |

---

## 2. iOS Application

### Project Structure

```
Guardian One/
├── GuardianOne.xcodeproj
├── GuardianOne/
│   ├── App/
│   │   ├── GuardianOneApp.swift      # App entry point
│   │   └── AppState.swift             # Global state management
│   ├── Views/
│   │   ├── MapView.swift              # Moving map (Free/Pro/Ultimate)
│   │   ├── InstrumentsView.swift     # Gauge displays (Pro/Ultimate)
│   │   ├── TrafficView.swift         # ADS-B traffic (Pro/Ultimate)
│   │   ├── WeatherView.swift         # NEXRAD/METARs (Pro/Ultimate)
│   │   ├── OCRView.swift              # Camera OCR (Ultimate only)
│   │   ├── AICoachingView.swift      # Chat interface (Free/Pro/Ultimate)
│   │   └── SettingsView.swift        # App settings
│   ├── Services/
│   │   ├── LocationService.swift      # GPS tracking
│   │   ├── ADSBService.swift          # ADS-B receiver communication
│   │   ├── OCRService.swift           # Camera gauge reading
│   │   ├── APIClient.swift            # Backend communication
│   │   ├── SubscriptionService.swift # StoreKit management
│   │   └── AICoachingService.swift   # OpenAI integration
│   ├── Models/
│   │   ├── Flight.swift               # Flight log data model
│   │   ├── Aircraft.swift             # Traffic aircraft model
│   │   ├── Weather.swift              # Weather data model
│   │   └── Subscription.swift        # User subscription model
│   ├── Utilities/
│   │   ├── GDL90Parser.swift          # ADS-B protocol decoder
│   │   ├── CoordinateHelper.swift    # Aviation coordinate math
│   │   └── UnitConverter.swift       # Knots/MPH/FPM conversions
│   └── Resources/
│       ├── Assets.xcassets           # Images, colors
│       └── Info.plist                # App configuration
└── GuardianOneTests/
    ├── LocationServiceTests.swift
    ├── ADSBServiceTests.swift
    └── OCRServiceTests.swift
```

### Core Location Integration

**GPS Accuracy:** Horizontal accuracy <10m required for navigation

```swift
import CoreLocation

class LocationService: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var heading: CLHeading?
    @Published var speed: CLLocationSpeed = 0.0 // m/s

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // meters
        locationManager.headingFilter = 5 // degrees
        locationManager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                        didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        speed = location.speed // m/s
    }

    func locationManager(_ manager: CLLocationManager,
                        didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }
}
```

### ADS-B Integration (GDL90 Protocol)

**Supported Receivers:** Stratux ($200), Stratus ($900), Sentry ($500)

```swift
import Network

class ADSBService: ObservableObject {
    @Published var aircraft: [TrafficAircraft] = []
    @Published var weather: WeatherData?

    private var connection: NWConnection?
    private let gdl90Port: NWEndpoint.Port = 4000 // Standard GDL90 UDP port

    func connect(to receiverIP: String) {
        let host = NWEndpoint.Host(receiverIP)
        let port = NWEndpoint.Port(rawValue: gdl90Port.rawValue)!
        connection = NWConnection(host: host, port: port, using: .udp)

        connection?.stateUpdateHandler = { [weak self] state in
            if state == .ready {
                self?.receiveGDL90Data()
            }
        }
        connection?.start(queue: .global())
    }

    private func receiveGDL90Data() {
        connection?.receiveMessage { [weak self] data, _, _, error in
            guard let data = data else { return }
            self?.parseGDL90Message(data)
            self?.receiveGDL90Data() // Continue receiving
        }
    }

    private func parseGDL90Message(_ data: Data) {
        guard data.count > 2 else { return }
        let messageID = data[0]

        switch messageID {
        case 0x00: // Heartbeat
            break
        case 0x14: // Traffic report
            parseTrafficReport(data)
        case 0x07, 0x08: // Weather (FIS-B)
            parseWeatherReport(data)
        default:
            break
        }
    }
}
```

### Camera OCR Implementation

**Target Accuracy:** >80% for airspeed, altimeter, VSI, RPM

```swift
import Vision
import CoreML

class OCRService: ObservableObject {
    @Published var airspeed: Int?
    @Published var altitude: Int?
    @Published var rpm: Int?

    private let model: VNCoreMLModel

    init() {
        // Load custom Core ML model (trained on aviation gauges)
        let mlModel = try! GuardianOneGaugeDetector(configuration: .init())
        model = try! VNCoreMLModel(for: mlModel.model)
    }

    func analyzeFrame(_ pixelBuffer: CVPixelBuffer) {
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation]
            else { return }

            self?.processGaugeDetections(results)
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }

    private func processGaugeDetections(_ detections: [VNRecognizedObjectObservation]) {
        for detection in detections {
            guard detection.confidence > 0.7 else { continue } // Minimum 70% confidence

            let label = detection.labels.first?.identifier ?? ""
            let needleAngle = extractNeedleAngle(from: detection)

            switch label {
            case "airspeed":
                airspeed = convertAngleToAirspeed(needleAngle)
            case "altimeter":
                altitude = convertAngleToAltitude(needleAngle)
            case "tachometer":
                rpm = convertAngleToRPM(needleAngle)
            default:
                break
            }
        }
    }
}
```

---

## 3. Backend Services

### API Endpoints

**Base URL:** `https://api.guardian.one/v1`

#### Authentication

```
POST /auth/apple-signin
Request: { "identityToken": "<apple_jwt>", "authorizationCode": "<code>" }
Response: { "access_token": "<jwt>", "user_id": "<uuid>", "subscription_tier": "free" }
```

#### Flight Logs

```
GET /flights
Headers: Authorization: Bearer <jwt>
Response: [{ "id": "<uuid>", "departure": "KAUS", "arrival": "KSAT", ... }]

POST /flights
Request: { "departure": "KAUS", "arrival": "KSAT", "route": [...] }
Response: { "id": "<uuid>", "created_at": "2025-11-14T10:00:00Z" }
```

#### AI Coaching

```
POST /coaching/ask
Request: { "question": "Should I fly with 15 kt crosswinds in a C172?" }
Response: { "answer": "15 kts is within C172 limits (15 kt max demonstrated)...", "tokens_used": 150 }
```

#### Subscriptions

```
GET /subscriptions/status
Response: { "tier": "pro", "expires_at": "2026-11-14T00:00:00Z", "auto_renew": true }

POST /subscriptions/verify-receipt
Request: { "receipt_data": "<base64_receipt>" }
Response: { "valid": true, "tier": "pro", "expires_at": "..." }
```

---

## 4. Database Schema

### Users Table

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apple_id TEXT UNIQUE NOT NULL,
    email TEXT,
    subscription_tier TEXT NOT NULL DEFAULT 'free', -- 'free', 'pro', 'ultimate'
    subscription_expires_at TIMESTAMP WITH TIME ZONE,
    subscription_auto_renew BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_users_apple_id ON users(apple_id);
```

### Flights Table

```sql
CREATE TABLE flights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    departure_airport TEXT, -- ICAO code (e.g., KAUS)
    arrival_airport TEXT,
    departure_time TIMESTAMP WITH TIME ZONE,
    arrival_time TIMESTAMP WITH TIME ZONE,
    flight_time_minutes INTEGER,
    route JSONB, -- [{ lat, lon, alt, timestamp, speed }]
    aircraft_type TEXT DEFAULT 'C172',
    notes TEXT,
    hobbs_start DECIMAL(6,1),
    hobbs_end DECIMAL(6,1),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_flights_user_id ON flights(user_id);
CREATE INDEX idx_flights_departure_time ON flights(departure_time DESC);
```

### AI Coaching Sessions Table

```sql
CREATE TABLE coaching_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    flight_id UUID REFERENCES flights(id) ON DELETE SET NULL,
    coaching_type TEXT NOT NULL, -- 'preflight', 'inflight', 'postflight'
    user_prompt TEXT NOT NULL,
    ai_response TEXT NOT NULL,
    tokens_used INTEGER,
    model_version TEXT DEFAULT 'gpt-4-turbo',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_coaching_user_id ON coaching_sessions(user_id);
```

---

## 5. External Integrations

### OpenAI API

**Model:** GPT-4 Turbo (128k context)
**Endpoint:** `https://api.openai.com/v1/chat/completions`

**System Prompt:**
```
You are an experienced Certified Flight Instructor (CFI) specializing in Cessna 172
VFR operations. Provide concise, safety-focused advice for general aviation pilots.
Always prioritize conservative decision-making and cite FAA regulations when applicable
(e.g., "Per 14 CFR 91.155..."). Never suggest actions that violate regulations or
exceed aircraft limitations. Keep responses under 300 words for cockpit readability.
```

**Usage Limits by Tier:**
- Free: 10 requests/month
- Pro: 100 requests/month
- Ultimate: Unlimited

### FAA Aviation Weather Center

**Base URL:** `https://aviationweather.gov/api/data`

**METARs:**
```
GET /metar?ids=KAUS,KSAT&format=json
Response: [{ "icaoId": "KAUS", "reportTime": "...", "rawOb": "KAUS 141853Z..." }]
```

**TAFs:**
```
GET /taf?ids=KAUS&format=json
```

### FAA Chart Data

**Source:** FAA Digital Products (free)
**Tile Server:** Cloudflare CDN (cached)

**Tile Format:** `https://cdn.guardian.one/charts/{type}/{zoom}/{x}/{y}.png`
- `type`: sectional, terminal, low_enroute, high_enroute, approach
- Zoom levels: 0-12 (standard map tiles)

---

## 6. Deployment

### iOS App Distribution

**Development:**
- Xcode 15+ required
- Sign in with Apple Developer account (Team ID: `<team_id>`)
- Build configuration: Debug
- Simulator testing: iPad Air 4 (minimum spec)

**TestFlight:**
- Upload via Xcode → Archive → Distribute
- Beta group: "Guardian One Beta Testers" (100 max)
- Build expiry: 90 days
- Crash reporting: Enabled

**App Store:**
- Bundle ID: `com.msrresearch.guardianone`
- Version: 1.0.0
- Minimum iOS: 17.0
- Supported devices: iPad Air 4+, iPad Pro (all)
- Categories: Navigation, Utilities

### Backend Deployment (Fly.io)

**Configuration:** `fly.toml`
```toml
app = "guardian-one-api"
primary_region = "dfw" # Dallas (central US)

[build]
  image = "python:3.11-slim"

[[services]]
  internal_port = 8000
  protocol = "tcp"

  [[services.ports]]
    port = 443
    handlers = ["tls", "http"]

  [[services.tcp_checks]]
    interval = 10000
    timeout = 2000
```

**Deploy Command:**
```bash
fly deploy --app guardian-one-api
```

**Environment Variables:**
```bash
fly secrets set OPENAI_API_KEY="sk-..."
fly secrets set SUPABASE_URL="https://..."
fly secrets set SUPABASE_SERVICE_KEY="eyJ..."
fly secrets set JWT_SECRET="..."
```

### Database (Supabase)

**Project:** `guardian-one-prod`
**Region:** US East (N. Virginia)
**Plan:** Pro ($25/month)

**Migrations:**
- Run via Supabase CLI: `supabase db push`
- Version control: Git-tracked in `supabase/migrations/`

---

## 7. Security

### Authentication Flow

1. User taps "Sign in with Apple"
2. iOS requests identity token from Apple
3. App sends token to backend `/auth/apple-signin`
4. Backend validates token with Apple (public key verification)
5. Backend creates/retrieves user, generates JWT (24h expiry)
6. App stores JWT in iOS Keychain
7. All API requests include `Authorization: Bearer <jwt>` header

### API Security

- **HTTPS Only:** TLS 1.3 required
- **JWT Validation:** HS256 signature with 256-bit secret
- **Rate Limiting:** 100 requests/minute per user
- **Subscription Checks:** Middleware validates tier access
- **SQL Injection Prevention:** Parameterized queries (SQLAlchemy ORM)

### Data Privacy

- **Location Data:** Never leaves device (processed locally)
- **Flight Logs:** Encrypted at rest (Supabase AES-256)
- **AI Coaching:** OpenAI does NOT train on user data (enterprise tier)
- **PII Handling:** Email only for account recovery, never shared

---

## 8. Monitoring & Analytics

### Crash Reporting

**Tool:** Firebase Crashlytics
**Metrics:**
- Crash-free rate (target >99%)
- Crash by iOS version
- Crash by device model

### Performance Monitoring

**Tool:** Firebase Performance
**Metrics:**
- App startup time (target <2 seconds)
- API response time (target <500ms p95)
- Screen rendering time (target 60 FPS)

### Business Analytics

**Tool:** Supabase (custom dashboards)
**Metrics:**
- Daily active users (DAU)
- Monthly active users (MAU)
- Free → Pro conversion rate (target 20%)
- Pro → Ultimate conversion rate (target 20%)
- Churn rate (target <5% monthly)

---

**Document Owner:** Byte (Backend Agent)
**Last Updated:** November 14, 2025
**Status:** Living document (updated with each milestone)
