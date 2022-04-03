//
// ApiImage.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct ApiImage: Codable, JSONEncodable, Hashable, Identifiable {

    public var id: String
    public var data: Data
    public var thumbnail: Data
    public var lat: Double
    public var lng: Double
    public var date: String
    public var source: String
    public var bearing: Int
    
    public init() {
        self.id = String()
        self.data = Data()
        self.thumbnail = Data()
        self.lat = Double()
        self.lng = Double()
        self.date = String()
        self.source = String()
        self.bearing = Int()
    }

    public init(id: String, data: Data, thumbnail: Data, lat: Double, lng: Double, date: String, source: String, bearing: Int) {
        self.id = id
        self.data = data
        self.thumbnail = thumbnail
        self.lat = lat
        self.lng = lng
        self.date = date
        self.source = source
        self.bearing = bearing
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case data
        case thumbnail
        case lat
        case lng
        case date
        case source
        case bearing
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(data, forKey: .data)
        try container.encode(thumbnail, forKey: .thumbnail)
        try container.encode(lat, forKey: .lat)
        try container.encode(lng, forKey: .lng)
        try container.encode(date, forKey: .date)
        try container.encode(source, forKey: .source)
        try container.encode(bearing, forKey: .bearing)
    }
}

