//
//  MapLocation.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 10.02.22.
//
import CoreLocation
import SwiftUI

struct CapVisImage: Hashable, Codable, Identifiable {
    
//    init(id: UUID = UUID(), lat: Double, long: Double) {
//        self.id = id
//        self.location = CLLocationCoordinate2D(latitude: lat, longitude: long)
//    }
    var id: Int
    var name: String
    var date: String
    var source: String
    var bearing: Int
    var distance: Double
    var coordinates: Coordinates
    var description: String
    var imageName: String
    var image: Image {
        Image(imageName)
    }
    
    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude)
    }

    struct Coordinates: Hashable, Codable {
        var latitude: Double
        var longitude: Double
    }
}
