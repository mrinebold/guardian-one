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
    @EnvironmentObject var appState: AppState
    @StateObject private var flightService = FlightService()

    @State private var showingNewFlight = false
    @State private var isRefreshing = false

    var body: some View {
        NavigationView {
            Group {
                if flightService.flights.isEmpty && !flightService.isLoading {
                    emptyStateView
                } else {
                    flightListView
                }
            }
            .navigationTitle("Logbook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewFlight = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewFlight) {
                NewFlightView(flightService: flightService)
            }
            .onAppear {
                loadFlights()
            }
        }
    }

    // MARK: - Flight List

    private var flightListView: some View {
        List {
            if flightService.isLoading {
                ProgressView("Loading flights...")
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(flightService.flights) { flight in
                    NavigationLink(destination: FlightDetailView(flight: flight, flightService: flightService)) {
                        FlightRowView(flight: flight)
                    }
                }
                .onDelete(perform: deleteFlight)
            }
        }
        .refreshable {
            await refreshFlights()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Flights Yet")
                .font(.headline)

            Text("Tap + to create your first flight log")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Create Flight") {
                showingNewFlight = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Actions

    private func loadFlights() {
        Task {
            do {
                _ = try await flightService.getFlights()
            } catch {
                print("❌ Failed to load flights: \(error)")
            }
        }
    }

    private func refreshFlights() async {
        do {
            _ = try await flightService.getFlights()
        } catch {
            print("❌ Failed to refresh flights: \(error)")
        }
    }

    private func deleteFlight(at offsets: IndexSet) {
        for index in offsets {
            let flight = flightService.flights[index]
            Task {
                do {
                    try await flightService.deleteFlight(flightId: flight.id)
                } catch {
                    print("❌ Failed to delete flight: \(error)")
                }
            }
        }
    }
}

// MARK: - Flight Row View

struct FlightRowView: View {
    let flight: Flight

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Route
            HStack {
                if let departure = flight.departureAirport {
                    Text(departure)
                        .font(.headline)
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let arrival = flight.arrivalAirport {
                    Text(arrival)
                        .font(.headline)
                } else if flight.departureAirport == nil {
                    Text("Local Flight")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(flight.aircraftType)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(4)
            }

            // Date and duration
            HStack {
                Text(flight.departureTime.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let duration = flight.durationMinutes {
                    Text("•")
                        .foregroundColor(.secondary)
                    Text("\(duration) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Notes preview
            if let notes = flight.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Flight Detail View

struct FlightDetailView: View {
    let flight: Flight
    @ObservedObject var flightService: FlightService

    @State private var showingEngineEntry = false

    var body: some View {
        List {
            Section("Flight Information") {
                if let departure = flight.departureAirport {
                    HStack {
                        Text("Departure")
                        Spacer()
                        Text(departure)
                            .foregroundColor(.secondary)
                    }
                }

                if let arrival = flight.arrivalAirport {
                    HStack {
                        Text("Arrival")
                        Spacer()
                        Text(arrival)
                            .foregroundColor(.secondary)
                    }
                }

                HStack {
                    Text("Aircraft")
                    Spacer()
                    Text(flight.aircraftType)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Date")
                    Spacer()
                    Text(flight.departureTime.formatted(date: .long, time: .shortened))
                        .foregroundColor(.secondary)
                }

                if let duration = flight.durationMinutes {
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text("\(duration) minutes")
                            .foregroundColor(.secondary)
                    }
                }
            }

            if let notes = flight.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                }
            }

            Section("Engine Parameters") {
                Button {
                    showingEngineEntry = true
                } label: {
                    Label("Log Engine Data", systemImage: "gauge")
                }

                NavigationLink(destination: EngineTrendView(flightService: flightService, flight: flight)) {
                    Label("View Trends", systemImage: "chart.line.uptrend.xyaxis")
                }
            }
        }
        .navigationTitle("Flight Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEngineEntry) {
            EngineDataEntryView(flightService: flightService, flight: flight)
        }
    }
}

// MARK: - New Flight View

struct NewFlightView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var flightService: FlightService

    @State private var departureAirport = ""
    @State private var arrivalAirport = ""
    @State private var aircraftType = "C172"
    @State private var notes = ""

    @State private var isCreating = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Route")) {
                    TextField("Departure Airport (ICAO)", text: $departureAirport)
                        .autocapitalization(.allCharacters)

                    TextField("Arrival Airport (ICAO)", text: $arrivalAirport)
                        .autocapitalization(.allCharacters)
                }

                Section(header: Text("Aircraft")) {
                    TextField("Aircraft Type", text: $aircraftType)
                        .autocapitalization(.allCharacters)
                }

                Section(header: Text("Notes (Optional)")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }

                Section {
                    Button(action: createFlight) {
                        HStack {
                            if isCreating {
                                ProgressView()
                                Text("Creating...")
                            } else {
                                Text("Create Flight Log")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(aircraftType.isEmpty || isCreating)
                }
            }
            .navigationTitle("New Flight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Flight Log", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("✅") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func createFlight() {
        isCreating = true

        Task {
            do {
                _ = try await flightService.createFlight(
                    departureAirport: departureAirport.isEmpty ? nil : departureAirport.uppercased(),
                    arrivalAirport: arrivalAirport.isEmpty ? nil : arrivalAirport.uppercased(),
                    aircraftType: aircraftType.uppercased(),
                    notes: notes.isEmpty ? nil : notes
                )

                DispatchQueue.main.async {
                    isCreating = false
                    alertMessage = "✅ Flight log created"
                    showAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    isCreating = false
                    alertMessage = "❌ Failed to create flight: \(error.localizedDescription)"
                    showAlert = true
                }
            }
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
