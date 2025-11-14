// Guardian One iOS App
// Main app entry point
// Built by Pixel (iOS Agent) - Day 2

import SwiftUI

@main
struct GuardianOneApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    // Request location permissions on launch
                    appState.locationService.requestAuthorization()
                }
        }
    }
}

/// Global app state manager
/// Handles location, ADS-B, authentication, and subscription state
class AppState: ObservableObject {
    // Core services
    @Published var locationService = LocationService()
    @Published var adsbService: ADSBService?
    @Published var authService = AuthService()

    // User state
    @Published var isAuthenticated = false
    @Published var subscriptionTier: SubscriptionTier = .free
    @Published var currentUser: User?

    // Flight state
    @Published var isFlying = false
    @Published var currentFlight: Flight?

    init() {
        // Check for existing authentication
        if let token = KeychainHelper.loadToken() {
            isAuthenticated = true
            // Validate token and load user
            Task {
                await validateSession(token: token)
            }
        }
    }

    private func validateSession(token: String) async {
        // Validate JWT with backend
        // Load user profile and subscription tier
        // TODO: Implement in Day 3
    }
}

/// Subscription tiers
enum SubscriptionTier: String, Codable {
    case free = "free"
    case pro = "pro"
    case ultimate = "ultimate"

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .pro: return "Pro"
        case .ultimate: return "Ultimate"
        }
    }

    var hasADSB: Bool {
        self == .pro || self == .ultimate
    }

    var hasOCR: Bool {
        self == .ultimate
    }

    var aiQueriesPerMonth: Int {
        switch self {
        case .free: return 10
        case .pro: return 100
        case .ultimate: return Int.max // Unlimited
        }
    }
}

/// User model
struct User: Codable, Identifiable {
    let id: String
    let email: String?
    let subscriptionTier: SubscriptionTier
    let subscriptionExpiresAt: Date?
    let createdAt: Date
}

/// Flight model
struct Flight: Codable, Identifiable {
    let id: String
    var departureAirport: String?
    var arrivalAirport: String?
    var departureTime: Date?
    var arrivalTime: Date?
    var route: [RoutePoint]
    var engineData: [EngineDataPoint]
    var notes: String?

    struct RoutePoint: Codable {
        let latitude: Double
        let longitude: Double
        let altitude: Double // feet MSL
        let timestamp: Date
        let speed: Double // knots
    }

    struct EngineDataPoint: Codable {
        let timestamp: Date
        let oilPressure: Double? // PSI
        let oilTemperature: Double? // °F
        let cht: Double? // °F (cylinder head temp)
        let egt: Double? // °F (exhaust gas temp)
        let rpm: Double?
        let fuelQuantity: Double? // gallons
    }
}

// MARK: - Keychain Helper
/// Secure storage for JWT tokens
struct KeychainHelper {
    private static let tokenKey = "com.guardianone.jwt"

    static func saveToken(_ token: String) {
        let data = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary) // Delete existing
        SecItemAdd(query as CFDictionary, nil)
    }

    static func loadToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    static func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]

        SecItemDelete(query as CFDictionary)
    }
}
