// EngineTrendView.swift
// Engine parameter trend graphs (last 10 flights)
// Built by Pixel (iOS Agent) - Day 8-9
// Requirement: Dustin's Feature #3 - Trend analysis with alerts

import SwiftUI
import Charts

struct EngineTrendView: View {
    @ObservedObject var flightService: FlightService
    let flight: Flight

    @State private var trends: [EngineTrend] = []
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Engine Parameter Trends")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Last 10 flights for \(flight.aircraftType)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)

                if isLoading {
                    ProgressView("Loading trends...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if let error = error {
                    errorView(message: error)
                } else if trends.isEmpty {
                    emptyStateView
                } else {
                    // Trend charts
                    ForEach(trends) { trend in
                        trendChartCard(trend: trend)
                    }
                }

                Spacer()
            }
        }
        .navigationTitle("Trends")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadTrends()
        }
    }

    // MARK: - Trend Chart Card

    @ViewBuilder
    private func trendChartCard(trend: EngineTrend) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(parameterDisplayName(trend.parameter))
                        .font(.headline)

                    HStack {
                        Text("Avg: \(String(format: "%.1f", trend.average))")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        trendBadge(trend.trend)
                    }
                }

                Spacer()

                parameterIcon(trend.parameter)
            }

            // Alert if present
            if let alert = trend.alert, !alert.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(alert)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }

            // Chart
            if !trend.values.isEmpty {
                Chart {
                    ForEach(Array(trend.values.enumerated()), id: \.offset) { index, value in
                        LineMark(
                            x: .value("Flight", "F\(10 - index)"),
                            y: .value("Value", value)
                        )
                        .foregroundStyle(trendColor(trend.trend))
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Flight", "F\(10 - index)"),
                            y: .value("Value", value)
                        )
                        .foregroundStyle(trendColor(trend.trend))
                    }

                    // Average line
                    RuleMark(y: .value("Average", trend.average))
                        .foregroundStyle(.gray.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .annotation(position: .trailing, alignment: .trailing) {
                            Text("Avg")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label)
                                    .font(.caption2)
                            }
                        }
                    }
                }
            } else {
                Text("No data available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
        .padding(.horizontal)
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func trendBadge(_ trend: String) -> some View {
        let (text, color) = trendInfo(trend)

        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(4)
    }

    @ViewBuilder
    private func parameterIcon(_ parameter: String) -> some View {
        let (icon, color) = iconInfo(parameter)

        Image(systemName: icon)
            .font(.title2)
            .foregroundColor(color)
            .frame(width: 40, height: 40)
            .background(color.opacity(0.1))
            .cornerRadius(8)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Trend Data Yet")
                .font(.headline)

            Text("Log engine parameters on multiple flights to see trend analysis.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)

            Text("Error Loading Trends")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Retry") {
                loadTrends()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    // MARK: - Helper Functions

    private func parameterDisplayName(_ parameter: String) -> String {
        switch parameter {
        case "oil_pressure": return "Oil Pressure"
        case "oil_temperature": return "Oil Temperature"
        case "cht": return "Cylinder Head Temp"
        case "egt": return "Exhaust Gas Temp"
        case "rpm": return "Engine RPM"
        case "fuel_quantity": return "Fuel Quantity"
        default: return parameter.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    private func trendInfo(_ trend: String) -> (String, Color) {
        switch trend.lowercased() {
        case "stable":
            return ("Stable", .green)
        case "increasing":
            return ("↗ Increasing", .orange)
        case "decreasing":
            return ("↘ Decreasing", .blue)
        default:
            return (trend, .gray)
        }
    }

    private func trendColor(_ trend: String) -> Color {
        switch trend.lowercased() {
        case "stable":
            return .green
        case "increasing":
            return .orange
        case "decreasing":
            return .blue
        default:
            return .gray
        }
    }

    private func iconInfo(_ parameter: String) -> (String, Color) {
        switch parameter {
        case "oil_pressure":
            return ("drop.fill", .blue)
        case "oil_temperature":
            return ("thermometer", .orange)
        case "cht":
            return ("flame.fill", .red)
        case "egt":
            return ("flame", .orange)
        case "rpm":
            return ("gauge", .green)
        case "fuel_quantity":
            return ("fuelpump.fill", .yellow)
        default:
            return ("chart.line.uptrend.xyaxis", .gray)
        }
    }

    // MARK: - Actions

    private func loadTrends() {
        isLoading = true
        error = nil

        Task {
            do {
                let fetchedTrends = try await flightService.getEngineTrends(flightId: flight.id)

                DispatchQueue.main.async {
                    self.trends = fetchedTrends
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        EngineTrendView(
            flightService: FlightService(),
            flight: Flight(
                id: "preview",
                userId: "preview",
                departureAirport: "KAUS",
                arrivalAirport: "KSAT",
                aircraftType: "C172N",
                departureTime: Date(),
                arrivalTime: nil,
                durationMinutes: nil,
                notes: nil,
                createdAt: Date()
            )
        )
    }
}
