//
//  GeometryUtils.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 28.01.22.
//

import Foundation
import ARKit
import SwiftUI
import UIKit

/**
 
 */
class GeometryUtils {
    
    /**
     
     */
    static func transformMatrix(_ matrix:simd_float4x4,_ originLocation:CLLocation, _ waypointLocation: CLLocation) -> simd_float4x4 {
        let bearing: Double = bearingBetweenLocations(originLocation, waypointLocation)
        let rotationMatrix: simd_float4x4 = rotateAroundY(matrix_identity_float4x4, Float(bearing))
        let distance: CLLocationDistance = originLocation.distance(from: waypointLocation)
        let position: simd_float4 = vector_float4(0.0, 0.0, Float(-distance), 0.0)
        let translationMatrix: simd_float4x4 = getTranslationMatrix(matrix_identity_float4x4, position)
        let transformMatrix: simd_float4x4 = simd_mul(rotationMatrix, translationMatrix)
        return simd_mul(matrix, transformMatrix)
    }
    
    /**
     
     */
    static func bearingBetweenLocations(_ originLocation: CLLocation, _ waypointLocation: CLLocation) -> Double {
        let lat1: Float = GLKMathDegreesToRadians(Float(originLocation.coordinate.latitude))
        let lon1: Float = GLKMathDegreesToRadians(Float(originLocation.coordinate.longitude))
        let lat2: Float = GLKMathDegreesToRadians(Float(waypointLocation.coordinate.latitude))
        let lon2: Float = GLKMathDegreesToRadians(Float(waypointLocation.coordinate.longitude))
        let longitudeDiff: Float = lon2 - lon1
        let y: Float = sin(longitudeDiff) * cos(lat2);
        let x: Float = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(longitudeDiff);
        return Double(atan2(y, x))
    }
    
    /**
     
     */
    static func rotateAroundY(_ matrix: simd_float4x4, _ degrees: Float) -> simd_float4x4 {
        var matrix = matrix
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
    
    /**
     
     */
    static func getTranslationMatrix(_ matrix:simd_float4x4, _ translation:vector_float4) -> simd_float4x4 {
        var matrix = matrix
        matrix.columns.3 = translation
        return matrix
    }
}
