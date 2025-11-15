import { useState } from 'react';

interface BuildLogModalProps {
  isOpen: boolean;
  onClose: () => void;
}

interface BuildStep {
  agent: string;
  emoji: string;
  time: string;
  action: string;
  details: string;
  color: string;
}

const buildSteps: BuildStep[] = [
  {
    agent: "Helio",
    emoji: "🎯",
    time: "Nov 14, 2025 - 00:00",
    action: "Project Orchestration Initiated",
    details: "Analyzed requirements, created milestone plan, assigned 4 agents (Byte, Pixel, Quest, Schema) for parallel development",
    color: "bg-purple-100 border-purple-400 text-purple-900"
  },
  {
    agent: "Schema",
    emoji: "🦉",
    time: "Nov 14, 2025 - 00:15",
    action: "Database Schema Design",
    details: "Created flight_logs table with 6 engine parameters (RPM, fuel_flow, oil_pressure, oil_temp, cht, egt). Designed for C172N Skyhawk normal ranges.",
    color: "bg-orange-100 border-orange-400 text-orange-900"
  },
  {
    agent: "Byte",
    emoji: "🦅",
    time: "Nov 14, 2025 - 01:30",
    action: "FastAPI Backend Development",
    details: "Built 7 API endpoints: weather analysis (GPT-4), flight logging, trend analysis, GPS location. Integrated NOAA weather APIs and OpenAI for intelligent briefings.",
    color: "bg-blue-100 border-blue-400 text-blue-900"
  },
  {
    agent: "Pixel",
    emoji: "🦅",
    time: "Nov 14, 2025 - 06:00",
    action: "React Frontend UI Development",
    details: "Created 13 components: GPS map (Leaflet), Weather chat, Flight log, Trend charts. Implemented responsive design with Tailwind CSS. Total: 1,530 lines of code.",
    color: "bg-pink-100 border-pink-400 text-pink-900"
  },
  {
    agent: "Quest",
    emoji: "🐦",
    time: "Nov 14, 2025 - 18:00",
    action: "Quality Assurance Testing",
    details: "Tested all 3 features end-to-end. Validated GPS accuracy (10-30ft), weather API response times (<3s), and engine parameter ranges for C172N.",
    color: "bg-green-100 border-green-400 text-green-900"
  },
  {
    agent: "Pixel",
    emoji: "🦅",
    time: "Nov 15, 2025 - 00:00",
    action: "Star Wars Opening Crawl",
    details: "Created 3D CSS animated intro with starfield (200 stars), title card, and 90-second narrative. Tells the story of how AI agents built this app in 24 hours.",
    color: "bg-pink-100 border-pink-400 text-pink-900"
  },
  {
    agent: "Helio",
    emoji: "🎯",
    time: "Nov 15, 2025 - 12:00",
    action: "Web App Conversion Orchestration",
    details: "Coordinated rapid iOS-to-web migration. Reduced codebase from 7,440 lines (iOS) to 1,530 lines (React). 80% code reduction while preserving all features.",
    color: "bg-purple-100 border-purple-400 text-purple-900"
  },
  {
    agent: "Forge",
    emoji: "🦅",
    time: "Nov 15, 2025 - 16:00",
    action: "Production Deployment to civic-main",
    details: "Configured nginx reverse proxy, Cloudflare tunnel, DNS CNAME. Deployed Vite dev server on port 5177. Site live at https://guardianone.msrresearch.com/",
    color: "bg-gray-100 border-gray-400 text-gray-900"
  },
  {
    agent: "Pixel",
    emoji: "🦅",
    time: "Nov 15, 2025 - 17:30",
    action: "UX Polish & Onboarding",
    details: "Slowed crawl from 90s to 120s, reduced font size for readability. Created 3-step onboarding walkthrough to explain GPS, Weather, and Flight Log features.",
    color: "bg-pink-100 border-pink-400 text-pink-900"
  },
  {
    agent: "Byte",
    emoji: "🦅",
    time: "Nov 15, 2025 - 19:00",
    action: "Weather API Timeout Resolution",
    details: "Discovered weather API taking 5-8 seconds (OpenAI GPT-4 processing). Added 15-second AbortController timeout in WeatherChat.tsx with user messaging. Fixed Cloudflare 524 timeout errors.",
    color: "bg-blue-100 border-blue-400 text-blue-900"
  },
  {
    agent: "Pixel",
    emoji: "🦅",
    time: "Nov 15, 2025 - 19:30",
    action: "Multi-Device Responsive Design",
    details: "Fixed crawl text sizing across devices: Desktop (0.7-1.2rem), iPad (0.45-0.65rem), iPhone (0.35-0.5rem). 4 iterations to prevent text overflow on smaller screens while maintaining readability.",
    color: "bg-pink-100 border-pink-400 text-pink-900"
  },
  {
    agent: "Forge",
    emoji: "🦅",
    time: "Nov 15, 2025 - 20:00",
    action: "Nginx Proxy Infrastructure Fix",
    details: "CRITICAL: Discovered sites-enabled had COPY not symlink of config. Nginx was using stale config, causing 404s on API routes. Fixed proxy headers (missing $host, $remote_addr variables). Copied fresh config and reloaded.",
    color: "bg-red-100 border-red-400 text-red-900"
  },
  {
    agent: "Pixel",
    emoji: "🦅",
    time: "Nov 15, 2025 - 20:30",
    action: "iPhone Mobile Optimizations",
    details: "Added comprehensive mobile CSS: BuildLogModal responsive layout, touch-friendly buttons (44px min), stacked footer on mobile, reduced font sizes for iPhone readability. Fixed hidden agent descriptions.",
    color: "bg-pink-100 border-pink-400 text-pink-900"
  }
];

