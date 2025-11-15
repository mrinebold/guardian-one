# Day 10 Testing Checklist - Dustin's Demo

**Date:** November 24, 2025
**Tester:** Dustin (American Airlines Pilot, ATP/CFI, 3,200 hours)
**Location:** NYC (Mac with Xcode)
**Objective:** Validate all 3 must-have features before proceeding to Milestone 3

---

## Pre-Flight Checklist (Setup)

### ☐ 1. Clone Repository
```bash
cd ~/Desktop  # or preferred location
git clone https://github.com/mrinebold/guardian-one
cd guardian-one
```

**Expected:** Repository cloned successfully

### ☐ 2. Backend Setup
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

**Expected:** All dependencies install without errors (2-3 minutes)

### ☐ 3. Configure OpenAI API Key
```bash
cp .env.example .env
nano .env  # or use your preferred editor
```

Add your OpenAI API key:
```
OPENAI_API_KEY=sk-...
```

**Expected:** `.env` file created with API key

### ☐ 4. Start Backend Server
```bash
python main.py
```

**Expected Output:**
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     ✅ OpenAI API key validated
INFO:     ✅ Backend ready
```

**Verification:** Open browser to http://localhost:8000/docs - should see Swagger UI

### ☐ 5. Open iOS Project (New Terminal Tab)
```bash
cd ~/Desktop/guardian-one/ios
open GuardianOne.xcodeproj
```

**Expected:** Xcode opens project

### ☐ 6. Select Simulator
- In Xcode: Product → Destination → iPad Air (6th generation)
- If not installed: Xcode → Settings → Platforms → Download iPad Air simulator

**Expected:** iPad Air simulator selected

### ☐ 7. Build & Run
- Press ⌘R (Command + R) or click Play button
- Wait for build to complete (30-60 seconds first time)

**Expected:**
- Build succeeds
- Simulator launches
- App displays "Guardian One" sign-in screen

---

## Feature Test #1: GPS Tracking (Partial)

**Dustin's Requirement:** GPS accuracy ±100 ft
**Note:** Simulator provides synthetic GPS, not real-world accuracy test

### ☐ 1.1 Sign In
- Tap "Sign in with Apple" button
- Simulator automatically signs in (mock authentication)

**Expected:** App navigates to Map tab

### ☐ 1.2 GPS Position Display
- Observe Map tab
- Check for:
  - Blue dot (current position)
  - Coordinates displayed (lat/lon)
  - Altitude in feet MSL
  - Speed in knots

**Expected:**
- GPS Active (green text)
- Coordinates displayed: `37.xxxx, -122.xxxx` (San Francisco area - simulator default)
- Altitude: `~0-100 ft MSL`
- Speed: `0.0 kts` (stationary)

**✅ PASS** if GPS data displays without errors
**❌ FAIL** if crash, "GPS Acquiring..." persists, or no data

---

## Feature Test #2: ADS-B Traffic Awareness

**Dustin's Requirement:** Traffic within 2 NM, ±1,000 ft triggers audio alert

**Note:** Requires Stratux receiver hardware. For Day 10 demo, verify code implementation only.

### ☐ 2.1 Code Review (Optional)
- File: `ios/Sources/Services/ADSBService.swift`
- Lines 49-114: Connection logic
- Lines 140-254: GDL90 parsing and traffic alerts

**Expected:** Code present and functional

### ☐ 2.2 Hardware Test (If Stratux Available)
- Connect iPad to Stratux Wi-Fi (192.168.10.1)
- Re-run app
- Observe traffic aircraft on map

**Expected:** Traffic displays with altitude indicators

**✅ PASS** if code review shows implementation complete
**⏸️ DEFER** hardware test to real-world flight testing

---

## Feature Test #3: AI Weather Decision Support

**Dustin's Requirement:** AI responds <3 seconds, conservative reasoning, explains WHY

### ☐ 3.1 Navigate to AI Coach
- Tap "AI" tab (brain icon)
- Ensure "Weather Analysis" is selected (not "General Chat")

**Expected:** Weather analysis form displays

### ☐ 3.2 Enter Test Data
**Scenario:** Marginal VFR conditions (should recommend NO-GO)

Enter:
- **From:** KAUS
- **To:** KSAT
- **Fuel Remaining:** 30.5 (gallons)
- **Your Question:** Should I fly this route today?

**Expected:** All fields accept input

### ☐ 3.3 Analyze Weather
- Tap "Analyze Weather" button
- Start timer on phone/watch

**Expected:**
- Button shows "Analyzing..." with spinner
- Backend fetches current METAR for KAUS and KSAT
- OpenAI GPT-4 analyzes conditions

### ☐ 3.4 Verify Response Time
- Stop timer when response appears

**✅ PASS** if response time <3 seconds
**❌ FAIL** if response time >3 seconds

### ☐ 3.5 Verify Recommendation
**Expected Response:**
- **Recommendation Badge:** GO, NO-GO, WAIT, or DIVERT
  - Color-coded (green=GO, red=NO-GO, orange=WAIT, yellow=DIVERT)
- **Weather Summary:** Plain English description of current conditions
- **AI Reasoning:** Detailed explanation citing:
  - Specific METAR data (ceilings, visibility, winds)
  - VFR minimums or pilot limitations
  - Safety margins
- **Hazards:** List of identified hazards (e.g., "Low ceilings", "Gusty winds")
- **Alternatives:** Suggested actions (e.g., "Wait 2 hours", "File IFR")

**Example Expected Response:**
```
Recommendation: NO-GO
Confidence: High

