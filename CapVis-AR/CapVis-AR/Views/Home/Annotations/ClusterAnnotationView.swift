//
//  ClusterAnnotationView.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 11.03.22.
//

import Foundation
import MapKit
import UIKit

/**
 
 */
final class ClusterAnnotationView: MKAnnotationView {
    
    private let imageView = UIImageView()
    private var circle = CGRect()
    private let countLabel: UILabel = {
        let label = UILabel()
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textAlignment = .center
        label.backgroundColor = UIColor.systemBlue
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 2
        label.numberOfLines = 1
        label.baselineAdjustment = .alignCenters
        return label
    }()
    
    public override var annotation: MKAnnotation? {
        didSet {
            updateView()
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    /**
     
     */
    private func setupView() {
        backgroundColor = UIColor.clear
        layer.borderColor = UIColor.white.cgColor
        circle = CGRect(origin: frame.origin, size: CGSize(width: 28, height: 28))
        addSubview(imageView)
        let container = UIView()
        container.bounds = CGRect(origin: container.frame.origin, size: CGSize(width: 28, height: 28))
        countLabel.frame = circle.offsetBy(dx: 62.0, dy: 2.0)
        countLabel.layer.cornerRadius = 14.0
        countLabel.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        container.addSubview(countLabel)
        addSubview(container)
    }
    
    /**
     
     */
    private func updateView() {
        if let cluster = annotation as? MKClusterAnnotation {
            let count = cluster.memberAnnotations.count
            backgroundColor = UIColor.white
            frame = CGRect(origin: frame.origin, size: CGSize(width: 64.0, height: 64.0))
            countLabel.text = "\(count)"
            if let imageAnnotation = cluster.memberAnnotations.first as? ImageAnnotation {
                imageView.image = imageAnnotation.image
            }
            imageView.contentMode = UIView.ContentMode.scaleAspectFill
            setNeedsLayout()
        }
    }
    
    /**
     
     */
    override public func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds.inset(by: UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0))
        layer.cornerRadius = image == nil ? 5.0 : 0
    }
    
}
