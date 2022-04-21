//
//  RadarAnnotationView.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 13.04.22.
//

import Foundation
import UIKit
import MapKit

/**
 
 */
final class RadarAnnotationView: MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        didSet {
            editView()
        }
    }
    
    /**
     
     */
    private func editView() {
        backgroundColor = UIColor.red
        frame = CGRect(origin: frame.origin, size: CGSize(width: 12.0, height: 12.0))
        layer.cornerRadius = self.frame.width / 2;
        layer.masksToBounds = true
        setNeedsLayout()
    }
    
    /**
     
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.width / 2;
        layer.masksToBounds = true
    }
}
