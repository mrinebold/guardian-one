# Email Template for Dustin's Day 10 Demo Invitation

---

**Subject:** Guardian One - Ready for Your Testing (Day 10 Demo)

---

Hey Dustin,

We're ready for you to test Guardian One! All 3 of your must-have features are implemented:

✅ **Feature #1: ADS-B Traffic Awareness** - GDL90 protocol integration
✅ **Feature #2: AI Weather Decision Support** - GPT-4 with <3s response time
✅ **Feature #3: Engine Parameter Logging** - Manual entry + trend analysis

**What I Need from You:**
30 minutes of testing on your Mac to validate:
- App stability (zero crashes requirement)
- Feature usefulness for real-world flying
- Overall quality assessment ("built by AI" vs "production-ready")

**Your Verdict Will Decide:**
- ✅ **PASS (3-5 rating):** Proceed to Milestone 3 (quality pass + beta testing)
- ❌ **FAIL (1-2 rating):** Fix critical bugs before continuing

---

## Quick Start (5 minutes to get running)

### 1. Clone Repository
```bash
cd ~/Desktop
git clone https://github.com/mrinebold/guardian-one
cd guardian-one
```

### 2. Get OpenAI API Key
- Go to: https://platform.openai.com/api-keys
- Create account (if needed) or sign in
- Click "Create new secret key"
- Copy the key (starts with `sk-...`)

### 3. Start Backend
```bash
cd backend
./start.sh
```
- Script will prompt for OpenAI API key - paste it when asked
- Backend will start at http://localhost:8000

### 4. Run iOS App
```bash
# New terminal tab
cd ~/Desktop/guardian-one/ios
open GuardianOne.xcodeproj
```
- In Xcode: Select **iPad Air (6th generation)** simulator
- Press **⌘R** to build and run
- App should launch in 30-60 seconds

---

## Testing Guide

**Quick Test (5 minutes):**
1. **Sign In** - Tap "Sign in with Apple" (auto-signs in simulator)
2. **GPS** - Map tab should show blue dot + position data
3. **AI Weather** - AI tab → KAUS to KSAT → Should respond <3 seconds
4. **Engine Logging** - Log tab → Create flight → Log engine data → View trends

**Full Testing Checklist:**
See `docs/DAY_10_TESTING_CHECKLIST.md` for detailed test procedures, expected results, and pass/fail criteria.

**Quick Start Guide:**
See `QUICKSTART.md` in repository root for troubleshooting and FAQs.

---

## What to Look For

### Critical (Must Work):
- ✅ App doesn't crash
- ✅ AI weather responds <3 seconds
- ✅ AI gives conservative recommendations with reasoning
- ✅ Engine data saves and trends display

### Your Expertise (Real-World Validation):
- Would you use this in your C172N?
- Is AI weather analysis actually helpful (vs just METARs)?
- Would you manually log engine data after each flight?
- Does this feel like a real product or "obviously AI-built"?

### Pricing Validation:
- Free tier (GPS + 10 AI queries): Worth $0?
- Pro tier (+ADS-B + weather): Worth $99/yr?
- Ultimate tier (+OCR + IFR charts): Worth $299/yr?

---

## After Testing

**Share Feedback:**
- Email me your rating (1-5) and key findings
- Or create GitHub issues: https://github.com/mrinebold/guardian-one/issues

**What I Need:**
1. **Overall Rating:** _____ / 5
2. **What Worked Well:** (3 things)
3. **Critical Bugs:** (must fix for M3)
4. **Nice-to-Have:** (improvements for beta)

---

## Why This Matters

**Your verdict determines:**
- Whether AI agents can build production-quality software
- If we proceed to beta testing with 100 real pilots
- My confidence in AI-assisted development at scale

**The Big Question:**
Can 9 AI agents build a better EFB than ForeFlight's 50-person team in 90 days for $88k instead of $496k?

Your honest feedback (even if brutal) is what we need to find out.

---

## Troubleshooting (If Needed)

**Backend errors:**
```bash
cd backend
source venv/bin/activate
pip install -r requirements.txt
python main.py
```

**iOS build fails:**
- Xcode → Product → Clean Build Folder (⌘⇧K)
- Restart Xcode

**Need help:**
- Text/call me: [your number]
- Email: mrinebold@gmail.com

---

Thanks for being our critical tester! Your pilot experience + CS/Physics background makes you the perfect skeptical validator.

Let me know when you're free to test (ideally this week while it's fresh).

- Ken

P.S. - If you want to see the AI agents' actual work, check `docs/BUILD_JOURNAL.md` and `docs/AGENT_TRACKING.md` for transparency on who built what and how much it cost.

---

**Repository:** https://github.com/mrinebold/guardian-one
**Quick Start:** See `QUICKSTART.md` in repo
**Full Testing:** See `docs/DAY_10_TESTING_CHECKLIST.md`
