import { useState } from 'react';

interface OnboardingWalkthroughProps {
  onComplete: () => void;
}

interface WalkthroughStep {
  title: string;
  icon: string;
  description: string;
  features: string[];
}

export function OnboardingWalkthrough({ onComplete }: OnboardingWalkthroughProps) {
  const [step, setStep] = useState(1);
  const totalSteps = 3;

  const steps: WalkthroughStep[] = [
    {
      title: "GPS Tracking",
      icon: "📍",
      description: "Guardian One uses your device GPS to show your exact position on a live map. Perfect for cross-country flights and finding nearby airports.",
      features: [
        "Accuracy: 10-30 feet",
        "Updates: Every 3 seconds",
        "Works on mobile and desktop",
      ],
    },
    {
      title: "AI Weather Decision Support",
      icon: "☁️",
      description: "Enter departure and destination airports, and our AI analyzes current weather conditions from NOAA METARs and TAFs. Get conservative go/no-go recommendations with reasoning.",
      features: [
        "GPT-4 powered analysis",
        "Response time: <3 seconds",
        "Cites weather data sources",
      ],
    },
    {
      title: "Flight History & Trends",
      icon: "📊",
      description: "Log 6 critical engine parameters after each flight. Guardian One analyzes 10-flight trends and alerts you to gradual failures like CHT creeping up slowly.",
      features: [
        "10-flight trend analysis",
        "Early warning alerts",
        "C172N normal ranges",
      ],
    },
  ];

  const handleNext = () => {
    if (step < totalSteps) {
      setStep(step + 1);
    } else {
      onComplete();
    }
  };

  const handleBack = () => {
    if (step > 1) {
      setStep(step - 1);
    }
  };

  const currentStep = steps[step - 1];

  return (
    <div className="onboarding-overlay">
      <div className="onboarding-card">
        <div className="onboarding-header">
          <h2>
            <span className="step-icon">{currentStep.icon}</span>
            {currentStep.title}
          </h2>
          <div className="step-indicator">
            Step {step} of {totalSteps}
          </div>
        </div>

        <div className="onboarding-content">
          <p className="step-description">{currentStep.description}</p>

          <ul className="step-features">
            {currentStep.features.map((feature, i) => (
              <li key={i}>✓ {feature}</li>
            ))}
          </ul>
        </div>

        <div className="onboarding-footer">
          <div className="progress-dots">
            {Array.from({ length: totalSteps }).map((_, i) => (
              <span
                key={i}
                className={`progress-dot ${i + 1 === step ? 'active' : ''} ${i + 1 < step ? 'completed' : ''}`}
              />
            ))}
          </div>

          <div className="onboarding-nav">
            {step > 1 && (
              <button onClick={handleBack} className="btn-secondary">
                ← Back
              </button>
            )}
            <button onClick={handleNext} className="btn-primary">
              {step === totalSteps ? "Got It! ✓" : "Next →"}
            </button>
          </div>
        </div>

        <button onClick={onComplete} className="skip-tutorial">
          Skip Tutorial
        </button>
      </div>
    </div>
  );
}
