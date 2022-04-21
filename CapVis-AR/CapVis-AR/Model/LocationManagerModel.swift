//
//  LocationManagerModel.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 10.03.22.
//

import Foundation
import CoreLocation

/**
 Location manager delegate to publish location and heading updates.
 */
class LocationManagerModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var heading: CLHeading
    @Published var location: CLLocation
    
    private let locationManager: CLLocationManager
    
    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        heading = locationManager.heading ?? CLHeading()
        location = locationManager.location ?? CLLocation()
        
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }
    
    /**
     Called on heading updates and publishes new one
     */
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }
    
    /**
     Called on location updates and publishes new one
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first!
    }
}
