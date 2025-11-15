# Guardian One - Quick Start Guide for Dustin

**Day 10 Demo - November 24, 2025**

Hey Dustin! This guide will get you up and running in 5 minutes. Full testing checklist is in `docs/DAY_10_TESTING_CHECKLIST.md`.

---

## What You Need

- ✅ Mac with Xcode installed
- ✅ OpenAI API key (for AI weather analysis)
- ✅ 30 minutes for full testing

---

## Step 1: Clone Repository (30 seconds)

```bash
cd ~/Desktop  # or wherever you want it
git clone https://github.com/mrinebold/guardian-one
cd guardian-one
```

---

## Step 2: Start Backend (2 minutes)

```bash
cd backend
./start.sh
```

The script will:
1. Create Python virtual environment
2. Install dependencies
3. Prompt you for OpenAI API key
4. Start the server

**Get OpenAI API Key:**
- Go to: https://platform.openai.com/api-keys
- Sign in (or create account)
- Click "Create new secret key"
- Copy key starting with `sk-...`
- Paste into `.env` file when prompted

**Expected Output:**
```
✅ Backend ready
INFO: Uvicorn running on http://0.0.0.0:8000
```

**Verify:** Open http://localhost:8000/docs in browser - should see Swagger UI

---

## Step 3: Run iOS App (2 minutes)

**New Terminal Tab:**
```bash
cd ~/Desktop/guardian-one/ios
open GuardianOne.xcodeproj
```

**In Xcode:**
1. Select device: Product → Destination → **iPad Air (6th generation)**
   - If not installed: Xcode → Settings → Platforms → Download
2. Press **⌘R** (or click Play button)
3. Wait for build (30-60 seconds first time)

**Expected:** Simulator launches showing "Guardian One" sign-in screen

---

## Step 4: Test Features (20 minutes)

### Quick Test Flow:

**1. Sign In**
- Tap "Sign in with Apple"
- Simulator auto-signs in

**2. GPS (Map Tab)**
- Should show blue dot, coordinates, altitude, speed

**3. AI Weather (AI Tab)**
- Weather Analysis
- Enter: KAUS → KSAT, 30.5 gallons fuel
- Tap "Analyze Weather"
- Should respond **<3 seconds** with GO/NO-GO recommendation

**4. Engine Logging (Log Tab)**
- Tap "+" to create flight
- Enter: KAUS → KSAT, C172N
- Tap flight → "Log Engine Data"
- Enter your actual post-flight readings
- Save → "View Trends"
- Should show 6 trend graphs with alerts

**5. Stability Test**
- Use app for 30 minutes
- Navigate between tabs
- Create multiple flights
- **Goal: Zero crashes**

---

## Detailed Testing

See **`docs/DAY_10_TESTING_CHECKLIST.md`** for:
- Complete step-by-step test procedures
- Expected results for each feature
- Pass/fail criteria
- Troubleshooting guide
- Feedback form

---

## What to Look For

### ✅ Success Criteria:
- App launches without crash
- GPS displays position
- AI weather responds <3 seconds
- AI gives conservative advice with reasoning
- Engine data saves and trends display
- Zero crashes in 30 minutes

### 🚨 Critical Issues:
- Crashes
- AI response >3 seconds
- Data loss
- Features don't work

### 💡 Nice-to-Have Feedback:
- UI/UX improvements
- Missing features for real-world use
- Performance issues
- Confusing workflows

---

## Troubleshooting

**Backend won't start:**
```bash
cd backend
source venv/bin/activate
pip install -r requirements.txt
python main.py
```

**iOS build fails:**
- Xcode → Product → Clean Build Folder (⌘⇧K)
- Restart Xcode

**AI weather errors:**
- Check OpenAI API key in `backend/.env`
- Verify backend is running at http://localhost:8000

**GPS not working:**
- Simulator → Features → Location → Apple

---

## After Testing

**Share Feedback:**
- Email: mrinebold@gmail.com
- GitHub Issues: https://github.com/mrinebold/guardian-one/issues

**Include:**
1. Overall rating (1-5)
2. What worked well
3. Critical bugs (must fix)
4. Nice-to-have improvements

---

## Your 3 Features in Action

### Feature #1: ADS-B Traffic Awareness
**Code:** `ios/Sources/Services/ADSBService.swift`
- GDL90 protocol parser ✅
- Connects to Stratux/Stratus/Sentry receivers
- <1s latency traffic updates
- Audio alerts for close traffic
- **Note:** Requires hardware (Stratux receiver) for real test

### Feature #2: AI Weather Decision Support ⭐
**Code:** `backend/services/openai_service.py`
- GPT-4 Turbo with aviation safety prompt
- Fetches live METARs from NOAA
- <3 second response time
- Conservative "safety-first" recommendations
- Explains reasoning with weather citations

### Feature #3: Engine Parameter Logging ⭐
**Code:**
- `ios/Sources/Views/EngineDataEntryView.swift` (manual entry)
- `ios/Sources/Views/EngineTrendView.swift` (trend graphs)
- Manual entry for 6 parameters (oil, CHT, EGT, RPM, fuel)
- Trend analysis (last 10 flights)
- Alerts for concerning trends (e.g., "CHT increasing rapidly")

---

## Key Questions to Answer

As you test, think about:

1. **Would you use this app in your C172N?**
   - What's missing for real-world use?

2. **Is AI weather analysis helpful?**
   - Better than just looking at METARs?
   - Would you trust the recommendations?

3. **Is engine logging valuable?**
   - Would you manually enter data after each flight?
   - Or wait for camera OCR in M7?

4. **Overall quality assessment:**
   - Is this "built by AI" obvious in a bad way?
   - Does it feel like a real product?

5. **Pricing validation:**
   - Free tier (GPS, 10 AI queries): Worth $0?
   - Pro tier (+ADS-B, weather, 100 AI): Worth $99/yr?
   - Ultimate tier (+OCR, IFR charts): Worth $299/yr?

---

**Let's see if AI agents can build production-quality software! 🚀**

Thanks for testing!
- Ken & the AI Agent Team (Pixel, Byte, Helio, etc.)
