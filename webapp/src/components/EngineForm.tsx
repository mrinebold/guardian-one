import { useState } from 'react';
import type { EngineParams } from '../types';

const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || '';

interface EngineFormProps {
  onFlightAdded: () => void;
}

export function EngineForm({ onFlightAdded }: EngineFormProps) {
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    date: new Date().toISOString().split('T')[0],
    departure: '',
    destination: '',
    aircraft_type: 'C172N',
    tail_number: '',
    duration_minutes: 60,
    oil_temp_f: 180,
    oil_pressure_psi: 55,
    cht_f: 380,
    egt_f: 1350,
    fuel_flow_gph: 8.5,
    manifold_pressure_inhg: 23,
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const engineParams: EngineParams = {
        oil_temp_f: formData.oil_temp_f,
        oil_pressure_psi: formData.oil_pressure_psi,
        cht_f: formData.cht_f,
        egt_f: formData.egt_f,
        fuel_flow_gph: formData.fuel_flow_gph,
        manifold_pressure_inhg: formData.manifold_pressure_inhg,
      };

      const response = await fetch(`${BACKEND_URL}/api/flights`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          departure_airport: formData.departure,
          arrival_airport: formData.destination,
          aircraft_type: formData.aircraft_type,
          departure_time: new Date(formData.date).toISOString(),
          notes: `Tail: ${formData.tail_number}, Duration: ${formData.duration_minutes}min, Engine: ${JSON.stringify(engineParams)}`,
        }),
      });

      if (!response.ok) throw new Error('Failed to add flight');

      // Reset form
      setFormData({
        ...formData,
        departure: '',
        destination: '',
        tail_number: '',
      });

      onFlightAdded();
    } catch (error) {
      console.error('Error adding flight:', error);
      alert('Failed to add flight. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="bg-white rounded-lg shadow p-4">
      <h2 className="text-xl font-bold mb-4 text-aviation-blue">Log New Flight</h2>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium mb-1">Date</label>
            <input
              type="date"
              value={formData.date}
              onChange={(e) => setFormData({ ...formData, date: e.target.value })}
              className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-aviation-blue"
              required
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Duration (min)</label>
            <input
              type="number"
              value={formData.duration_minutes}
              onChange={(e) => setFormData({ ...formData, duration_minutes: Number(e.target.value) })}
              className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-aviation-blue"
              required
            />
          </div>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium mb-1">Departure</label>
            <input
              type="text"
              value={formData.departure}
              onChange={(e) => setFormData({ ...formData, departure: e.target.value.toUpperCase() })}
              placeholder="KAUS"
              maxLength={4}
              className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-aviation-blue"
              required
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Destination</label>
            <input
              type="text"
              value={formData.destination}
              onChange={(e) => setFormData({ ...formData, destination: e.target.value.toUpperCase() })}
              placeholder="KDAL"
              maxLength={4}
              className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-aviation-blue"
              required
            />
          </div>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium mb-1">Aircraft Type</label>
            <input
              type="text"
              value={formData.aircraft_type}
              onChange={(e) => setFormData({ ...formData, aircraft_type: e.target.value })}
              className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-aviation-blue"
              required
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Tail Number</label>
            <input
              type="text"
              value={formData.tail_number}
              onChange={(e) => setFormData({ ...formData, tail_number: e.target.value.toUpperCase() })}
              placeholder="N12345"
              className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-aviation-blue"
              required
            />
          </div>
        </div>

        <div className="border-t pt-4">
          <h3 className="font-semibold mb-3">Engine Parameters</h3>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm mb-1">Oil Temp (°F)</label>
              <input
                type="number"
                value={formData.oil_temp_f}
                onChange={(e) => setFormData({ ...formData, oil_temp_f: Number(e.target.value) })}
                className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-aviation-blue"
                required
              />
            </div>
            <div>
              <label className="block text-sm mb-1">Oil Pressure (psi)</label>
              <input
                type="number"
                value={formData.oil_pressure_psi}
                onChange={(e) => setFormData({ ...formData, oil_pressure_psi: Number(e.target.value) })}
                className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-aviation-blue"
                required
              />
            </div>
            <div>
              <label className="block text-sm mb-1">CHT (°F)</label>
              <input
                type="number"
                value={formData.cht_f}
                onChange={(e) => setFormData({ ...formData, cht_f: Number(e.target.value) })}
                className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-aviation-blue"
                required
              />
            </div>
            <div>
              <label className="block text-sm mb-1">EGT (°F)</label>
              <input
                type="number"
                value={formData.egt_f}
                onChange={(e) => setFormData({ ...formData, egt_f: Number(e.target.value) })}
                className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-aviation-blue"
                required
              />
            </div>
            <div>
              <label className="block text-sm mb-1">Fuel Flow (gph)</label>
              <input
                type="number"
                step="0.1"
                value={formData.fuel_flow_gph}
                onChange={(e) => setFormData({ ...formData, fuel_flow_gph: Number(e.target.value) })}
                className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-aviation-blue"
                required
              />
            </div>
            <div>
              <label className="block text-sm mb-1">Manifold Pressure (")</label>
              <input
                type="number"
                step="0.1"
                value={formData.manifold_pressure_inhg}
                onChange={(e) => setFormData({ ...formData, manifold_pressure_inhg: Number(e.target.value) })}
                className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-aviation-blue"
                required
              />
            </div>
          </div>
        </div>

        <button
          type="submit"
          disabled={loading}
          className="w-full py-3 bg-aviation-green text-white rounded-lg font-semibold hover:bg-green-700 disabled:opacity-50"
        >
          {loading ? 'Adding Flight...' : 'Add Flight'}
        </button>
      </form>
    </div>
  );
}
