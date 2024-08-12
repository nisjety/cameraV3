//
//  CLLocationManager.swift
//  iCameraV3
//
//  Created by Ima Da Costa on 10/08/2024.
//

import Foundation
import CoreLocation

// Extension to add async authorization and location handling
extension CLLocationManager {

    // Use stable pointers for associated object keys
    private static var updateKey: UInt8 = 0
    private static var errorKey: UInt8 = 0
    private static var authKey: UInt8 = 0

    // Closure for handling location updates
    var didUpdateLocations: (([CLLocation]) -> Void)? {
        get { objc_getAssociatedObject(self, &CLLocationManager.updateKey) as? ([CLLocation]) -> Void }
        set { objc_setAssociatedObject(self, &CLLocationManager.updateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // Closure for handling location errors
    var didFailWithError: ((Error) -> Void)? {
        get { objc_getAssociatedObject(self, &CLLocationManager.errorKey) as? (Error) -> Void }
        set { objc_setAssociatedObject(self, &CLLocationManager.errorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // Closure for handling authorization changes
    var didChangeAuthorization: ((CLAuthorizationStatus) -> Void)? {
        get { objc_getAssociatedObject(self, &CLLocationManager.authKey) as? (CLAuthorizationStatus) -> Void }
        set { objc_setAssociatedObject(self, &CLLocationManager.authKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // Async method to request location authorization
    func requestLocationAuthorization() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.requestWhenInUseAuthorization()
            self.didChangeAuthorization = { status in
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: LocationError.unauthorized)
                }
            }
        }
    }
}