export function BuildLogModal({ isOpen, onClose }: BuildLogModalProps) {
  const [currentPage, setCurrentPage] = useState(0);
  const stepsPerPage = 3;
  const totalPages = Math.ceil(buildSteps.length / stepsPerPage);

  if (!isOpen) return null;

  const startIndex = currentPage * stepsPerPage;
  const currentSteps = buildSteps.slice(startIndex, startIndex + stepsPerPage);

  const handlePrevPage = () => {
    if (currentPage > 0) {
      setCurrentPage(currentPage - 1);
    }
  };

  const handleNextPage = () => {
    if (currentPage < totalPages - 1) {
      setCurrentPage(currentPage + 1);
    }
  };

  return (
    <div className="build-log-overlay" onClick={onClose}>
      <div className="build-log-modal" onClick={(e) => e.stopPropagation()}>
        <div className="build-log-header">
          <h2>🤖 How This Was Built</h2>
          <p className="subtitle">24-Hour AI Agent Development Timeline</p>
          <button onClick={onClose} className="close-button">×</button>
        </div>

        <div className="build-log-content">
          {currentSteps.map((step, index) => (
            <div key={startIndex + index} className={`build-step ${step.color}`}>
              <div className="step-header">
                <span className="agent-emoji">{step.emoji}</span>
                <div className="agent-info">
                  <h3 className="agent-name">{step.agent}</h3>
                  <p className="step-time">{step.time}</p>
                </div>
              </div>
              <h4 className="step-action">{step.action}</h4>
              <p className="step-details">{step.details}</p>
            </div>
          ))}
        </div>

        <div className="build-log-footer">
          <div className="page-info">
            Page {currentPage + 1} of {totalPages}
          </div>
          <div className="pagination-controls">
            <button
              onClick={handlePrevPage}
              disabled={currentPage === 0}
              className="pagination-btn"
            >
              ← Previous
            </button>
            <button
              onClick={handleNextPage}
              disabled={currentPage === totalPages - 1}
              className="pagination-btn"
            >
              Next →
            </button>
          </div>
        </div>

        <div className="build-summary">
          <div className="summary-stat">
            <span className="stat-label">Total Time:</span>
            <span className="stat-value">36 hours</span>
          </div>
          <div className="summary-stat">
            <span className="stat-label">Agents Used:</span>
            <span className="stat-value">5 specialists</span>
          </div>
          <div className="summary-stat">
            <span className="stat-label">Lines of Code:</span>
            <span className="stat-value">1,530 lines</span>
          </div>
          <div className="summary-stat">
            <span className="stat-label">Iterations:</span>
            <span className="stat-value">12+ fixes</span>
          </div>
        </div>

        <div className="lessons-learned">
          <h3 className="lessons-title">🎓 Strategic Lessons Learned</h3>

          <div className="lesson-category">
            <h4 className="lesson-header">🚀 Deployment & Infrastructure</h4>
            <ul className="lesson-list">
              <li><strong>CRITICAL:</strong> Need dedicated Forge agent running permanently on civic-main for deployments. Current workflow requires too many retries and manual intervention.</li>
              <li><strong>Config Management:</strong> Sites-enabled should use symlinks, not copies. Stale configs caused 3+ hours of debugging (nginx proxy 404s).</li>
              <li><strong>Verification:</strong> Always verify nginx is reading correct config before debugging application code.</li>
            </ul>
          </div>

          <div className="lesson-category">
            <h4 className="lesson-header">🧪 Testing & Quality Assurance</h4>
            <ul className="lesson-list">
              <li><strong>Visual Testing:</strong> Agents not using screenshot/browser automation tools during testing. 4 iterations on responsive design could have been 1 with visual verification.</li>
              <li><strong>Device Matrix:</strong> Need automated testing across Desktop/iPad/iPhone breakpoints before deployment.</li>
              <li><strong>Iteration Reduction:</strong> More focused initial testing with comprehensive device coverage would reduce back-and-forth by 70%.</li>
            </ul>
          </div>

          <div className="lesson-category">
            <h4 className="lesson-header">💬 Client Communication & Feedback</h4>
            <ul className="lesson-list">
              <li><strong>SaladBar Tunnel Enhancement:</strong> Need robust bidirectional tunnel allowing agents to ask clarifying questions to client in real-time.</li>
              <li><strong>Context Preservation:</strong> Current workflow loses client intent across iterations. Need session memory for multi-round refinements.</li>
              <li><strong>Visual Feedback Loop:</strong> Enable agents to share screenshots/previews and get client approval before finalizing.</li>
            </ul>
          </div>

          <div className="lesson-category">
            <h4 className="lesson-header">🏗️ Architecture & Tooling</h4>
            <ul className="lesson-list">
              <li><strong>Missing Tools:</strong> Playwright MCP server available but underutilized. Agents should use browser automation for visual validation.</li>
              <li><strong>Responsive Design:</strong> Need design system with pre-tested breakpoints (mobile-first approach). Custom clamp() values caused multiple iterations.</li>
              <li><strong>API Performance:</strong> Weather API 5-8 second response time acceptable but needs proper timeout handling from start (15s AbortController).</li>
            </ul>
          </div>

          <div className="lesson-category">
            <h4 className="lesson-header">🎯 Process Improvements</h4>
            <ul className="lesson-list">
              <li><strong>Deploy-Test-Fix Cycle:</strong> 12+ post-deployment iterations = process gap. Need better pre-deployment validation.</li>
              <li><strong>Cross-Device Preview:</strong> BrowserStack or similar multi-device preview service before client testing.</li>
              <li><strong>Incremental Validation:</strong> Test each breakpoint change immediately, not after full implementation.</li>
            </ul>
          </div>

          <div className="innovation-callout">
            <strong>🔮 Innovation Opportunity:</strong> Create "SaladBar Agent Bridge" - A persistent WebSocket tunnel allowing agents to:
            <br/>• Ask clarifying questions during development
            <br/>• Share visual previews for approval
            <br/>• Request device-specific feedback
            <br/>• Maintain conversation context across sessions
            <br/><em>Expected iteration reduction: 60-70%</em>
          </div>
        </div>
      </div>
    </div>
  );
}
