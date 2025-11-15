import { useState, useCallback, useEffect } from 'react';
import { StarWarsCrawl } from './components/StarWarsCrawl';
import { OnboardingWalkthrough } from './components/OnboardingWalkthrough';
import { BuildLogModal } from './components/BuildLogModal';
import { Map } from './components/Map';
import { WeatherChat } from './components/WeatherChat';
import { AviationChat } from './components/AviationChat';
import { FlightList } from './components/FlightList';
import { EngineForm } from './components/EngineForm';
import { TrendChart } from './components/TrendChart';
import { useGeolocation } from './hooks/useGeolocation';

function App() {
  const [showCrawl, setShowCrawl] = useState(true);
  const [showOnboarding, setShowOnboarding] = useState(false);
  const [showBuildLog, setShowBuildLog] = useState(false);
  const [refreshFlights, setRefreshFlights] = useState(0);
  const { location } = useGeolocation();

  // Check if user has seen onboarding before
  useEffect(() => {
    const hasSeenOnboarding = localStorage.getItem('guardian-one-onboarding-complete');
    if (hasSeenOnboarding) {
      setShowOnboarding(false);
    }
  }, []);

  const handleCrawlComplete = useCallback(() => {
    setShowCrawl(false);
    // Show onboarding only if user hasn't seen it before
    const hasSeenOnboarding = localStorage.getItem('guardian-one-onboarding-complete');
    if (!hasSeenOnboarding) {
      setShowOnboarding(true);
    }
  }, []);

  const handleOnboardingComplete = useCallback(() => {
    localStorage.setItem('guardian-one-onboarding-complete', 'true');
    setShowOnboarding(false);
  }, []);

  const handleFlightAdded = useCallback(() => {
    setRefreshFlights((prev) => prev + 1);
  }, []);

  if (showCrawl) {
    return <StarWarsCrawl onComplete={handleCrawlComplete} />;
  }

  if (showOnboarding) {
    return <OnboardingWalkthrough onComplete={handleOnboardingComplete} />;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-aviation-blue text-white shadow-lg">
        <div className="container mx-auto px-4 py-6">
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-3xl font-bold">Guardian One</h1>
              <p className="text-blue-100 mt-1">Aviation Safety Assistant • Built by AI Agents in 24 Hours</p>
            </div>
            <button
              onClick={() => setShowBuildLog(true)}
              className="bg-white/10 hover:bg-white/20 text-white border border-white/30 px-4 py-2 rounded-lg transition-all font-semibold"
            >
              🤖 How This Was Built
            </button>
          </div>
        </div>
      </header>

      {/* Build Log Modal */}
      <BuildLogModal isOpen={showBuildLog} onClose={() => setShowBuildLog(false)} />

      {/* Main Content */}
      <main className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* GPS Tracking */}
          <div>
            <Map location={location} />
          </div>

          {/* AI Weather Briefing */}
          <div>
            <WeatherChat location={location} />
          </div>

          {/* AI Aviation Assistant */}
          <div>
            <AviationChat />
          </div>

          {/* Engine Parameter Entry */}
          <div>
            <EngineForm onFlightAdded={handleFlightAdded} />
          </div>

          {/* Flight Log */}
          <div>
            <FlightList key={refreshFlights} />
          </div>

          {/* Trend Analysis */}
          <div className="lg:col-span-2">
            <TrendChart key={refreshFlights} />
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-gray-800 text-gray-300 mt-12">
        <div className="container mx-auto px-4 py-6 text-center">
          <p className="text-sm">
            Built by <span className="text-star-wars-yellow font-semibold">Saladbar AI Agent Platform</span> • MSR Research © 2025
          </p>
          <p className="text-xs mt-2 text-gray-400">
            Agents: Helio (Orchestrator) • Byte (Backend) • Pixel (Frontend) • Quest (QA) • Schema (Database)
          </p>
        </div>
      </footer>
    </div>
  );
}

export default App;
