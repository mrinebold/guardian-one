# Guardian One - User Guide

**Version:** 1.0
**Last Updated:** November 14, 2025
**Audience:** Pilots, Students, Flight Instructors

---

## Welcome to Guardian One

Guardian One is your AI-powered safety companion for VFR flying in Cessna 172 aircraft. This guide will help you get started and make the most of Guardian One's features across all subscription tiers.

---

## Quick Start (5 Minutes)

### 1. Download & Install
- Open App Store on iPad
- Search "Guardian One"
- Tap "Get" → Install
- Open Guardian One

### 2. Sign In
- Tap "Sign in with Apple"
- Follow on-screen prompts
- Grant location permissions when asked

### 3. Your First Flight
- **Map Tab:** See your current position on the moving map
- **Plan Tab:** Create a route from KAUS → KSAT
- **AI Tab:** Ask "What's the weather at KSAT?"
- **Settings:** Select aircraft type (Cessna 172)

---

## Features by Subscription Tier

### Free Tier - "Student Pilot Essential"

**Navigation:**
- Moving map with your GPS position
- Airports, airspace boundaries (Class B/C/D)
- VFR sectional chart overlay
- Flight planning (create routes, waypoints)

**AI Coaching (10/month):**
- Pre-flight briefings
- Post-flight debriefs
- General aviation Q&A

**Limitations:**
- No ADS-B traffic/weather
- No camera OCR
- No IFR charts

### Pro Tier - "Safe VFR Flying" ($99/year)

**Everything in Free, plus:**
- ADS-B traffic display (see nearby aircraft)
- Live weather radar (NEXRAD)
- METARs, TAFs, winds aloft
- Traffic collision alerts
- AI coaching (100/month)
- Cloud sync across devices

**How to Upgrade:**
- Settings → Subscription → "Upgrade to Pro"
- Apple Pay checkout ($99/year)

### Ultimate Tier - "Pro-Level Tools" ($299/year)

**Everything in Pro, plus:**
- Camera OCR for analog gauges
- IFR charts (low/high enroute, approach plates)
- Performance calculators (W&B, takeoff/landing)
- Advanced AI coaching (unlimited)
- Priority email support

**How to Upgrade:**
- Settings → Subscription → "Upgrade to Ultimate"

---

## Using the Moving Map

### Map Controls
- **Pinch to Zoom:** Two fingers in/out
- **Pan:** Drag with one finger
- **Rotate:** Two-finger twist
- **Center on Aircraft:** Tap compass icon (top-right)

### Map Layers (Toggle in Map Settings)
- Sectional charts (VFR)
- Airspace boundaries
- Airports (tap for details)
- Weather radar (Pro/Ultimate only)
- Traffic aircraft (Pro/Ultimate only)

### Flight Planning
1. Tap "Plan" tab
2. Tap "New Flight Plan"
3. Enter departure (e.g., KAUS)
4. Enter destination (e.g., KSAT)
5. Add waypoints (optional)
6. Tap "Start Flight"

**Map will display:**
- Magenta line (your route)
- Distance to next waypoint
- Estimated time enroute (ETE)
- Groundspeed, track

---

## ADS-B Integration (Pro/Ultimate Only)

### Supported Receivers
- **Stratux:** $200 (recommended for beginners)
- **Stratus:** $900 (premium, weather + AHRS)
- **Sentry:** $500 (mid-range)

### Connecting Stratux
1. Power on Stratux receiver
2. iPad Settings → Wi-Fi → Connect to "Stratux" network
3. Return to Guardian One
4. Map tab → Top bar should show "ADS-B Connected" (green)

**If not connecting:**
- Settings → ADS-B → Manual IP: `192.168.10.1:4000`
- Restart Stratux receiver
- Check Stratux battery

### Understanding Traffic Display

**Traffic Symbols:**
- 🔷 Blue diamond: Aircraft 1,000+ ft below you
- 🔶 Orange diamond: Aircraft within ±1,000 ft
- 🔴 Red diamond: Aircraft on collision course (<30 seconds)

**Traffic Info Panel:**
- Tap aircraft icon → See callsign, altitude, speed, distance
- Relative altitude (e.g., "+500" = 500 ft above you)

**Collision Alerts:**
- Red banner at top: "TRAFFIC ALERT - 2 o'clock, 3 miles, converging"
- Audio alert (if enabled in settings)
- Recommended action from AI coaching

---

## Weather Features (Pro/Ultimate Only)

### NEXRAD Radar
- Map → Weather icon (toggle on/off)
- Color scale: Green (light rain) → Red (heavy precip) → Magenta (extreme)
- Tap cell → See intensity, tops, movement

### METARs & TAFs
- Tap airport icon → "Weather" tab
- METAR (current conditions)
- TAF (forecast for next 24 hours)
- Age of report (e.g., "15 minutes ago")

### Winds Aloft
- Map → Winds icon
- See wind barbs at various altitudes
- Tap altitude (e.g., "6,000 ft") → See speed/direction

---

## Camera OCR (Ultimate Tier Only)

### Setting Up Camera OCR

**Requirements:**
- iPad with rear camera (not front)
- Yoke mount for iPad (camera facing instruments)
- Good lighting (cockpit dome light or daylight)

