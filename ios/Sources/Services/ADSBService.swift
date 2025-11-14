// ADSBService.swift
// ADS-B traffic receiver integration (GDL90 protocol)
// Built by Pixel (iOS Agent) - Day 4-5
// Requirement: Dustin's Feature #1 (Traffic Awareness That Actually Works)

import Foundation
import Network
import Combine
import AVFoundation

/// ADS-B traffic service
/// Connects to Stratux/Stratus/Sentry receivers via GDL90 protocol
class ADSBService: ObservableObject {
    // MARK: - Published Properties
    @Published var aircraft: [TrafficAircraft] = []
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var receiverInfo: ReceiverInfo?

    // MARK: - Private Properties
    private var connection: NWConnection?
    private let gdl90Port: NWEndpoint.Port = 4000 // Standard GDL90 UDP port
    private var audioPlayer: AVAudioPlayer?

    // Alert thresholds (from Dustin's requirements)
    private let alertDistanceNM: Double = 2.0 // 2 nautical miles
    private let alertAltitudeFt: Double = 1000.0 // ±1,000 feet

    // MARK: - Connection Status
    enum ConnectionStatus {
        case disconnected
        case connecting
        case connected
        case failed(Error)

        var description: String {
            switch self {
            case .disconnected: return "Disconnected"
            case .connecting: return "Connecting..."
            case .connected: return "Connected"
            case .failed(let error): return "Failed: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Public Methods

    /// Connect to ADS-B receiver
    /// - Parameter receiverIP: IP address of receiver (default: Stratux at 192.168.10.1)
    func connect(to receiverIP: String = "192.168.10.1") {
        disconnect() // Disconnect if already connected

        let host = NWEndpoint.Host(receiverIP)
        let port = NWEndpoint.Port(rawValue: gdl90Port.rawValue)!

        connection = NWConnection(host: host, port: port, using: .udp)
        connectionStatus = .connecting

        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    self?.connectionStatus = .connected
                    self?.receiveGDL90Data()
                    print("✅ ADS-B Connected to \(receiverIP)")

                case .failed(let error):
                    self?.connectionStatus = .failed(error)
                    print("❌ ADS-B Connection failed: \(error)")

                case .waiting(let error):
                    print("⏳ ADS-B Waiting: \(error)")

                default:
                    break
                }
            }
        }

        connection?.start(queue: .global())
    }

    /// Disconnect from receiver
    func disconnect() {
        connection?.cancel()
        connection = nil
        connectionStatus = .disconnected
        aircraft.removeAll()
        print("⏸️ ADS-B Disconnected")
    }

    /// Get aircraft within alert threshold
    /// - Parameter ownPosition: Own aircraft position and altitude
    /// - Returns: Aircraft requiring traffic alerts
    func getAlertAircraft(ownPosition: CLLocation, ownAltitude: Double) -> [TrafficAircraft] {
        return aircraft.filter { traffic in
            guard let distance = calculateDistance(
                from: ownPosition.coordinate,
                to: traffic.coordinate
            ) else { return false }

            let altitudeDifference = abs(traffic.altitude - ownAltitude)

            // Alert if within 2 NM and ±1,000 ft
            return distance <= alertDistanceNM && altitudeDifference <= alertAltitudeFt
        }
    }

    /// Play audio alert for close traffic
    func playTrafficAlert() {
        // TODO: Implement AVFoundation audio alert (Day 5)
        // For now, system beep
        AudioServicesPlaySystemSound(1315) // Alert tone
        print("🔔 Traffic Alert!")
    }

    // MARK: - Private Methods

