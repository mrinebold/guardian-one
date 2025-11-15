import { useState, useEffect } from 'react';
import type { Location } from '../types';

export function useGeolocation() {
  const [location, setLocation] = useState<Location | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    console.log('📍 GPS: useGeolocation hook initialized');

    if (!navigator.geolocation) {
      console.error('❌ GPS: Geolocation not supported by browser');
      setError('Geolocation is not supported by your browser');
      return;
    }

    console.log('✅ GPS: Browser supports geolocation, starting watchPosition...');

    const watchId = navigator.geolocation.watchPosition(
      (position) => {
        console.log('✅ GPS: Position acquired:', {
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          altitude: position.coords.altitude,
          accuracy: position.coords.accuracy,
          speed: position.coords.speed,
          timestamp: new Date(position.timestamp).toISOString()
        });

        setLocation({
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          altitude: position.coords.altitude,
          accuracy: position.coords.accuracy,
          speed: position.coords.speed,
          heading: position.coords.heading,
          timestamp: position.timestamp,
        });
        setError(null);

        console.log('✅ GPS: Location state updated');
      },
      (err) => {
        console.error('❌ GPS: Geolocation error:', {
          code: err.code,
          message: err.message,
          PERMISSION_DENIED: err.code === 1,
          POSITION_UNAVAILABLE: err.code === 2,
          TIMEOUT: err.code === 3
        });
        setError(err.message);
      },
      {
        enableHighAccuracy: true,
        timeout: 5000,
        maximumAge: 0,
      }
    );

    console.log('📍 GPS: watchPosition started with ID:', watchId);

    return () => {
      console.log('📍 GPS: Cleaning up watchPosition:', watchId);
      navigator.geolocation.clearWatch(watchId);
    };
  }, []);

  return { location, error };
}
