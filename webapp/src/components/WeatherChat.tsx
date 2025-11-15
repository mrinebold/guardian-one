import { useState, useRef, useEffect } from 'react';
import type { WeatherMessage, Location } from '../types';

const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || '';

// Simple nearest airport lookup for common US locations
function getNearestAirport(location: Location | null): string | null {
  if (!location) return null;

  const { latitude, longitude } = location;

  // Austin, TX area
  if (latitude > 30.0 && latitude < 30.5 && longitude > -98.0 && longitude < -97.5) {
    return 'KAUS';
  }
  // Dallas, TX area
  if (latitude > 32.5 && latitude < 33.0 && longitude > -97.5 && longitude < -96.5) {
    return 'KDFW';
  }
  // Houston, TX area
  if (latitude > 29.5 && latitude < 30.0 && longitude > -95.5 && longitude < -95.0) {
    return 'KIAH';
  }

  return null; // Default to no auto-briefing if location unknown
}

interface WeatherChatProps {
  location?: Location | null;
}

export function WeatherChat({ location }: WeatherChatProps) {
  const [messages, setMessages] = useState<WeatherMessage[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [autoExecuted, setAutoExecuted] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    // Only auto-scroll if user has sent a message (more than just the auto-fetch)
    if (messages.length > 2) {
      scrollToBottom();
    }
  }, [messages]);

  // Auto-execute weather briefing when location is first detected
  useEffect(() => {
    console.log('🌤️ Weather auto-fetch check:', {
      hasLocation: !!location,
      autoExecuted,
      messageCount: messages.length,
      location
    });

    if (location && !autoExecuted && messages.length === 0) {
      const airport = getNearestAirport(location);
      console.log('✈️ Nearest airport detected:', airport);

      if (airport) {
        setAutoExecuted(true);

        // Add system message
        const systemMessage: WeatherMessage = {
          role: 'assistant',
          content: `📍 Location detected near ${airport}. Fetching current weather conditions... (this may take 5-10 seconds)`,
          timestamp: Date.now(),
        };
        setMessages([systemMessage]);
        setLoading(true);

        console.log('🔄 Starting weather fetch for:', airport);

        // Fetch weather with longer timeout (15 seconds)
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 15000);

        const apiUrl = `${BACKEND_URL}/api/coaching/weather-analysis`;
        console.log('📡 Weather API URL:', apiUrl);

        fetch(apiUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            departure_airport: airport,
            arrival_airport: airport,
          }),
          signal: controller.signal,
        })
          .then(res => {
            clearTimeout(timeoutId);
            console.log('📥 Weather API response status:', res.status);
            if (!res.ok) throw new Error(`HTTP ${res.status}`);
            return res.json();
          })
          .then(data => {
            console.log('✅ Weather data received:', data);
            const weatherMessage: WeatherMessage = {
              role: 'assistant',
              content: `**${data.recommendation}**\n\n${data.reasoning}\n\n*Weather Summary:*\n${data.weather_summary}`,
              timestamp: Date.now(),
            };
            setMessages(prev => [...prev, weatherMessage]);
          })
          .catch((err) => {
            clearTimeout(timeoutId);
            console.error('❌ Weather fetch error:', err);
            const errorMessage: WeatherMessage = {
              role: 'assistant',
              content: err.name === 'AbortError'
                ? 'Weather request timed out. The weather API is taking longer than expected. Try asking manually: "Should I fly from KAUS to KAUS?"'
                : `Could not fetch automatic weather briefing: ${err.message}. You can ask me about weather conditions manually.`,
              timestamp: Date.now(),
            };
            setMessages(prev => [...prev, errorMessage]);
          })
          .finally(() => {
            setLoading(false);
            console.log('🏁 Weather fetch complete');
          });
      } else {
        console.log('⚠️ No airport found for location:', location);
      }
    }
  }, [location, autoExecuted, messages.length]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim() || loading) return;

    const userMessage: WeatherMessage = {
      role: 'user',
      content: input,
      timestamp: Date.now(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setInput('');
    setLoading(true);

    try {
      // Parse airport codes from input (match 3 or 4 letter codes like AUS or KAUS)
      const airportRegex = /\b[A-Z]{3,4}\b/g;
      const airports = input.match(airportRegex) || [];

      let requestBody;
      let endpoint;

      if (airports.length >= 1) {
        // Use weather analysis endpoint for any airport query
        requestBody = {
          departure_airport: airports[0],
          arrival_airport: airports[1] || airports[0], // Use same airport if only one provided
        };
        endpoint = `${BACKEND_URL}/api/coaching/weather-analysis`;
      } else {
        // General coaching chat for non-weather questions
        requestBody = {
          user_id: 'web-user',
          message: input,
        };
        endpoint = `${BACKEND_URL}/api/coaching/chat`;
      }

      const response = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      });

      if (!response.ok) throw new Error('Failed to get weather analysis');

      const data = await response.json();

      const assistantMessage: WeatherMessage = {
        role: 'assistant',
        content: airports.length >= 1
          ? `**${data.recommendation}**\n\n${data.reasoning}\n\n*Weather Summary:*\n${data.weather_summary}`
          : data.response,
        timestamp: Date.now(),
      };

      setMessages((prev) => [...prev, assistantMessage]);
    } catch (error) {
      const errorMessage: WeatherMessage = {
        role: 'assistant',
        content: 'Sorry, I encountered an error analyzing the weather. Please try again.',
        timestamp: Date.now(),
      };
      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setLoading(false);
    }
  };

  const getRecommendationColor = (content: string) => {
    if (content.includes('**GO**')) return 'text-aviation-green';
    if (content.includes('**NO-GO**')) return 'text-aviation-red';
    if (content.includes('**CAUTION**')) return 'text-aviation-yellow';
    return '';
  };

  return (
    <div className="bg-white rounded-lg shadow p-4 flex flex-col h-[600px]">
      <h2 className="text-xl font-bold mb-4 text-aviation-blue">AI Weather Briefing</h2>

      <div className="flex-1 overflow-y-auto mb-4 space-y-4">
        {messages.length === 0 && (
          <div className="text-gray-500 text-center py-8">
            Ask about weather conditions for your flight. Try:
            <br />
            "Should I fly from KAUS to KDAL today?"
          </div>
        )}

        {messages.map((msg, idx) => (
          <div
            key={idx}
            className={`p-3 rounded-lg ${
              msg.role === 'user'
                ? 'bg-blue-50 ml-8'
                : 'bg-gray-50 mr-8'
            }`}
          >
            <div className="font-semibold mb-1">
              {msg.role === 'user' ? 'You' : 'AI Weather Advisor'}
            </div>
            <div
              className={`whitespace-pre-wrap ${
                msg.role === 'assistant' ? getRecommendationColor(msg.content) : ''
              }`}
            >
              {msg.content}
            </div>
          </div>
        ))}

        {loading && (
          <div className="text-center text-gray-500">
            <div className="inline-block animate-pulse">Analyzing weather...</div>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>

      <form onSubmit={handleSubmit} className="flex gap-2">
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Ask about weather conditions..."
          className="flex-1 px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-aviation-blue"
          disabled={loading}
        />
        <button
          type="submit"
          disabled={loading || !input.trim()}
          className="px-6 py-2 bg-aviation-blue text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Send
        </button>
      </form>
    </div>
  );
}