    /// Receive and parse GDL90 messages
    private func receiveGDL90Data() {
        connection?.receiveMessage { [weak self] data, _, isComplete, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ GDL90 Receive error: \(error)")
                return
            }

            if let data = data, !data.isEmpty {
                self.parseGDL90Message(data)
            }

            // Continue receiving
            if isComplete {
                self.receiveGDL90Data()
            }
        }
    }

    /// Parse GDL90 protocol message
    private func parseGDL90Message(_ data: Data) {
        guard data.count >= 2 else { return }

        // GDL90 message format: [0x7E] [MessageID] [Payload] [FCS] [0x7E]
        // Strip flags (first and last byte)
        var payload = data
        if payload.first == 0x7E {
            payload.removeFirst()
        }
        if payload.last == 0x7E {
            payload.removeLast()
        }

        guard !payload.isEmpty else { return }

        let messageID = payload[0]

        switch messageID {
        case 0x00: // Heartbeat
            parseHeartbeat(payload)

        case 0x14: // Traffic Report
            parseTrafficReport(payload)

        case 0x0A: // Ownship Report
            parseOwnshipReport(payload)

        case 0x07, 0x08: // Weather (FIS-B)
            // TODO: Implement weather parsing (Day 6-7)
            break

        default:
            // Unknown message
            break
        }
    }

    /// Parse heartbeat message (receiver status)
    private func parseHeartbeat(_ data: Data) {
        guard data.count >= 7 else { return }

        // Byte 1-2: Status flags
        let status = UInt16(data[1]) << 8 | UInt16(data[2])
        let gpsValid = (status & 0x8000) != 0
        let stratuxVersion = String(format: "%d.%d", data[3], data[4])

        DispatchQueue.main.async {
            self.receiverInfo = ReceiverInfo(
                version: stratuxVersion,
                gpsValid: gpsValid
            )
        }
    }

    /// Parse traffic report (GDL90 Message ID 0x14)
    private func parseTrafficReport(_ data: Data) {
        guard data.count >= 28 else { return }

        // Extract ICAO address (3 bytes)
        let icao = String(format: "%02X%02X%02X",
                         data[2], data[3], data[4])

        // Extract latitude (3 bytes, signed)
        let latRaw = Int32(data[5]) << 16 | Int32(data[6]) << 8 | Int32(data[7])
        let latitude = Double(latRaw) * (180.0 / Double(1 << 23))

        // Extract longitude (3 bytes, signed)
        let lonRaw = Int32(data[8]) << 16 | Int32(data[9]) << 8 | Int32(data[10])
        let longitude = Double(lonRaw) * (180.0 / Double(1 << 23))

        // Extract altitude (12 bits, pressure altitude in 25-foot increments)
        let altRaw = (Int16(data[11]) << 4) | (Int16(data[12]) >> 4)
        let altitude = Double(altRaw) * 25.0 // feet

        // Extract velocity (horizontal speed in knots)
        let velocityRaw = UInt16(data[13]) << 4 | (UInt16(data[14]) >> 4)
        let velocity = Double(velocityRaw) // knots

        // Extract vertical velocity (ft/min)
        let vvRaw = Int16(data[15])
        let verticalVelocity = Double(vvRaw) * 64.0 // ft/min

        // Extract track/heading (degrees)
        let track = Double(data[16]) * (360.0 / 256.0)

        // Extract callsign (8 bytes)
        let callsignData = data.subdata(in: 17..<25)
        let callsign = String(data: callsignData, encoding: .ascii)?.trimmingCharacters(in: .whitespaces) ?? icao

        // Create or update aircraft
        let aircraft = TrafficAircraft(
            icao: icao,
            callsign: callsign,
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            speed: velocity,
            verticalSpeed: verticalVelocity,
            track: track,
            lastUpdated: Date()
        )

        DispatchQueue.main.async {
            // Update or add aircraft
            if let index = self.aircraft.firstIndex(where: { $0.icao == icao }) {
                self.aircraft[index] = aircraft
            } else {
                self.aircraft.append(aircraft)
            }

            // Remove stale aircraft (not updated in 60 seconds)
            let staleThreshold = Date().addingTimeInterval(-60)
            self.aircraft.removeAll { $0.lastUpdated < staleThreshold }
        }
    }

    /// Parse ownship report (GPS position from receiver)
    private func parseOwnshipReport(_ data: Data) {
        // TODO: Cross-check with iOS GPS (Day 3)
    }

    /// Calculate distance between coordinates (in nautical miles)
    private func calculateDistance(from: CLLocationCoordinate2D,
                                  to: CLLocationCoordinate2D) -> Double? {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)

        let distanceMeters = fromLocation.distance(from: toLocation)
        return distanceMeters / 1852.0 // Convert to nautical miles
    }
}

// MARK: - Models

/// Traffic aircraft model
struct TrafficAircraft: Identifiable, Equatable {
    let id = UUID()
    let icao: String // ICAO 24-bit address (hex)
    let callsign: String
    let latitude: Double
    let longitude: Double
    let altitude: Double // feet MSL
    let speed: Double // knots
    let verticalSpeed: Double // ft/min
    let track: Double // degrees true
    let lastUpdated: Date

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Predicted position 30 seconds from now (Dustin's requirement)
    func predictedPosition(after seconds: Double = 30) -> CLLocationCoordinate2D {
        let distanceNM = (speed / 3600.0) * seconds // NM traveled in 30 seconds
        let distanceMeters = distanceNM * 1852.0

        let radiusEarth = 6371000.0 // meters
        let bearing = track * .pi / 180.0

        let lat1 = latitude * .pi / 180.0
        let lon1 = longitude * .pi / 180.0

        let lat2 = asin(
            sin(lat1) * cos(distanceMeters / radiusEarth) +
            cos(lat1) * sin(distanceMeters / radiusEarth) * cos(bearing)
        )

        let lon2 = lon1 + atan2(
            sin(bearing) * sin(distanceMeters / radiusEarth) * cos(lat1),
            cos(distanceMeters / radiusEarth) - sin(lat1) * sin(lat2)
        )

        return CLLocationCoordinate2D(
            latitude: lat2 * 180.0 / .pi,
            longitude: lon2 * 180.0 / .pi
        )
    }

    static func == (lhs: TrafficAircraft, rhs: TrafficAircraft) -> Bool {
        lhs.icao == rhs.icao
    }
}

/// Receiver information
struct ReceiverInfo {
    let version: String
    let gpsValid: Bool
}

// MARK: - LocationCoordinate2D Extension
import CoreLocation

extension CLLocationCoordinate2D {
    /// Distance to another coordinate (in nautical miles)
    func distance(to other: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: latitude, longitude: longitude)
        let toLocation = CLLocation(latitude: other.latitude, longitude: other.longitude)

        let distanceMeters = fromLocation.distance(from: toLocation)
        return distanceMeters / 1852.0 // NM
    }

    /// Bearing to another coordinate (degrees true)
    func bearing(to other: CLLocationCoordinate2D) -> Double {
        let lat1 = latitude * .pi / 180
        let lon1 = longitude * .pi / 180
        let lat2 = other.latitude * .pi / 180
        let lon2 = other.longitude * .pi / 180

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

        var bearing = atan2(y, x) * 180 / .pi
        bearing = (bearing + 360).truncatingRemainder(dividingBy: 360)

        return bearing
    }
}
