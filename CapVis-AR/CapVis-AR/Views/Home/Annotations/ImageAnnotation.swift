//
//  ImageAnnotation.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 11.03.22.
//

import Foundation
import UIKit
import MapKit

/**
 
 */
final class ImageAnnotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    var image: UIImage?
    var id: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, image: UIImage, subtitle: String, id: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.id = id
    }
}