**First-Time Calibration:**
1. Tap "Instruments" tab
2. Tap "Camera OCR" → "Calibrate"
3. Select gauge type (Airspeed, Altimeter, VSI, RPM, etc.)
4. Point camera at gauge (center in green circle)
5. Tap center of gauge dial
6. Tap minimum value on gauge (e.g., "0 mph")
7. Tap maximum value (e.g., "200 mph")
8. Tap "Save Calibration"
9. Repeat for other gauges

**Using OCR in Flight:**
- Instruments tab shows digital readings from analog gauges
- Green checkmark = high confidence (>80%)
- Yellow "?" = low confidence (60-80%)
- Red "---" = gauge not visible

**Manual Override:**
- If OCR reads incorrectly, tap gauge → Enter value manually

### Best Practices
- Mount iPad where camera has clear view of panel
- Avoid reflections (tilt iPad if needed)
- Re-calibrate if you fly a different aircraft
- Use as backup to primary instruments (not replacement)

---

## AI Safety Coaching

### Pre-Flight Briefing
**Ask:**
- "Brief me for a flight from KAUS to KSAT"
- "What's the weather along my route?"
- "Check NOTAMs for KAUS"

**AI will provide:**
- Weather summary (ceilings, visibility, winds)
- NOTAM highlights (TFRs, runway closures)
- Route recommendations (avoid restricted airspace)

### In-Flight Coaching
**Ask:**
- "Traffic 2 o'clock, what should I do?"
- "Should I divert due to weather?"
- "What's the nearest airport?"

**AI will provide:**
- Traffic avoidance vectors
- Weather deviation routes
- Emergency procedures

### Post-Flight Debrief
**Ask:**
- "Review my flight performance"
- "Did I violate any airspace?"

**AI will provide:**
- Altitude deviations from planned
- Airspace violations (if any)
- Fuel efficiency analysis

### Usage Limits
- Free: 10 questions/month
- Pro: 100 questions/month
- Ultimate: Unlimited

**Tip:** Phrase questions clearly (e.g., "What's the crosswind limit for C172?" instead of "Can I land?")

---

## Performance Calculators (Ultimate Tier Only)

### Weight & Balance
1. Settings → Aircraft → Enter Empty Weight, CG
2. Pre-Flight tab → "W&B Calculator"
3. Enter: Pilot weight, passenger, fuel, baggage
4. Tap "Calculate"
5. See: Total weight, CG position, within limits (yes/no)

### Takeoff Distance
1. Pre-Flight tab → "Takeoff Distance"
2. Enter: Elevation, temperature, wind, runway condition
3. See: Ground roll, total distance to clear 50 ft obstacle

### Landing Distance
1. Pre-Flight tab → "Landing Distance"
2. Enter: Elevation, temperature, wind
3. See: Ground roll, total distance from 50 ft

---

## Flight Logging

### Automatic Logging (Pro/Ultimate)
- Detects takeoff (groundspeed >60 mph)
- Records route every 10 seconds
- Detects landing (groundspeed <30 mph for 1 minute)
- Saves to "Log" tab automatically

### Manual Logging (Free Tier)
- Log tab → "New Flight"
- Enter: Departure, arrival, flight time, Hobbs start/end
- Tap "Save"

### Exporting Logs
- Log tab → Tap flight → "Export PDF"
- Share via Email/AirDrop for logbook

---

## Settings & Preferences

### Aircraft Profile
- Settings → Aircraft
- Enter: Tail number, make/model, fuel capacity, empty weight
- Save multiple aircraft (e.g., flight school rentals)

### Units
- Settings → Units
- Choose: Statute miles or nautical miles
- Altitude: Feet or meters
- Speed: Knots, mph, or km/h

### Subscription
- Settings → Subscription
- View: Current tier, expiration date
- Manage: Upgrade, downgrade, cancel

---

## Troubleshooting

### GPS Not Working
- Settings → Privacy → Location Services → Guardian One → "While Using"
- Ensure iPad has GPS (Wi-Fi + Cellular models only)
- Step outside for clear sky view

### ADS-B Not Connecting
- Check Stratux power (LED lights on)
- iPad Wi-Fi connected to "Stratux" network
- Settings → ADS-B → Test Connection

### Camera OCR Inaccurate
- Re-calibrate gauge
- Improve lighting (turn on dome light)
- Clean camera lens
- Check camera view (gauge fully visible)

### AI Coaching Slow
- Check internet connection (requires data/Wi-Fi)
- Busy times may have 5-10 second delay
- Ultimate tier gets priority processing

---

## Safety Disclaimer

**Guardian One is NOT certified avionics.**

- Use as supplementary tool only
- **ALWAYS** cross-reference with certified instruments
- **NEVER** rely solely on GPS altitude for terrain clearance
- Camera OCR is experimental (not for primary reference)
- AI coaching is advisory only (pilot-in-command makes final decisions)

**Per 14 CFR 91.205:** Required equipment for VFR flight is NOT replaced by Guardian One.

---

## Support

**Email:** support@guardian.one
**Response Time:**
- Free tier: 5 business days
- Pro tier: 2 business days
- Ultimate tier: 24 hours

**Community Forum:** forum.guardian.one

---

**Safe Flying!**

_Guardian One Team_
