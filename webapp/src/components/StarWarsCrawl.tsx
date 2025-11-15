import { useState, useEffect, useRef } from 'react';
import { Starfield } from './Starfield';
import { dustinCrawl } from '../content/crawl-dustin';

interface StarWarsCrawlProps {
  onComplete: () => void;
}

export function StarWarsCrawl({ onComplete }: StarWarsCrawlProps) {
  const [showTitle, setShowTitle] = useState(true);
  const [showCrawl, setShowCrawl] = useState(false);
  const [audioPlaying, setAudioPlaying] = useState(false);
  const [showSoundPrompt, setShowSoundPrompt] = useState(true);
  const audioRef = useRef<HTMLAudioElement>(null);

  useEffect(() => {
    // Show title for 6 seconds, then start crawl
    const titleTimer = setTimeout(() => {
      setShowTitle(false);
      setShowCrawl(true);
    }, 6000);

    return () => clearTimeout(titleTimer);
  }, []);

  useEffect(() => {
    // Handle Enter key
    const handleKeyPress = (e: KeyboardEvent) => {
      if (e.key === 'Enter') {
        onComplete();
      }
    };

    window.addEventListener('keydown', handleKeyPress);
    return () => window.removeEventListener('keydown', handleKeyPress);
  }, [onComplete]);

  const handleSkip = () => {
    onComplete();
  };

  const enableSound = () => {
    if (audioRef.current) {
      audioRef.current.play();
      setAudioPlaying(true);
      setShowSoundPrompt(false);
    }
  };

  const toggleAudio = () => {
    if (audioRef.current) {
      if (audioPlaying) {
        audioRef.current.pause();
      } else {
        audioRef.current.play();
      }
      setAudioPlaying(!audioPlaying);
    }
  };

  return (
    <div className="crawl-container">
      <Starfield />

      {showSoundPrompt && (
        <div className="sound-prompt">
          <button onClick={enableSound} className="enable-sound-btn">
            🔊 Enable Epic Music
          </button>
          <p>Click to start with sound</p>
        </div>
      )}

      {showTitle && (
        <div className="title-card">
          <h1>GUARDIAN ONE</h1>
          <p>Built by AI Agents</p>
        </div>
      )}

      {showCrawl && (
        <>
          <div className="crawl-text">
            {dustinCrawl.split('\n').map((line, i) => (
              <div key={i}>{line || '\u00A0'}</div>
            ))}
          </div>
          <div className="press-enter">
            Press ENTER to launch →
          </div>
        </>
      )}

      <button
        onClick={handleSkip}
        className="skip-button"
      >
        Skip Intro
      </button>

      {!showSoundPrompt && (
        <button
          onClick={toggleAudio}
          className="audio-button"
        >
          {audioPlaying ? '🔇 Mute Music' : '🔊 Play Music'}
        </button>
      )}

      <audio
        ref={audioRef}
        loop
        src="/assets/star-wars-theme.mp3"
      />
    </div>
  );
}
