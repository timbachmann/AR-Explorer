//
//  GeometryUtils.swift
//  CapVis
//
//  Created by Tim Bachmann on 28.01.22.
//

import Foundation
import ARKit
import SwiftUI
import UIKit

class GeometryUtils {
    
    static func calculateDistance(first: SCNVector3, second: SCNVector3) -> Float {
        var distance:Float = sqrt(
            pow(second.x - first.x, 2) +
            pow(second.y - first.y, 2) +
            pow(second.z - first.z, 2)
        )
        
        distance *= 100 // convert in cm
        return abs(distance)
    }
    
    static func calculateDistance(firstNode: SCNNode, secondNode:SCNNode) -> Float {
        return calculateDistance(first: firstNode.position, second: secondNode.position)
    }
    
    
    
}
