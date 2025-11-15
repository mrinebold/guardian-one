import { useState, useEffect } from 'react';
import type { Flight } from '../types';

const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || '';

export function FlightList() {
  const [flights, setFlights] = useState<Flight[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchFlights();
  }, []);

  const fetchFlights = async () => {
    try {
      const response = await fetch(`${BACKEND_URL}/api/flights?user_id=mock_user_id`);
      if (!response.ok) throw new Error('Failed to fetch flights');
      const data = await response.json();
      setFlights(data.flights || []);
    } catch (error) {
      console.error('Error fetching flights:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="bg-white rounded-lg shadow p-4">
        <div className="text-center text-gray-500">Loading flights...</div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow p-4">
      <h2 className="text-xl font-bold mb-4 text-aviation-blue">Flight Log</h2>

      {flights.length === 0 ? (
        <div className="text-gray-500 text-center py-8">
          No flights logged yet. Add your first flight below!
        </div>
      ) : (
        <div className="space-y-4">
          {flights.map((flight) => (
            <div
              key={flight.id}
              className="border rounded-lg p-4 hover:bg-gray-50 transition"
            >
              <div className="flex justify-between items-start mb-2">
                <div>
                  <div className="font-semibold text-lg">
                    {flight.departure_airport || 'N/A'} → {flight.arrival_airport || 'N/A'}
                  </div>
                  <div className="text-sm text-gray-600">
                    {new Date(flight.departure_time).toLocaleDateString()}
                    {flight.duration_minutes && ` • ${flight.duration_minutes} min`}
                  </div>
                </div>
                <div className="text-right text-sm text-gray-600">
                  {flight.aircraft_type}
                  {flight.notes && (
                    <div className="text-xs text-gray-500 mt-1">{flight.notes.split(',')[0]}</div>
                  )}
                </div>
              </div>

              {flight.engine_params && (
                <div className="grid grid-cols-3 gap-2 text-sm mt-3 pt-3 border-t">
                  <div>
                    <span className="text-gray-600">Oil Temp:</span>{' '}
                    <span className="font-semibold">{flight.engine_params.oil_temp_f}°F</span>
                  </div>
                  <div>
                    <span className="text-gray-600">Oil Press:</span>{' '}
                    <span className="font-semibold">{flight.engine_params.oil_pressure_psi} psi</span>
                  </div>
                  <div>
                    <span className="text-gray-600">CHT:</span>{' '}
                    <span className="font-semibold">{flight.engine_params.cht_f}°F</span>
                  </div>
                  <div>
                    <span className="text-gray-600">EGT:</span>{' '}
                    <span className="font-semibold">{flight.engine_params.egt_f}°F</span>
                  </div>
                  <div>
                    <span className="text-gray-600">Fuel Flow:</span>{' '}
                    <span className="font-semibold">{flight.engine_params.fuel_flow_gph} gph</span>
                  </div>
                  <div>
                    <span className="text-gray-600">MP:</span>{' '}
                    <span className="font-semibold">{flight.engine_params.manifold_pressure_inhg}"</span>
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
