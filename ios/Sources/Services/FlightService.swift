// FlightService.swift
// Flight logging and engine parameter tracking service
// Built by Pixel (iOS Agent) - Day 8-9
// Requirement: Dustin's Feature #3 (Engine Parameter Trend Analysis)

import Foundation
import Combine

/// Flight logging service
/// Communicates with backend for flight logs and engine parameter tracking
class FlightService: ObservableObject {
    // MARK: - Published Properties
    @Published var flights: [Flight] = []
    @Published var currentFlight: Flight?
    @Published var isLoading = false
    @Published var error: String?

    // MARK: - Private Properties
    private let baseURL: String
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(baseURL: String = "http://localhost:8000") {
        self.baseURL = baseURL
    }

    // MARK: - Public Methods

    /// Create new flight log
    /// - Parameters:
    ///   - departureAirport: Departure ICAO code (optional)
    ///   - arrivalAirport: Arrival ICAO code (optional)
    ///   - aircraftType: Aircraft type (e.g., "C172")
    ///   - notes: Optional flight notes
    /// - Returns: Created flight
    func createFlight(
        departureAirport: String?,
        arrivalAirport: String?,
        aircraftType: String,
        notes: String? = nil
    ) async throws -> Flight {
        isLoading = true
        error = nil

        defer { isLoading = false }

        let url = URL(string: "\(baseURL)/api/flights")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any?] = [
            "departure_airport": departureAirport,
            "arrival_airport": arrivalAirport,
            "aircraft_type": aircraftType,
            "departure_time": ISO8601DateFormatter().string(from: Date()),
            "notes": notes
        ]

        let cleanedBody = requestBody.compactMapValues { $0 }
        request.httpBody = try JSONSerialization.data(withJSONObject: cleanedBody)

        print("✈️ Creating flight log...")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw FlightError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let flight = try decoder.decode(Flight.self, from: data)

        DispatchQueue.main.async {
            self.currentFlight = flight
            self.flights.insert(flight, at: 0)
        }

        print("✅ Flight log created: \(flight.id)")

        return flight
    }

    /// Add engine parameter data point to flight
    /// - Parameters:
    ///   - flightId: Flight ID
    ///   - data: Engine data point
    func addEngineData(flightId: String, data: EngineDataPoint) async throws {
        isLoading = true
        error = nil

        defer { isLoading = false }

        let url = URL(string: "\(baseURL)/api/flights/\(flightId)/engine-data")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(data)

        print("📊 Adding engine data to flight \(flightId)...")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw FlightError.invalidResponse
        }

        print("✅ Engine data recorded")
    }

    /// Get engine parameter trends for a flight
    /// - Parameter flightId: Flight ID
    /// - Returns: Array of trend data
    func getEngineTrends(flightId: String) async throws -> [EngineTrend] {
        isLoading = true
        error = nil

        defer { isLoading = false }

        let url = URL(string: "\(baseURL)/api/flights/\(flightId)/trends")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        print("📈 Fetching engine trends for flight \(flightId)...")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw FlightError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let trends = try decoder.decode([EngineTrend].self, from: data)

        print("✅ Retrieved \(trends.count) trend series")

        return trends
    }

    /// Get user's flight logs
    /// - Parameter limit: Maximum number of flights to return
    /// - Returns: Array of flights
    func getFlights(limit: Int = 20) async throws -> [Flight] {
        isLoading = true
        error = nil

        defer { isLoading = false }

        // TODO: Get actual user ID from auth service
        let userId = "mock_user_id"

        let url = URL(string: "\(baseURL)/api/flights?user_id=\(userId)&limit=\(limit)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        print("📚 Fetching flight logs...")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw FlightError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let responseObj = try decoder.decode(FlightsResponse.self, from: data)

        DispatchQueue.main.async {
            self.flights = responseObj.flights
        }

        print("✅ Retrieved \(responseObj.flights.count) flights")

        return responseObj.flights
    }

    /// Delete a flight log
    /// - Parameter flightId: Flight ID to delete
    func deleteFlight(flightId: String) async throws {
        isLoading = true
        error = nil

        defer { isLoading = false }

        let url = URL(string: "\(baseURL)/api/flights/\(flightId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw FlightError.invalidResponse
        }

        DispatchQueue.main.async {
            self.flights.removeAll { $0.id == flightId }
            if self.currentFlight?.id == flightId {
                self.currentFlight = nil
            }
        }

        print("🗑️ Flight deleted: \(flightId)")
    }
}

// MARK: - Models

/// Engine parameter data point (matches backend model)
struct EngineDataPoint: Codable {
    let timestamp: Date
    let oilPressure: Double?
    let oilTemperature: Double?
    let cht: Double?
    let egt: Double?
    let rpm: Double?
    let fuelQuantity: Double?

    init(
        timestamp: Date = Date(),
        oilPressure: Double? = nil,
        oilTemperature: Double? = nil,
        cht: Double? = nil,
        egt: Double? = nil,
        rpm: Double? = nil,
        fuelQuantity: Double? = nil
    ) {
        self.timestamp = timestamp
        self.oilPressure = oilPressure
        self.oilTemperature = oilTemperature
        self.cht = cht
        self.egt = egt
        self.rpm = rpm
        self.fuelQuantity = fuelQuantity
    }
}

/// Engine parameter trend data
struct EngineTrend: Codable, Identifiable {
    let id = UUID()
    let parameter: String
    let values: [Double]
    let timestamps: [Date]
    let average: Double
    let trend: String // "stable", "increasing", "decreasing"
    let alert: String?

    enum CodingKeys: String, CodingKey {
        case parameter, values, timestamps, average, trend, alert
    }
}

/// Flights response wrapper
struct FlightsResponse: Codable {
    let flights: [Flight]
    let total: Int
}

/// Flight service errors
enum FlightError: LocalizedError {
    case invalidResponse
    case httpError(Int)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code):
            return "Server error: HTTP \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