Weather Summary:
KAUS reports overcast ceilings at 1,500 ft with 3 SM visibility
in light rain and mist. Winds 180° at 15 gusting 25 knots.

AI Reasoning:
I recommend NO-GO for the following reasons:
1. Ceilings (OVC015 = 1,500 ft AGL) are below VFR minimums
   for Class E airspace (3,000 ft AGL + 1,000 ft cloud clearance)
2. Visibility (3 SM) is at VFR minimum but marginal with rain
3. Gusty winds (15G25KT) may exceed crosswind component limits
   for C172 (maximum demonstrated: 15 knots)
4. IMC conditions with potential for worsening weather

Hazards:
• Low ceilings below VFR minimums
• Gusty crosswind component
• Reduced visibility in precipitation
• Risk of inadvertent IMC entry

Alternatives:
• Wait 2-3 hours for frontal passage
• File IFR flight plan with CFII
• Delay until METAR shows VFR conditions
```

**✅ PASS** if:
- Response <3 seconds
- Recommendation is conservative (NO-GO or WAIT for marginal conditions)
- Reasoning cites specific weather data
- Explains WHY, not just "don't fly"

**❌ FAIL** if:
- Response >3 seconds
- AI says "GO" for marginal VFR
- Reasoning is vague or doesn't cite data
- No alternatives provided

### ☐ 3.6 Test General Chat
- Switch to "General Chat" tab
- Enter question: "What's the best descent rate for passenger comfort?"
- Tap send

**Expected:** AI responds within 3 seconds with helpful answer

---

## Feature Test #4: Engine Parameter Trend Analysis

**Dustin's Requirement:** Manual entry, trend graphs, alert for out-of-range values

### ☐ 4.1 Navigate to Logbook
- Tap "Log" tab (book icon)

**Expected:**
- Empty state: "No Flights Yet" with "Create Flight" button
- Or: List of previously created flights

### ☐ 4.2 Create New Flight
- Tap "+" button (top right)
- Enter:
  - **Departure Airport:** KAUS
  - **Arrival Airport:** KSAT
  - **Aircraft Type:** C172N
  - **Notes:** Post-maintenance test flight
- Tap "Create Flight Log"

**Expected:**
- Alert: "✅ Flight log created"
- Flight appears in list

### ☐ 4.3 Navigate to Flight Details
- Tap the flight you just created

**Expected:** Flight details screen with:
- Departure/Arrival airports
- Aircraft type
- Date/time
- Notes
- "Engine Parameters" section with:
  - "Log Engine Data" button
  - "View Trends" navigation link

### ☐ 4.4 Log Engine Data
- Tap "Log Engine Data"

**Expected:** Engine parameter entry form with 6 fields:
- Oil Pressure (PSI)
- Oil Temperature (°F)
- Cylinder Head Temp (CHT) (°F)
- Exhaust Gas Temp (EGT) (°F)
- Engine RPM
- Fuel Quantity (gallons)

### ☐ 4.5 Enter Parameters (From Dustin's C172N)
**Scenario:** Post-flight readings from your actual aircraft

Enter realistic values:
- **Oil Pressure:** 54 PSI (normal: 30-60)
- **Oil Temperature:** 203°F (normal: 100-245)
- **CHT:** 398°F (normal: 200-500, ideal <400°F)
- **EGT:** 1378°F (normal: 1200-1600)
- **RPM:** 2410 (normal: 2000-2700)
- **Fuel Quantity:** 36.5 gallons (C172: 43 usable)

**Expected:**
- All fields accept numeric input
- Normal range guidance displayed below each field

### ☐ 4.6 Save Engine Data
- Tap "Save Engine Data"

**Expected:**
- Alert: "✅ Engine data saved successfully"
- Form dismisses
- Return to Flight Details screen

### ☐ 4.7 View Trend Graphs
- Tap "View Trends"

**Expected:** Trend graph screen with 6 charts:

1. **Oil Pressure**
   - Line graph showing last 10 flights
   - Trend badge: "Stable" (green)
   - Average: ~54.5 PSI
   - No alert

2. **Oil Temperature**
   - Line graph showing gradual increase
   - Trend badge: "↗ Increasing" (orange)
   - Average: ~191.2°F
   - Alert: "⚠️ Oil temperature trending up - monitor closely (normal: 100-245°F)"

3. **Cylinder Head Temp (CHT)**
   - Line graph showing steep increase
   - Trend badge: "↗ Increasing" (orange/red)
   - Average: ~371.6°F
   - Alert: "⚠️ CHT increasing rapidly - possible cylinder issue (normal: 200-500°F, ideal: <400°F)"

4. **Exhaust Gas Temp (EGT)**
   - Line graph relatively flat
   - Trend badge: "Stable" (green)
   - Average: ~1367.3°F
   - No alert

5. **Engine RPM**
   - Line graph relatively flat
   - Trend badge: "Stable" (green)
   - Average: ~2407.5 RPM
   - No alert

6. **Fuel Quantity**
   - Line graph showing gradual decrease
   - Trend badge: "↘ Decreasing" (blue)
   - Average: ~39.3 gallons
   - Alert: "📊 Normal consumption - refuel before next long flight"

**Expected Chart Features:**
- Color-coded parameter icons (oil=blue, CHT=red, EGT=orange, etc.)
- Last 10 flights labeled F1-F10 on X-axis
- Dashed average line across chart
- Alert badges for concerning trends

**✅ PASS** if:
- All 6 trend graphs display
- CHT shows "increasing" trend with alert
- Oil temp shows "increasing" trend with alert
- Charts are readable and color-coded correctly

**❌ FAIL** if:
- Graphs don't load (error message)
- No alerts displayed for concerning trends
- Charts display incorrectly or crash

---

## Crash Testing (30-Minute Session)

**Dustin's Requirement:** Zero crashes during 30-minute test session

### ☐ 5.1 Continuous Usage Test
Spend 30 minutes using the app:
- Navigate between all 5 tabs
- Create multiple flights (3-5)
- Log engine data multiple times
- Run weather analysis 3-4 times
- Use general chat feature
- Pull to refresh flight list
- Delete flights (swipe left)

**Expected:** No crashes, no UI freezes, no data loss

### ☐ 5.2 Monitor for Issues
Watch for:
- **Crashes:** App closes unexpectedly
- **Hangs:** UI freezes or becomes unresponsive
- **Memory leaks:** App slows down over time
- **Data loss:** Created flights disappear
- **UI glitches:** Elements misaligned or overlapping

**✅ PASS** if zero crashes in 30 minutes
**❌ FAIL** if any crash occurs

---

## Final Verdict

### Summary Checklist

**Feature Completeness:**
- ☐ GPS tracking displays position (Feature #1 - Partial)
- ☐ ADS-B code implemented (Feature #1 - Deferred to hardware test)
- ☐ AI weather responds <3 seconds (Feature #2)
- ☐ AI reasoning is conservative and explanatory (Feature #2)
- ☐ Engine parameters save successfully (Feature #3)
- ☐ Trend graphs display with alerts (Feature #3)

**Stability:**
- ☐ Zero crashes during 30-minute test
- ☐ No UI freezes or hangs
- ☐ No data loss

**User Experience:**
- ☐ App is intuitive to navigate
- ☐ Forms are easy to fill out
- ☐ AI responses are helpful and actionable
- ☐ Trend graphs are clear and informative

### Dustin's Overall Rating

**1-5 Scale:**
- **1 = Unusable** - Crashes, missing features, poor UX
- **2 = Needs Major Work** - Some features work, many bugs
- **3 = Acceptable MVP** - Core features work, minor polish needed
- **4 = Production Quality** - Solid app, ready for beta testing
- **5 = Exceeds Expectations** - Polished, differentiated, ready for launch

**Your Rating:** _____ / 5

**Key Strengths:**
1. ___________________________________
2. ___________________________________
3. ___________________________________

**Critical Issues (Must Fix for M3):**
1. ___________________________________
2. ___________________________________
3. ___________________________________

**Nice-to-Have Improvements:**
1. ___________________________________
2. ___________________________________
3. ___________________________________

---

## Troubleshooting

### Backend won't start
**Error:** `ModuleNotFoundError: No module named 'fastapi'`
**Fix:**
```bash
source venv/bin/activate
pip install -r requirements.txt
```

### OpenAI API error
**Error:** `OPENAI_API_KEY not set in environment`
**Fix:**
```bash
cd backend
nano .env
# Add: OPENAI_API_KEY=sk-...
```

### iOS build fails
**Error:** `Command PhaseScriptExecution failed`
**Fix:**
1. Xcode → Product → Clean Build Folder (⌘⇧K)
2. Close Xcode
3. Delete `ios/DerivedData`
4. Reopen project and rebuild

### Simulator GPS not working
**Fix:**
1. Simulator → Features → Location → Apple (or Custom Location)
2. Restart simulator

### AI weather returns "Unable to fetch weather data"
**Possible Causes:**
- No internet connection
- NOAA API temporarily down
- Weather data unavailable for airport

**Fix:** Try different airports (KJFK, KLAX, KORD)

---

## Next Steps After Testing

### If PASS (Rating 3-5):
1. Proceed to Milestone 3 (Quality Pass)
2. Implement feedback items
3. >80% test coverage (XCTest + pytest)
4. Security audit
5. CI/CD pipeline

### If FAIL (Rating 1-2):
1. Document all critical bugs
2. Prioritize fixes
3. Re-test after fixes
4. Delay Milestone 3 start

---

**Testing Complete!**
Share feedback with Ken: mrinebold@gmail.com
GitHub Issues: https://github.com/mrinebold/guardian-one/issues
