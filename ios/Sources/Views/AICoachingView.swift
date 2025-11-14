// AICoachingView.swift
// AI Safety Coaching Chat Interface
// Built by Pixel (iOS Agent) - Day 6-7
// Requirement: Dustin's Feature #2 - Weather analysis with reasoning

import SwiftUI

struct AICoachingView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var weatherService = WeatherService()

    // Weather analysis form
    @State private var departureAirport = ""
    @State private var arrivalAirport = ""
    @State private var fuelRemaining = ""
    @State private var customQuestion = ""

    // General chat
    @State private var chatMessages: [ChatMessage] = []
    @State private var currentMessage = ""

    // UI state
    @State private var selectedTab = 0 // 0 = Weather, 1 = Chat
    @State private var showingAnalysis = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segmented control for Weather vs Chat
                Picker("Mode", selection: $selectedTab) {
                    Text("Weather Analysis").tag(0)
                    Text("General Chat").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                // Content
                if selectedTab == 0 {
                    weatherAnalysisView
                } else {
                    chatView
                }
            }
            .navigationTitle("AI Coach")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Weather Analysis View

    private var weatherAnalysisView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Input form
                VStack(alignment: .leading, spacing: 16) {
                    Text("Flight Information")
                        .font(.headline)

                    HStack(spacing: 12) {
                        VStack(alignment: .leading) {
                            Text("From")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("KAUS", text: $departureAirport)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.allCharacters)
                        }

                        VStack(alignment: .leading) {
                            Text("To")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("KSAT", text: $arrivalAirport)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.allCharacters)
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Fuel Remaining (gallons)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("30.5", text: $fuelRemaining)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                    }

                    VStack(alignment: .leading) {
                        Text("Your Question (optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Should I fly this route?", text: $customQuestion)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Analyze button
                    Button(action: analyzeWeather) {
                        HStack {
                            if weatherService.isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                Text("Analyzing...")
                            } else {
                                Image(systemName: "brain")
                                Text("Analyze Weather")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(departureAirport.isEmpty || arrivalAirport.isEmpty || weatherService.isLoading)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Analysis result
                if let analysis = weatherService.lastAnalysis {
                    analysisResultView(analysis: analysis)
                }

                // Error message
                if let error = weatherService.error {
                    Text("⚠️ \(error)")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - Analysis Result View

    private func analysisResultView(analysis: WeatherAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Recommendation badge
            HStack {
                Text(analysis.recommendation)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(recommendationColor(for: analysis.recommendation))
                    .cornerRadius(8)

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Confidence: \(analysis.confidence)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(analysis.responseTimeMs)ms")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Weather summary
            VStack(alignment: .leading, spacing: 8) {
                Text("Weather Summary")
                    .font(.headline)
                Text(analysis.weatherSummary)
                    .font(.body)
            }

            Divider()

            // Reasoning
            VStack(alignment: .leading, spacing: 8) {
                Text("AI Reasoning")
                    .font(.headline)
                Text(analysis.reasoning)
                    .font(.body)
            }

            // Hazards
            if !analysis.hazards.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("⚠️ Identified Hazards")
                        .font(.headline)
                        .foregroundColor(.orange)

                    ForEach(analysis.hazards, id: \.self) { hazard in
                        HStack(alignment: .top) {
                            Text("•")
                            Text(hazard)
                        }
                    }
                }
            }

            // Alternatives
            if !analysis.alternatives.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Alternative Actions")
                        .font(.headline)
                        .foregroundColor(.blue)

                    ForEach(analysis.alternatives, id: \.self) { alternative in
                        HStack(alignment: .top) {
                            Text("•")
                            Text(alternative)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }

    // MARK: - Chat View

    private var chatView: some View {
        VStack(spacing: 0) {
            // Chat messages
            ScrollView {
                ScrollViewReader { proxy in
                    VStack(spacing: 12) {
                        ForEach(chatMessages) { message in
                            chatBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                    .onChange(of: chatMessages.count) { _ in
                        // Scroll to bottom when new message arrives
                        if let lastMessage = chatMessages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }

            Divider()

            // Message input
            HStack {
                TextField("Ask about safety, weather, procedures...", text: $currentMessage)
                    .textFieldStyle(.roundedBorder)
                    .disabled(weatherService.isLoading)

                Button(action: sendChatMessage) {
                    Image(systemName: weatherService.isLoading ? "hourglass" : "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(currentMessage.isEmpty ? .gray : .blue)
                }
                .disabled(currentMessage.isEmpty || weatherService.isLoading)
            }
            .padding()
        }
    }

    // MARK: - Chat Bubble

    private func chatBubble(message: ChatMessage) -> some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .frame(maxWidth: 280, alignment: .trailing)
            } else {
                Text(message.text)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(16)
                    .frame(maxWidth: 280, alignment: .leading)
                Spacer()
            }
        }
    }

    // MARK: - Actions

    private func analyzeWeather() {
        Task {
            do {
                let fuel = Double(fuelRemaining)
                let analysis = try await weatherService.analyzeWeather(
                    departure: departureAirport.uppercased(),
                    arrival: arrivalAirport.uppercased(),
                    fuelRemaining: fuel,
                    pilotHours: nil, // TODO: Get from user profile
                    aircraftType: "C172", // TODO: Get from user profile
                    customQuestion: customQuestion.isEmpty ? nil : customQuestion
                )

                print("✅ Weather analysis: \(analysis.recommendation)")
            } catch {
                weatherService.error = error.localizedDescription
                print("❌ Weather analysis error: \(error)")
            }
        }
    }

    private func sendChatMessage() {
        guard !currentMessage.isEmpty else { return }

        // Add user message
        let userMessage = ChatMessage(text: currentMessage, isUser: true)
        chatMessages.append(userMessage)

        let messageText = currentMessage
        currentMessage = ""

        // Get AI response
        Task {
            do {
                let response = try await weatherService.askCoachingQuestion(message: messageText)

                // Add AI response
                let aiMessage = ChatMessage(text: response, isUser: false)
                chatMessages.append(aiMessage)
            } catch {
                let errorMessage = ChatMessage(text: "Sorry, I'm experiencing technical difficulties. Please try again.", isUser: false)
                chatMessages.append(errorMessage)
            }
        }
    }

    // MARK: - Helpers

    private func recommendationColor(for recommendation: String) -> Color {
        switch recommendation.uppercased() {
        case "GO":
            return .green
        case "NO-GO":
            return .red
        case "WAIT":
            return .orange
        case "DIVERT":
            return .yellow
        default:
            return .gray
        }
    }
}

// MARK: - Chat Message Model

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
}

// MARK: - Preview

#Preview {
    AICoachingView()
        .environmentObject(AppState())
}
