//
//  ImageAnnotationView.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 11.03.22.
//

import Foundation
import UIKit
import MapKit

/**
 
 */
final class ImageAnnotationView: MKAnnotationView {
    
    private let imageView = UIImageView()
    override var annotation: MKAnnotation? { didSet {
        editView()
    } }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    /**
     
     */
    private func setupView() {
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        addSubview(imageView)
    }
    
    /**
     
     */
    private func editView() {
        backgroundColor = UIColor.white
        frame = CGRect(origin: frame.origin, size: CGSize(width: 64.0, height: 64.0))
        if let imageAnnotation = annotation as? ImageAnnotation {
            imageView.image = imageAnnotation.image
        }
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        setNeedsLayout()
    }
    
    /**
     
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds.inset(by: UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0))
        layer.cornerRadius = image == nil ? 5.0 : 0
    }
}
