export interface Location {
  latitude: number;
  longitude: number;
  altitude: number | null;
  accuracy: number;
  speed: number | null;
  heading: number | null;
  timestamp: number;
}

export interface Flight {
  id: string;
  user_id: string;
  departure_airport: string | null;
  arrival_airport: string | null;
  aircraft_type: string;
  departure_time: string;
  arrival_time: string | null;
  duration_minutes: number | null;
  notes: string | null;
  created_at: string;
  engine_params?: EngineParams;
}

export interface EngineParams {
  oil_temp_f: number;
  oil_pressure_psi: number;
  cht_f: number;
  egt_f: number;
  fuel_flow_gph: number;
  manifold_pressure_inhg: number;
}

export interface WeatherMessage {
  role: 'user' | 'assistant';
  content: string;
  timestamp: number;
}

export interface WeatherAnalysis {
  recommendation: 'GO' | 'NO-GO' | 'CAUTION';
  reasoning: string;
  weather_data: string;
}
