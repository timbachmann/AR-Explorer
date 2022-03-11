//
//  ImageAnnotationView.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 11.03.22.
//

import Foundation
import UIKit
import MapKit


final class ImageAnnotationView: MKAnnotationView {
    
    private let imageView = UIImageView()
    override var annotation: MKAnnotation? { didSet {
        //configureDetailView()
        editView()
    } }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        //configure()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //configure()
        setupView()
    }
    
    private func setupView() {
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        addSubview(imageView)
    }
    
    private func editView() {
        //View
        backgroundColor = UIColor.white
        frame = CGRect(origin: frame.origin, size: CGSize(width: 64.0, height: 64.0))
        if let imageAnnotation = annotation as? ImageAnnotation {
            imageView.image = imageAnnotation.image
        }
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //countLabel.frame = bounds.offsetBy(dx: bounds.size.width/2, dy: -bounds.size.height/2)
        imageView.frame = bounds.inset(by: UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0))
        layer.cornerRadius = image == nil ? 5.0 : 0
    }
}

//Callout Config
//private extension ImageAnnotationView {
//    func configure() {
//        canShowCallout = true
//        setupView()
//        configureDetailView()
//    }
//
//    func configureDetailView() {
//        guard let annotation = annotation else { return }
//
//        if let observationAnnotation = annotation as? ImageAnnotation {
//
//            // Callout
//            let rect = CGRect(origin: .zero, size: CGSize(width: 200, height: 200))
//            let snapshotView = UIView()
//
//            let imageView = UIImageView(frame: rect)
//            imageView.image = observationAnnotation.image
//            snapshotView.addSubview(imageView)
//
//            detailCalloutAccessoryView = snapshotView
//            NSLayoutConstraint.activate([
//                snapshotView.widthAnchor.constraint(equalToConstant: rect.width),
//                snapshotView.heightAnchor.constraint(equalToConstant: rect.height)
//            ])
//        }
//    }
//}
