# Guardian One
## AI-Powered Cockpit Safety Companion

**Built 100% by AI agents in 90 days**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: iOS](https://img.shields.io/badge/Platform-iOS%2017%2B-blue)](https://www.apple.com/ios/)
[![Backend: FastAPI](https://img.shields.io/badge/Backend-FastAPI-green)](https://fastapi.tiangolo.com/)
[![AI: GPT-4](https://img.shields.io/badge/AI-GPT--4%20Turbo-purple)](https://openai.com/)

---

## Overview

Guardian One is a freemium Electronic Flight Bag (EFB) app for Cessna 172 pilots. It provides:
- **AI Safety Coaching** (only EFB with this feature)
- **Camera OCR** for analog gauges (revolutionary)
- **ADS-B Traffic & Weather** (Pro/Ultimate tiers)
- **Free Tier** for student pilots

**Pricing:** Free → $99/yr Pro → $299/yr Ultimate

**Built by:** 9 AI agents (Pixel, Byte, Cipher, Quest, Nova, Schema, Helio, Echo, Iris)
**Timeline:** 90 days (vs 12-18 months traditional)
**Cost:** $88,000 (vs $496,000 traditional)

---

## Quick Links

- **Product Requirements:** [prds/guardian-one-freemium-mvp.prd.md](prds/guardian-one-freemium-mvp.prd.md)
- **Technical Documentation:** [docs/TECHNICAL_DOCUMENTATION.md](docs/TECHNICAL_DOCUMENTATION.md)
- **User Guide:** [docs/USER_DOCUMENTATION.md](docs/USER_DOCUMENTATION.md)
- **Build Journal:** [docs/BUILD_JOURNAL.md](docs/BUILD_JOURNAL.md) (daily agent activities)
- **Agent Cost Tracking:** [docs/AGENT_TRACKING.md](docs/AGENT_TRACKING.md)
- **Value Proposition:** [docs/VALUE_PROPOSITION_STORY.md](docs/VALUE_PROPOSITION_STORY.md)
- **Competitive Analysis:** [docs/COMPETITIVE_ANALYSIS.md](docs/COMPETITIVE_ANALYSIS.md)

---

## Features by Tier

### Free Tier ($0/year)
- ✅ iPad GPS navigation
- ✅ Moving map with airports & airspace
- ✅ Flight planning (routes, waypoints)
- ✅ Basic AI coaching (10 questions/month)
- ❌ No ADS-B traffic/weather
- ❌ No camera OCR

### Pro Tier ($99/year)
- ✅ Everything in Free
- ✅ ADS-B traffic display
- ✅ Live weather radar (NEXRAD)
- ✅ METARs, TAFs, winds aloft
- ✅ AI coaching (100 questions/month)
- ❌ No camera OCR

### Ultimate Tier ($299/year)
- ✅ Everything in Pro
- ✅ **Camera OCR for analog gauges** (unique)
- ✅ IFR charts (low/high enroute, approach plates)
- ✅ Performance calculators (W&B, takeoff/landing)
- ✅ Unlimited AI coaching

---

## Technology Stack

### iOS App
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI (iOS 17+)
- **Dependencies:** Supabase, MapKit, Core ML, Vision, StoreKit 2

### Backend
- **Language:** Python 3.11+
- **Framework:** FastAPI
- **Database:** Supabase (PostgreSQL 15+)
- **AI:** OpenAI GPT-4 Turbo
- **Hosting:** Fly.io

---

## 90-Day Development Roadmap

### Milestone 1: Project Intake (Day 1) ✅
- SaladBar submission complete
- Repository created
- PRD and documentation finalized

### Milestone 2: 10-Day Sprint (Days 2-11)
- Implement Dustin's 3 must-have features
- iOS app with GPS + moving map
- TestFlight build for Dustin

### Milestone 3: Quality Pass (Days 12-21)
- >80% test coverage
- Security audit
- CI/CD pipeline

### Milestone 4: User Feedback (Days 22-31)
- Incorporate Dustin's feedback
- UI/UX polish
- In-app purchase integration

### Milestone 5: Feature Integration (Days 32-46)
- ADS-B integration (Stratux)
- AI coaching API
- Pro tier features

### Milestone 6: Beta Launch (Days 47-61)
- 100 TestFlight beta testers
- App Store assets
- Crash reporting

### Milestone 7: Advanced Features (Days 62-76)
- Camera OCR for gauges
- IFR charts
- Ultimate tier features

### Milestone 8: Revenue Launch (Days 77-90)
- App Store submission
- Production deployment
- Marketing launch

---

## AI Agent Team

| Agent | Role | Primary Responsibilities |
|-------|------|-------------------------|
| **Helio** | Project Orchestrator | Milestone tracking, agent coordination |
| **Pixel** | iOS Developer | SwiftUI UI, MapKit, Core ML OCR |
| **Byte** | Backend Developer | FastAPI, Supabase, AI integration |
| **Cipher** | Security Analyst | Authentication, API security, audits |
| **Quest** | QA Specialist | Test suite, CI/CD, bug triage |
| **Nova** | Documentation | PRD, tech docs, user guide |
| **Schema** | Database Architect | PostgreSQL schema, migrations |
| **Echo** | Analytics | Metrics dashboard, KPI tracking |
| **Iris** | Marketing | App Store listing, launch content |

---

## Getting Started (Development)

### iOS App

```bash
cd ios/
# Open in Xcode (Xcode 15+ required)
open GuardianOne.xcodeproj

# Or resolve Swift packages via CLI
swift package resolve
```

### Backend

```bash
cd backend/
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create .env file with:
# SUPABASE_URL=...
# SUPABASE_SERVICE_KEY=...
# OPENAI_API_KEY=...

# Run backend
uvicorn main:app --reload --port 8000
```

---

## Testing

### iOS Tests
```bash
cd ios/
swift test
```

### Backend Tests
```bash
cd backend/
pytest --cov=app --cov-report=html
```

---

## Contributing

**This project is built 100% by AI agents.** Human contributions are welcome for:
- Beta testing (TestFlight feedback)
- Bug reports (GitHub Issues)
- Feature requests (GitHub Discussions)
- Documentation improvements (PRs accepted)

**Code contributions:** AI agents (Pixel, Byte) review and approve PRs.

---

## License

MIT License - See [LICENSE](LICENSE) file

---

## Stakeholder

**Dustin** (Ken's son):
- American Airlines pilot
- Computer Science + Physics degrees
- Owns Cessna 172
- **Mission:** Prove AI agents can build quality software

**Dustin, if you're reading this:**
1. Download the TestFlight build (check your email)
2. Fly 3 flights with Guardian One
3. Provide feedback (GitHub Issues or email)
4. Join the team if you're impressed 😊

---

## Contact

**Email:** support@guardian.one
**GitHub:** [@mrinebold](https://github.com/mrinebold)
**Project Status:** Active development (Day 1 of 90)

---

**Safe Flying!**

_Built with ❤️ by AI Agents_

🤖 Generated with [Claude Code](https://claude.com/claude-code)
