//
//  File.swift
//  
//
//  Created by Tim Bachmann on 03.04.22.
//

import Foundation

#if canImport(AnyCodable)
import AnyCodable
#endif

public struct MetaData: Codable, JSONEncodable, Hashable {

    public var id: String
    public var lat: Double
    public var lng: Double
    public var date: String
    public var source: String
    public var bearing: Int
    public var yaw: Float
    public var pitch: Float

    public init(id: String, lat: Double, lng: Double, date: String, source: String, bearing: Int, yaw: Float, pitch: Float) {
        self.id = id
        self.lat = lat
        self.lng = lng
        self.date = date
        self.source = source
        self.bearing = bearing
        self.yaw = yaw
        self.pitch = pitch
    }
}
