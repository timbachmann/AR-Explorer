//
// NewImageRequest.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct NewImageRequest: Codable, JSONEncodable, Hashable {

    public var userID: String
    public var id: String
    public var data: Data
    public var lat: Double
    public var lng: Double
    public var date: String
    public var source: String
    public var bearing: Int
    public var yaw: Float
    public var pitch: Float
    public var publicImage: Int

    public init(userID: String, id: String, data: Data, lat: Double, lng: Double, date: String, source: String, bearing: Int, yaw: Float, pitch: Float, publicImage: Int) {
        self.userID = userID
        self.id = id
        self.data = data
        self.lat = lat
        self.lng = lng
        self.date = date
        self.source = source
        self.bearing = bearing
        self.yaw = yaw
        self.pitch = pitch
        self.publicImage = publicImage
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case userID
        case id
        case data
        case lat
        case lng
        case date
        case source
        case bearing
        case yaw
        case pitch
        case publicImage
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userID, forKey: .userID)
        try container.encode(id, forKey: .id)
        try container.encode(data, forKey: .data)
        try container.encode(lat, forKey: .lat)
        try container.encode(lng, forKey: .lng)
        try container.encode(date, forKey: .date)
        try container.encode(source, forKey: .source)
        try container.encode(bearing, forKey: .bearing)
        try container.encode(yaw, forKey: .yaw)
        try container.encode(pitch, forKey: .pitch)
        try container.encode(publicImage, forKey: .publicImage)
    }
}

