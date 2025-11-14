// LocationService.swift
// GPS tracking service using Core Location
// Built by Pixel (iOS Agent) - Day 2
// Requirement: Dustin's Acceptance Criteria #2 (GPS accuracy ±100 ft)

import Foundation
import CoreLocation
import Combine

/// GPS location tracking service
/// Provides real-time position, heading, speed for navigation
class LocationService: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var currentLocation: CLLocation?
    @Published var heading: CLHeading?
    @Published var speed: Double = 0.0 // knots
    @Published var altitude: Double = 0.0 // feet MSL
    @Published var track: Double = 0.0 // degrees true
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isTracking = false

    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private var locationHistory: [CLLocation] = []
    private let maxHistoryCount = 100 // Last 100 positions

    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // meters (update every 10m of movement)
        locationManager.headingFilter = 5 // degrees
        locationManager.activityType = .airborne // Optimized for aviation

        // Check authorization status
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Public Methods

    /// Request location authorization from user
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Start GPS tracking
    func startTracking() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            print("⚠️ Location authorization not granted")
            return
        }

        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        isTracking = true
        print("✅ GPS tracking started")
    }

    /// Stop GPS tracking
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        isTracking = false
        print("⏸️ GPS tracking stopped")
    }

    /// Get current position as coordinate
    var coordinate: CLLocationCoordinate2D? {
        currentLocation?.coordinate
    }

    /// Get current accuracy (horizontal)
    var horizontalAccuracy: Double? {
        currentLocation?.horizontalAccuracy
    }

    /// Get groundspeed in knots
    var groundspeedKnots: Double {
        guard let location = currentLocation, location.speed >= 0 else {
            return 0.0
        }
        // Convert m/s to knots (1 m/s = 1.94384 knots)
        return location.speed * 1.94384
    }

    /// Get location history for route tracking
    func getLocationHistory() -> [CLLocation] {
        return locationHistory
    }

    /// Clear location history
    func clearHistory() {
        locationHistory.removeAll()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location authorized")
            startTracking()
        case .denied, .restricted:
            print("❌ Location authorization denied")
            isTracking = false
        case .notDetermined:
            print("⏳ Location authorization pending")
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager,
                        didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // Update current location
        currentLocation = location

        // Update altitude (convert from meters to feet)
        altitude = location.altitude * 3.28084 // meters to feet

        // Update speed (convert to knots)
        if location.speed >= 0 {
            speed = location.speed * 1.94384 // m/s to knots
        }

        // Update track (course over ground)
        if location.course >= 0 {
            track = location.course
        }

        // Add to history
        locationHistory.append(location)
        if locationHistory.count > maxHistoryCount {
            locationHistory.removeFirst()
        }

        // Debug logging
        #if DEBUG
        print("""
        📍 GPS Update:
           Lat: \(location.coordinate.latitude)
           Lon: \(location.coordinate.longitude)
           Alt: \(String(format: "%.0f", altitude)) ft
           Speed: \(String(format: "%.1f", speed)) kts
           Accuracy: \(String(format: "%.0f", location.horizontalAccuracy)) m
        """)
        #endif
    }

    func locationManager(_ manager: CLLocationManager,
                        didUpdateHeading newHeading: CLHeading) {
        heading = newHeading

        #if DEBUG
        print("🧭 Heading: \(String(format: "%.0f", newHeading.trueHeading))° true")
        #endif
    }

    func locationManager(_ manager: CLLocationManager,
                        didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")

        // Handle specific errors
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                authorizationStatus = .denied
                isTracking = false
            case .locationUnknown:
                // Temporary error - GPS acquiring signal
                print("⏳ GPS acquiring signal...")
            default:
                break
            }
        }
    }
}

// MARK: - Aviation Utilities
extension LocationService {
    /// Calculate distance to a coordinate (in nautical miles)
    func distanceTo(coordinate: CLLocationCoordinate2D) -> Double? {
        guard let current = currentLocation else { return nil }

        let targetLocation = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        let distanceMeters = current.distance(from: targetLocation)
        // Convert meters to nautical miles (1 NM = 1852 meters)
        return distanceMeters / 1852.0
    }

    /// Calculate bearing to a coordinate (degrees true)
    func bearingTo(coordinate: CLLocationCoordinate2D) -> Double? {
        guard let current = currentLocation?.coordinate else { return nil }

        let lat1 = current.latitude * .pi / 180
        let lon1 = current.longitude * .pi / 180
        let lat2 = coordinate.latitude * .pi / 180
        let lon2 = coordinate.longitude * .pi / 180

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

        var bearing = atan2(y, x) * 180 / .pi
        bearing = (bearing + 360).truncatingRemainder(dividingBy: 360)

        return bearing
    }

    /// Estimate time enroute to coordinate (in minutes)
    func estimatedTimeEnrouteTo(coordinate: CLLocationCoordinate2D) -> Double? {
        guard let distance = distanceTo(coordinate: coordinate),
              speed > 0 else { return nil }

        // Time = Distance / Speed (NM / knots = hours)
        let timeHours = distance / speed
        return timeHours * 60 // convert to minutes
    }
}
