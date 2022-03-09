//
//  Photo.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 01.03.22.
//

import Foundation
import UIKit
import CoreLocation
import OpenAPIClient
import SwiftUI

public struct Photo: Identifiable, Equatable {
    
    public var id: String
    public var originalData: Data
    var coordinates: Coordinates
    let locationManager: CLLocationManager = CLLocationManager()
    
    public init(id: String = UUID().uuidString, originalData: Data) {
        self.id = id
        self.originalData = originalData
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let latitude = locationManager.location?.coordinate.latitude
        let longitude = locationManager.location?.coordinate.longitude
        self.coordinates = Coordinates(latitude: latitude ?? 0.0, longitude: longitude ?? 0.0)
    }
}

extension Photo {
    
    public var compressedData: Data? {
        ImageResizer(targetWidth: 800).resize(data: originalData)?.jpegData(compressionQuality: 0.5)
    }
    public var thumbnailData: Data? {
        ImageResizer(targetWidth: 100).resize(data: originalData)?.jpegData(compressionQuality: 0.5)
    }
    public var thumbnailImage: UIImage? {
        guard let data = thumbnailData else { return nil }
        return UIImage(data: data)
    }
    public var image: UIImage? {
        guard let data = compressedData else { return nil }
        return UIImage(data: data)
    }
}

struct Coordinates: Hashable, Codable {
    var latitude: Double
    var longitude: Double
}
