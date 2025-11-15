import { useEffect, useRef } from 'react';
import L from 'leaflet';
import type { Location } from '../types';
import 'leaflet/dist/leaflet.css';

// Fix for default marker icon
import icon from 'leaflet/dist/images/marker-icon.png';
import iconShadow from 'leaflet/dist/images/marker-shadow.png';

let DefaultIcon = L.icon({
  iconUrl: icon,
  shadowUrl: iconShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});

L.Marker.prototype.options.icon = DefaultIcon;

interface MapProps {
  location: Location | null;
}

export function Map({ location }: MapProps) {
  const mapRef = useRef<L.Map | null>(null);
  const markerRef = useRef<L.Marker | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current || mapRef.current) return;

    // Initialize map
    const map = L.map(containerRef.current).setView([39.8283, -98.5795], 4);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors',
    }).addTo(map);

    mapRef.current = map;

    return () => {
      if (mapRef.current) {
        mapRef.current.remove();
        mapRef.current = null;
      }
    };
  }, []);

  useEffect(() => {
    if (!mapRef.current || !location) return;

    const { latitude, longitude } = location;

    // Update or create marker
    if (markerRef.current) {
      markerRef.current.setLatLng([latitude, longitude]);
    } else {
      markerRef.current = L.marker([latitude, longitude])
        .addTo(mapRef.current)
        .bindPopup('Current Location');
    }

    // Center map on location
    mapRef.current.setView([latitude, longitude], 13);
  }, [location]);

  return (
    <div className="bg-white rounded-lg shadow p-4">
      <h2 className="text-xl font-bold mb-4 text-aviation-blue">GPS Tracking</h2>
      <div ref={containerRef} className="h-96 rounded" />
      {location && (
        <div className="mt-4 grid grid-cols-2 gap-2 text-sm">
          <div>
            <span className="font-semibold">Latitude:</span> {location.latitude.toFixed(6)}°
          </div>
          <div>
            <span className="font-semibold">Longitude:</span> {location.longitude.toFixed(6)}°
          </div>
          <div>
            <span className="font-semibold">Altitude:</span>{' '}
            {location.altitude ? `${Math.round(location.altitude * 3.28084)} ft` : 'N/A'}
          </div>
          <div>
            <span className="font-semibold">Speed:</span>{' '}
            {location.speed ? `${Math.round(location.speed * 1.94384)} kts` : 'N/A'}
          </div>
        </div>
      )}
    </div>
  );
}
