// WeatherService.swift
// Backend API client for AI weather analysis
// Built by Pixel (iOS Agent) - Day 6-7
// Requirement: Dustin's Feature #2 (AI Weather Decision Support)

import Foundation
import Combine

/// Weather analysis service
/// Communicates with Guardian One backend for AI weather recommendations
class WeatherService: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var lastAnalysis: WeatherAnalysis?
    @Published var error: String?

    // MARK: - Private Properties
    private let baseURL: String
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(baseURL: String = "http://localhost:8000") {
        // TODO: Change to production URL for TestFlight/App Store
        self.baseURL = baseURL
    }

    // MARK: - Public Methods

    /// Request AI weather analysis
    /// - Parameters:
    ///   - departure: Departure airport ICAO code
    ///   - arrival: Arrival airport ICAO code
    ///   - fuelRemaining: Fuel in gallons (optional)
    ///   - pilotHours: Pilot experience hours (optional)
    ///   - aircraftType: Aircraft type (optional)
    ///   - customQuestion: Custom question (optional)
    /// - Returns: Publisher with weather analysis
    func analyzeWeather(
        departure: String,
        arrival: String,
        fuelRemaining: Double? = nil,
        pilotHours: Int? = nil,
        aircraftType: String? = nil,
        customQuestion: String? = nil
    ) async throws -> WeatherAnalysis {

        isLoading = true
        error = nil

        defer { isLoading = false }

        // Build request
        let url = URL(string: "\(baseURL)/api/coaching/weather-analysis")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Request body
        let requestBody: [String: Any?] = [
            "departure_airport": departure,
            "arrival_airport": arrival,
            "fuel_remaining": fuelRemaining,
            "pilot_experience_hours": pilotHours,
            "aircraft_type": aircraftType,
            "custom_question": customQuestion
        ]

        // Remove nil values
        let cleanedBody = requestBody.compactMapValues { $0 }
        request.httpBody = try JSONSerialization.data(withJSONObject: cleanedBody)

        print("📡 Requesting AI weather analysis: \(departure) → \(arrival)")
        let startTime = Date()

        // Make request
        let (data, response) = try await URLSession.shared.data(for: request)

        // Check response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            print("❌ Weather API error: HTTP \(httpResponse.statusCode)")
            throw WeatherError.httpError(httpResponse.statusCode)
        }

        // Parse response
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let analysis = try decoder.decode(WeatherAnalysis.self, from: data)

        // Calculate response time
        let elapsed = Date().timeIntervalSince(startTime)
        print("✅ Weather analysis received in \(String(format: "%.2f", elapsed))s")

        // Warn if exceeds Dustin's 3-second requirement
        if elapsed > 3.0 {
            print("⚠️ Response time \(String(format: "%.2f", elapsed))s exceeds 3-second target!")
        }

        // Update state
        DispatchQueue.main.async {
            self.lastAnalysis = analysis
        }

        return analysis
    }

    /// Send general AI coaching question
    /// - Parameters:
    ///   - message: User's question
    ///   - context: Optional flight context
    /// - Returns: AI response text
    func askCoachingQuestion(message: String, context: [String: Any]? = nil) async throws -> String {
        isLoading = true
        error = nil

        defer { isLoading = false }

        let url = URL(string: "\(baseURL)/api/coaching/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any?] = [
            "user_id": "mock_user_id", // TODO: Get from auth service
            "message": message,
            "context": context
        ]

        let cleanedBody = requestBody.compactMapValues { $0 }
        request.httpBody = try JSONSerialization.data(withJSONObject: cleanedBody)

        print("💬 Asking AI: \(message.prefix(50))...")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WeatherError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let chatResponse = try decoder.decode(ChatResponse.self, from: data)

        print("✅ AI response received")

        return chatResponse.response
    }
}

// MARK: - Models

/// Weather analysis response from AI
struct WeatherAnalysis: Codable {
    let recommendation: String // "GO", "NO-GO", "WAIT", "DIVERT"
    let reasoning: String
    let weatherSummary: String
    let hazards: [String]
    let alternatives: [String]
    let confidence: String // "High", "Medium", "Low"
    let responseTimeMs: Int

    /// Color for recommendation badge
    var recommendationColor: String {
        switch recommendation.uppercased() {
        case "GO":
            return "green"
        case "NO-GO":
            return "red"
        case "WAIT":
            return "orange"
        case "DIVERT":
            return "yellow"
        default:
            return "gray"
        }
    }
}

/// Chat response from AI
struct ChatResponse: Codable {
    let response: String
    let responseTimeMs: Int
}

/// Weather service errors
enum WeatherError: LocalizedError {
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
