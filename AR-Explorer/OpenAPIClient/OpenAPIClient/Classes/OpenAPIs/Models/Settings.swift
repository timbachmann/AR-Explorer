//
//  Settings.swift
//  AR-Explorer
//
//  Created by Tim Bachmann on 21.04.22.
//

import Foundation

#if canImport(AnyCodable)
import AnyCodable
#endif


public struct Settings: Codable, JSONEncodable, Hashable {
    
    public var serverAddress: String
    
    public init(serverAddress: String) {
        self.serverAddress = serverAddress
    }
}
