// EngineDataEntryView.swift
// Manual engine parameter entry form
// Built by Pixel (iOS Agent) - Day 8-9
// Requirement: Dustin's Feature #3 - Manual entry (OCR deferred to M7)

import SwiftUI

struct EngineDataEntryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var flightService: FlightService
    let flight: Flight

    // Engine parameters (Dustin's C172N typical ranges)
    @State private var oilPressure = "" // PSI (normal: 30-60 PSI)
    @State private var oilTemperature = "" // °F (normal: 100-245°F)
    @State private var cht = "" // Cylinder Head Temp (normal: 200-500°F)
    @State private var egt = "" // Exhaust Gas Temp (normal: 1200-1600°F)
    @State private var rpm = "" // Engine RPM (normal: 2000-2700 RPM)
    @State private var fuelQuantity = "" // Gallons (C172: 43 gal usable)

    // UI state
    @State private var isSaving = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    // Normal ranges for C172N (for validation alerts)
    private let normalRanges: [String: (min: Double, max: Double)] = [
        "oilPressure": (30, 60),
        "oilTemperature": (100, 245),
        "cht": (200, 500),
        "egt": (1200, 1600),
        "rpm": (2000, 2700),
        "fuelQuantity": (0, 43)
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Flight Information")) {
                    HStack {
                        Text("Aircraft")
                        Spacer()
                        Text(flight.aircraftType)
                            .foregroundColor(.secondary)
                    }

                    if let departure = flight.departureAirport {
                        HStack {
                            Text("Departure")
                            Spacer()
                            Text(departure)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Text("Date")
                        Spacer()
                        Text(flight.departureTime.formatted(date: .abbreviated, time: .shortened))
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Engine Parameters"),
                       footer: Text("Enter current readings from your gauges. Leave blank if not applicable.")) {

                    // Oil Pressure
                    parameterField(
                        label: "Oil Pressure",
                        value: $oilPressure,
                        unit: "PSI",
                        range: normalRanges["oilPressure"]!,
                        icon: "drop.fill",
                        color: .blue
                    )

                    // Oil Temperature
                    parameterField(
                        label: "Oil Temperature",
                        value: $oilTemperature,
                        unit: "°F",
                        range: normalRanges["oilTemperature"]!,
                        icon: "thermometer",
                        color: .orange
                    )

                    // Cylinder Head Temperature
                    parameterField(
                        label: "Cylinder Head Temp (CHT)",
                        value: $cht,
                        unit: "°F",
                        range: normalRanges["cht"]!,
                        icon: "flame.fill",
                        color: .red
                    )

                    // Exhaust Gas Temperature
                    parameterField(
                        label: "Exhaust Gas Temp (EGT)",
                        value: $egt,
                        unit: "°F",
                        range: normalRanges["egt"]!,
                        icon: "flame",
                        color: .orange
                    )

                    // RPM
                    parameterField(
                        label: "Engine RPM",
                        value: $rpm,
                        unit: "RPM",
                        range: normalRanges["rpm"]!,
                        icon: "gauge",
                        color: .green
                    )

                    // Fuel Quantity
                    parameterField(
                        label: "Fuel Quantity",
                        value: $fuelQuantity,
                        unit: "gallons",
                        range: normalRanges["fuelQuantity"]!,
                        icon: "fuelpump.fill",
                        color: .yellow
                    )
                }

                Section {
                    Button(action: saveEngineData) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                Text("Saving...")
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Save Engine Data")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(isSaving || allFieldsEmpty)
                }
            }
            .navigationTitle("Engine Parameters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Engine Data", isPresented: $showAlert) {
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

    // MARK: - Parameter Field View

    @ViewBuilder
    private func parameterField(
        label: String,
        value: Binding<String>,
        unit: String,
        range: (min: Double, max: Double),
        icon: String,
        color: Color
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.body)
                Text("Normal: \(Int(range.min))-\(Int(range.max)) \(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            TextField("--", text: value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 60)

            Text(unit)
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Computed Properties

    private var allFieldsEmpty: Bool {
        oilPressure.isEmpty &&
        oilTemperature.isEmpty &&
        cht.isEmpty &&
        egt.isEmpty &&
        rpm.isEmpty &&
        fuelQuantity.isEmpty
    }

    // MARK: - Actions

    private func saveEngineData() {
        // Validate and create engine data point
        let dataPoint = EngineDataPoint(
            timestamp: Date(),
            oilPressure: Double(oilPressure),
            oilTemperature: Double(oilTemperature),
            cht: Double(cht),
            egt: Double(egt),
            rpm: Double(rpm),
            fuelQuantity: Double(fuelQuantity)
        )

        // Check for out-of-range values (Dustin's requirement)
        var warnings: [String] = []

        if let oilPress = dataPoint.oilPressure,
           let range = normalRanges["oilPressure"],
           (oilPress < range.min || oilPress > range.max) {
            warnings.append("⚠️ Oil Pressure \(Int(oilPress)) PSI is outside normal range (\(Int(range.min))-\(Int(range.max)) PSI)")
        }

        if let oilTemp = dataPoint.oilTemperature,
           let range = normalRanges["oilTemperature"],
           (oilTemp < range.min || oilTemp > range.max) {
            warnings.append("⚠️ Oil Temperature \(Int(oilTemp))°F is outside normal range (\(Int(range.min))-\(Int(range.max))°F)")
        }

        if let chtValue = dataPoint.cht,
           let range = normalRanges["cht"],
           (chtValue < range.min || chtValue > range.max) {
            warnings.append("⚠️ CHT \(Int(chtValue))°F is outside normal range (\(Int(range.min))-\(Int(range.max))°F)")
        }

        if let egtValue = dataPoint.egt,
           let range = normalRanges["egt"],
           (egtValue < range.min || egtValue > range.max) {
            warnings.append("⚠️ EGT \(Int(egtValue))°F is outside normal range (\(Int(range.min))-\(Int(range.max))°F)")
        }

        // Show warnings if any
        if !warnings.isEmpty {
            alertMessage = warnings.joined(separator: "\n\n")
            showAlert = true
            // Don't return - still save the data but alert the user
        }

        // Save to backend
        isSaving = true

        Task {
            do {
                try await flightService.addEngineData(flightId: flight.id, data: dataPoint)

                DispatchQueue.main.async {
                    isSaving = false
                    alertMessage = "✅ Engine data saved successfully"
                    showAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    isSaving = false
                    alertMessage = "❌ Failed to save: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let mockFlight = Flight(
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

    return EngineDataEntryView(
        flightService: FlightService(),
        flight: mockFlight
    )
}
