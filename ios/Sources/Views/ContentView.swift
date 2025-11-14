// ContentView.swift
// Main app navigation and tab bar
// Built by Pixel (iOS Agent) - Day 2

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        if appState.isAuthenticated {
            // Main app interface
            TabView(selection: $selectedTab) {
                // Map tab - Primary navigation view
                MapView()
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                    .tag(0)

                // Flight Plan tab
                FlightPlanView()
                    .tabItem {
                        Label("Plan", systemImage: "airplane")
                    }
                    .tag(1)

                // AI Coaching tab
                AICoachingView()
                    .tabItem {
                        Label("AI", systemImage: "brain")
                    }
                    .tag(2)

                // Flight Log tab
                FlightLogView()
                    .tabItem {
                        Label("Log", systemImage: "book")
                    }
                    .tag(3)

                // Settings tab
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(4)
            }
            .accentColor(.blue)
        } else {
            // Sign-in view
            SignInView()
        }
    }
}

// MARK: - Sign-In View
struct SignInView: View {
    @EnvironmentObject var appState: AppState
    @State private var isSigningIn = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // App logo and title
            Image(systemName: "shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("Guardian One")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("AI-Powered Cockpit Safety Companion")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            // Sign in with Apple button
            SignInWithAppleButton(isSigningIn: $isSigningIn) {
                // Handle successful sign-in
                appState.isAuthenticated = true
            }
            .frame(height: 50)
            .padding(.horizontal, 40)

            Text("Free tier includes GPS navigation and 10 AI coaching questions per month")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
        }
    }
}

// MARK: - Placeholder Views (To be implemented in Days 3-9)

struct MapView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ZStack {
                // TODO: Implement MapKit view with sectional overlay
                Color.gray.opacity(0.2)

                VStack {
                    if let location = appState.locationService.currentLocation {
                        Text("GPS Active")
                            .font(.headline)
                            .foregroundColor(.green)

                        Text(String(format: "%.4f, %.4f",
                                  location.coordinate.latitude,
                                  location.coordinate.longitude))
                            .font(.subheadline)
                            .monospaced()

                        Text(String(format: "%.0f ft MSL | %.1f kts",
                                  appState.locationService.altitude,
                                  appState.locationService.speed))
                            .font(.subheadline)
                            .monospaced()
                    } else {
                        Text("GPS Acquiring...")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FlightPlanView: View {
    var body: some View {
        NavigationView {
            Text("Flight Planning")
                .navigationTitle("Plan")
        }
    }
}

struct AICoachingView: View {
    var body: some View {
        NavigationView {
            Text("AI Safety Coaching")
                .navigationTitle("AI Coach")
        }
    }
}

struct FlightLogView: View {
    var body: some View {
        NavigationView {
            Text("Flight Logs")
                .navigationTitle("Logbook")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    if let user = appState.currentUser {
                        Text("Email: \(user.email ?? "N/A")")
                    }

                    HStack {
                        Text("Subscription")
                        Spacer()
                        Text(appState.subscriptionTier.displayName)
                            .foregroundColor(.secondary)
                    }
                }

                Section("App") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (M2 Sprint)")
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        KeychainHelper.deleteToken()
                        appState.isAuthenticated = false
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Sign In with Apple Button
struct SignInWithAppleButton: View {
    @Binding var isSigningIn: Bool
    var onSuccess: () -> Void

    var body: some View {
        Button(action: {
            isSigningIn = true
            // TODO: Implement Apple Sign-In (Day 3)
            // For M2 demo, we'll simulate successful sign-in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isSigningIn = false
                onSuccess()
            }
        }) {
            HStack {
                Image(systemName: "applelogo")
                Text(isSigningIn ? "Signing In..." : "Sign in with Apple")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(isSigningIn)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(AppState())
}
