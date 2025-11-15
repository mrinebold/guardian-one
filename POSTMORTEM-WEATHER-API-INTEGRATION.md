# Guardian One - Weather API Integration Postmortem

**Date**: November 15, 2025
**Incident**: Weather API feature returned "Sorry, I encountered an error" on production
**Duration**: ~45 minutes (17:30 - 18:15 UTC)
**Severity**: Medium (core feature non-functional)
**Status**: ✅ Resolved

---

## 🔴 Timeline

**17:30 UTC** - User reported weather API error on live site
**17:32 UTC** - Investigation started: Vite dev server running, nginx/Cloudflare configured
**17:35 UTC** - Discovered backend missing: No Guardian One FastAPI server running
**17:40 UTC** - Found backend exists at `/home/mrinebold/dev/guardian-one/backend/`
**17:45 UTC** - Port conflict: Port 8000 occupied by CivicGrantsAI backend
**17:50 UTC** - Changed Guardian One backend to port 8002
**17:55 UTC** - Dependency conflict: `supabase==2.3.0` vs `httpx==0.25.1` incompatible
**18:00 UTC** - Created `requirements-minimal.txt` with compatible versions
**18:05 UTC** - Missing `.env` file: OpenAI API key not loaded
**18:10 UTC** - Added `load_dotenv()` to `main.py`
**18:12 UTC** - Backend started successfully on port 8002
**18:13 UTC** - Frontend updated to parse airport codes and call correct endpoints
**18:15 UTC** - ✅ Weather API fully operational (verified with KAUS→KDAL test)

---

## 🐛 Root Causes

### 1. **Missing Backend Service** (Critical)
**Issue**: Guardian One backend was never deployed to civic-main
**Impact**: Weather API returned 404 errors
**Why It Happened**:
- Web app deployment focused on frontend only (Vite)
- Backend deployment was assumed but never executed
- No deployment checklist verified backend health

**Evidence**:
```bash
# Frontend running: ✅
$ ss -tlnp | grep 5177
LISTEN 0  511  0.0.0.0:5177

# Backend running: ❌
$ ss -tlnp | grep 8000
LISTEN 0  2048  0.0.0.0:8000  # Wrong backend (CivicGrantsAI)
```

### 2. **Port Conflict** (Medium)
**Issue**: Guardian One backend configured for port 8000, already occupied
**Impact**: Backend couldn't start, failed silently
**Why It Happened**:
- Multiple backends developed in parallel (CivicGrantsAI, MSR Research, Guardian One)
- No port registry or allocation system
- Default port (8000) used by all projects

**Attempted Fix**: Changed to port 8002
**Result**: ✅ Successful (no conflicts)

### 3. **Dependency Conflicts** (Medium)
**Issue**: `supabase==2.3.0` requires `httpx>=0.24,<0.26` but `requirements.txt` pinned `httpx==0.25.1` twice (lines 26 and 44)
**Impact**: `pip install` failed with resolution error
**Why It Happened**:
- `requirements.txt` was auto-generated/copy-pasted from another project
- Duplicate `httpx` entry in Testing section
- No dependency validation before deployment

**Fix**:
```python
# Before (requirements.txt line 44)
httpx==0.25.1  # API testing (already listed above)

# After
# httpx already listed above under External APIs
```

**Better Fix**: Created `requirements-minimal.txt` with only needed packages

### 4. **Missing Environment Configuration** (Critical)
**Issue**: Backend required `OPENAI_API_KEY` but `.env` file never loaded
**Impact**: Backend crashed on import with `ValueError`
**Why It Happened**:
- `main.py` imported services before loading dotenv
- `.env` file existed but wasn't read
- `python-dotenv` installed but never called

**Error**:
```python
❌ OPENAI_API_KEY not set in environment
ValueError: OPENAI_API_KEY environment variable is required
```

**Fix**:
```python
# main.py (BEFORE)
from fastapi import FastAPI
from routers import coaching  # Imports OpenAIService → crashes

# main.py (AFTER)
from dotenv import load_dotenv
load_dotenv()  # Load .env BEFORE imports
from fastapi import FastAPI
from routers import coaching  # Now works
```

### 5. **Incorrect API Endpoint** (Medium)
**Issue**: Frontend called `/api/weather/analyze` but backend exposed `/api/coaching/weather-analysis`
**Impact**: 404 Not Found errors
**Why It Happened**:
- Frontend built against hypothetical API design
- Backend used different endpoint naming convention
- No API contract or OpenAPI spec validation

**Fix**: Updated `WeatherChat.tsx` to parse airport codes and route correctly:
```typescript
// Detects ICAO codes (KAUS, KDAL) → /api/coaching/weather-analysis
// General questions → /api/coaching/chat
```

---

## ✅ What Went Right

1. **Detailed Documentation**: Backend README and .env.example made setup clear
2. **Modular Code**: Backend worked immediately after dependencies resolved
3. **Good Error Messages**: OpenAI service error was clear and actionable
4. **Fast Diagnosis**: Logs and `ss -tlnp` quickly identified missing backend
5. **Production Resilience**: Frontend continued working, only weather feature affected

---

## 🚨 What Went Wrong

### Process Failures

1. **No Deployment Checklist**
   - Frontend deployed ✅
   - Backend deployment skipped ❌
   - No verification step for full-stack features

2. **No Integration Testing**
   - Components tested in isolation
   - No end-to-end test: Frontend → Backend → OpenAI → NOAA
   - Weather feature never tested on production

3. **No Service Discovery**
   - Frontend hardcoded `localhost:8000`
   - No environment-based backend URL
   - Port conflicts not anticipated

