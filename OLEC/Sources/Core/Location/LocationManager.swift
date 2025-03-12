import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastError: Error?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update location when user moves 10 meters
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func getCurrentLocation() -> User.Location? {
        guard let location = location else { return nil }
        return User.Location(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            stopUpdatingLocation()
            lastError = NSError(
                domain: "com.olec.location",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Location access denied"]
            )
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastError = error
        print("Location manager error: \(error.localizedDescription)")
    }
}

// MARK: - Location Utilities
extension LocationManager {
    func distance(from location: User.Location) -> Double? {
        guard let currentLocation = self.location else { return nil }
        
        let targetLocation = CLLocation(
            latitude: location.latitude,
            longitude: location.longitude
        )
        
        return currentLocation.distance(from: targetLocation)
    }
    
    func formattedDistance(from location: User.Location) -> String? {
        guard let distance = distance(from: location) else { return nil }
        
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = 1
        
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        if distance < 1000 {
            return formatter.string(from: measurement)
        } else {
            return formatter.string(from: measurement.converted(to: .kilometers))
        }
    }
} 