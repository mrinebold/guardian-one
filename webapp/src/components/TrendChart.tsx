import { useState, useEffect } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import type { Flight } from '../types';

const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || '';

interface TrendData {
  date: string;
  oil_temp: number;
  oil_pressure: number;
  cht: number;
  egt: number;
}

export function TrendChart() {
  const [trendData, setTrendData] = useState<TrendData[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedParam, setSelectedParam] = useState<'oil_temp' | 'oil_pressure' | 'cht' | 'egt'>('cht');

  useEffect(() => {
    fetchTrendData();
  }, []);

  const fetchTrendData = async () => {
    try {
      const response = await fetch(`${BACKEND_URL}/api/flights?user_id=mock_user_id`);
      if (!response.ok) throw new Error('Failed to fetch flights');
      const result = await response.json();
      const flights: Flight[] = result.flights || [];

      // Get last 10 flights and format for chart
      const last10 = flights.slice(-10);

      // Filter only flights with engine_params
      const flightsWithParams = last10.filter(flight => flight.engine_params);

      const data = flightsWithParams.map((flight) => ({
        date: new Date(flight.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
        oil_temp: flight.engine_params.oil_temp_f,
        oil_pressure: flight.engine_params.oil_pressure_psi,
        cht: flight.engine_params.cht_f,
        egt: flight.engine_params.egt_f,
      }));

      setTrendData(data);
    } catch (error) {
      console.error('Error fetching trend data:', error);
    } finally {
      setLoading(false);
    }
  };

  const paramConfig = {
    oil_temp: {
      label: 'Oil Temperature',
      dataKey: 'oil_temp',
      color: '#dc2626',
      unit: '°F',
      normal: { min: 140, max: 220 },
    },
    oil_pressure: {
      label: 'Oil Pressure',
      dataKey: 'oil_pressure',
      color: '#1e40af',
      unit: 'psi',
      normal: { min: 30, max: 60 },
    },
    cht: {
      label: 'Cylinder Head Temp',
      dataKey: 'cht',
      color: '#16a34a',
      unit: '°F',
      normal: { min: 200, max: 450 },
    },
    egt: {
      label: 'Exhaust Gas Temp',
      dataKey: 'egt',
      color: '#fbbf24',
      unit: '°F',
      normal: { min: 1200, max: 1550 },
    },
  };

  const config = paramConfig[selectedParam];

  if (loading) {
    return (
      <div className="bg-white rounded-lg shadow p-4">
        <div className="text-center text-gray-500">Loading trend data...</div>
      </div>
    );
  }

  if (trendData.length < 2) {
    return (
      <div className="bg-white rounded-lg shadow p-4">
        <h2 className="text-xl font-bold mb-4 text-aviation-blue">Engine Trend Analysis</h2>
        <div className="text-gray-500 text-center py-8">
          Need at least 2 flights to show trends. Keep logging!
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow p-4">
      <h2 className="text-xl font-bold mb-4 text-aviation-blue">Engine Trend Analysis</h2>

      <div className="flex gap-2 mb-4">
        {(Object.keys(paramConfig) as Array<keyof typeof paramConfig>).map((key) => (
          <button
            key={key}
            onClick={() => setSelectedParam(key)}
            className={`px-4 py-2 rounded transition ${
              selectedParam === key
                ? 'bg-aviation-blue text-white'
                : 'bg-gray-100 hover:bg-gray-200'
            }`}
          >
            {paramConfig[key].label}
          </button>
        ))}
      </div>

      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={trendData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="date" />
          <YAxis
            domain={[config.normal.min - 20, config.normal.max + 20]}
            label={{ value: config.unit, angle: -90, position: 'insideLeft' }}
          />
          <Tooltip />
          <Legend />
          <Line
            type="monotone"
            dataKey={config.dataKey}
            stroke={config.color}
            strokeWidth={2}
            name={config.label}
          />
          <Line
            type="monotone"
            dataKey={() => config.normal.max}
            stroke="#ef4444"
            strokeDasharray="5 5"
            name="Max Normal"
            dot={false}
          />
          <Line
            type="monotone"
            dataKey={() => config.normal.min}
            stroke="#3b82f6"
            strokeDasharray="5 5"
            name="Min Normal"
            dot={false}
          />
        </LineChart>
      </ResponsiveContainer>

      <div className="mt-4 text-sm text-gray-600">
        Normal range: {config.normal.min} - {config.normal.max} {config.unit}
      </div>
    </div>
  );
}
