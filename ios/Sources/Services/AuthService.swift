// AuthService.swift
// Authentication service for Apple Sign-In and backend communication
// Built by Pixel (iOS Agent) - Day 3
// TODO: Implement full Apple Sign-In flow

import Foundation
import AuthenticationServices
import Combine

/// Authentication service
/// Handles Apple Sign-In and JWT token management
class AuthService: ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var authError: String?

    // MARK: - Private Properties
    private let baseURL = "http://localhost:8000" // TODO: Change for production

    // MARK: - Public Methods

    /// Sign in with Apple
    /// - Parameter authorization: Apple authorization result
    func signInWithApple(authorization: ASAuthorization) async throws {
        // TODO (Day 3): Implement Apple Sign-In flow
        // 1. Extract identity token and authorization code
        // 2. Send to backend /api/auth/apple-signin
        // 3. Receive JWT token
        // 4. Store token in Keychain
        // 5. Load user profile

        // Mock implementation for M2 development
        print("🔐 Apple Sign-In (mock)")
        KeychainHelper.saveToken("mock_jwt_token")
        isAuthenticated = true
    }

    /// Sign out user
    func signOut() {
        KeychainHelper.deleteToken()
        isAuthenticated = false
        currentUser = nil
        print("👋 Signed out")
    }

    /// Validate existing session
    func validateSession() async throws {
        // TODO (Day 3): Validate JWT with backend
        // If token expired, refresh or sign out
        guard let token = KeychainHelper.loadToken() else {
            isAuthenticated = false
            return
        }

        // Mock validation
        isAuthenticated = true
        print("✅ Session valid")
    }
}