4. **No Dependency Management**
   - `requirements.txt` had duplicates and conflicts
   - No `pip-compile` or `poetry.lock` for reproducibility
   - Testing dependencies mixed with production

### Architecture Issues

5. **Tight Coupling**
   - Frontend assumes backend on specific port
   - No service discovery mechanism
   - Hard to run multiple projects simultaneously

6. **Missing Health Checks**
   - No `/health` endpoint monitoring
   - No startup validation (DB connection, API keys, etc.)
   - Silent failures (no alerts when backend unavailable)

7. **Incomplete Environment Parity**
   - Dev environment (local) worked fine
   - Production environment missing backend
   - No staging environment to catch this

---

## 🛠️ Immediate Fixes Applied

1. ✅ Created `requirements-minimal.txt` (removed conflicts)
2. ✅ Added `load_dotenv()` to `main.py`
3. ✅ Created `.env` with OpenAI API key
4. ✅ Started backend on port 8002 (conflict-free)
5. ✅ Updated frontend to parse airport codes and route correctly
6. ✅ Deployed all fixes to civic-main
7. ✅ Verified weather API: KAUS→KDAL test returned GO recommendation in 8s

---

## 📋 Long-Term Preventions

### PRD Required: Saladbar Ideator Enhancement
**Goal**: Prevent deployment inconsistencies across multi-tier applications

**Proposed Rules** (to be implemented in Saladbar Ideator):

1. **Full-Stack Deployment Checklist**
   - When PRD mentions "API" or "backend", enforce deployment steps
   - Require health check verification before marking complete
   - Block completion if services don't respond

2. **Port Registry System**
   - Maintain `PORTS.md` registry:
     - 8000: CivicGrantsAI Backend
     - 8001: MSR Research Backend
     - 8002: Guardian One Backend
     - 5173-5178: Frontend dev servers
   - Auto-detect conflicts before suggesting port
   - Warn if port already allocated

3. **Dependency Validation**
   - Run `pip-compile` or `poetry check` on generated requirements
   - Detect duplicate packages
   - Flag version conflicts pre-deployment

4. **Environment File Templates**
   - Generate `.env.example` AND `.env` (with placeholders)
   - Check for `load_dotenv()` in main entry points
   - Warn if env vars referenced but not loaded

5. **Integration Test Requirements**
   - For multi-tier features (Frontend + Backend + External API):
     - Require E2E test in PRD acceptance criteria
     - Block deployment until test passes on staging
     - Auto-generate smoke test from API contract

6. **API Contract Validation**
   - Generate OpenAPI spec from FastAPI routes
   - Compare frontend fetch() calls against spec
   - Fail if endpoints don't match

7. **Service Health Monitoring**
   - Require `/health` endpoint for all backends
   - Auto-generate systemd service files
   - Add startup verification command

8. **Deployment Verification**
   - After deployment, auto-verify:
     - ✅ Service listening on expected port
     - ✅ Health check returns 200
     - ✅ Frontend can reach backend
     - ✅ External API calls succeed (if applicable)

---

## 📊 Metrics

**Time to Detect**: 0 minutes (user reported immediately)
**Time to Diagnose**: 15 minutes (identified missing backend)
**Time to Fix**: 30 minutes (resolved all 5 root causes)
**Total Downtime**: 45 minutes (weather feature only)

**Affected Users**: Unknown (production, but likely low traffic during deployment)
**Data Loss**: None
**Financial Impact**: None (development project)

---

## 🎓 Lessons Learned

### Technical

1. **Always deploy both tiers** for full-stack features (obvious in hindsight)
2. **Environment parity matters** - dev ≠ production caught us
3. **Minimal dependencies win** - stripped down requirements worked first try
4. **Load env vars FIRST** - before any imports that need them

### Process

5. **Checklists prevent errors** - deployment steps must be systematic
6. **Test in production** - at least smoke test after deploy
7. **Document port allocations** - prevents conflicts
8. **Health checks are mandatory** - for any service

### Meta

9. **AI agents need guardrails** - Saladbar Ideator should catch these
10. **Patterns repeat** - same mistakes will happen again without systemic fixes

---

## 👥 Action Items

| Action | Owner | Deadline | Status |
|--------|-------|----------|--------|
| Create PRD: Saladbar Ideator Enhancement | Pixel | Nov 15 | 🔄 In Progress |
| Implement port registry in CLAUDE.md | Helio | Nov 16 | ⏳ Pending |
| Add deployment checklist template | Helio | Nov 16 | ⏳ Pending |
| Create staging environment for Guardian One | Forge | Nov 18 | ⏳ Pending |
| Write E2E test: Frontend → Backend → OpenAI | Quest | Nov 17 | ⏳ Pending |
| Generate OpenAPI spec from FastAPI | Byte | Nov 16 | ⏳ Pending |
| Add health check monitoring to qinfra | Helio | Nov 17 | ⏳ Pending |

---

## 🔗 Related Documents

- **PRD**: `prds/2025-11-15-1730_guardian-one-ux-polish-production-ready.prd.md`
- **Deployment**: `UX-IMPROVEMENTS-COMPLETE.md`
- **Backend README**: `backend/README.md`
- **API Logs**: `/tmp/guardian-backend.log` (civic-main)

---

**Postmortem Author**: Claude (Pixel Agent)
**Reviewers**: Helio (Orchestrator), Byte (Backend), Quest (QA)
**Date**: November 15, 2025 18:30 UTC

*This postmortem follows the "blameless" principle - we focus on systemic improvements, not individual fault.*
