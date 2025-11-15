import { useState, useEffect, useRef } from 'react';
import { Starfield } from './Starfield';
import { dustinCrawl } from '../content/crawl-dustin';

interface StarWarsCrawlProps {
  onComplete: () => void;
}

export function StarWarsCrawl({ onComplete }: StarWarsCrawlProps) {
  const [showTitle, setShowTitle] = useState(true);
  const [showCrawl, setShowCrawl] = useState(false);
  const [audioPlaying, setAudioPlaying] = useState(true);
  const audioRef = useRef<HTMLAudioElement>(null);

  useEffect(() => {
    // Auto-play music on mount
    if (audioRef.current) {
      audioRef.current.play().catch(error => {
        console.log('Auto-play prevented:', error);
        setAudioPlaying(false);
      });
    }

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

      <button
        onClick={toggleAudio}
        className="audio-button"
      >
        {audioPlaying ? '🔇 Mute Music' : '🔊 Play Music'}
      </button>

      <audio
        ref={audioRef}
        loop
        src="/assets/star-wars-theme.mp3"
      />
    </div>
  );
}
