//
//  MapViewRepresentable.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 11.02.22.
//

import SwiftUI
import MapKit
import OpenAPIClient


struct MapViewRepresentable: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    var locationManager = CLLocationManager()
    func setupManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    @Binding var mapMarkerImages: [ApiImage]
    @Binding var showDetail: Bool
    @Binding var detailId: String
    let region: MKCoordinateRegion
    let mapType: MKMapType
    let showsUserLocation: Bool
    let userTrackingMode: MKUserTrackingMode
    let identifier = "Annotation"
    let mapView = MKMapView()
    
    func makeUIView(context: UIViewRepresentableContext<MapViewRepresentable>) -> MKMapView {
        setupManager()
        mapView.delegate = context.coordinator
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: identifier)
        mapView.setRegion(region, animated: true)
        mapView.mapType = mapType
        mapView.showsUserLocation = showsUserLocation
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapViewRepresentable>) {
        uiView.mapType = mapType
        uiView.setRegion(region, animated: true)
        uiView.removeAnnotations(uiView.annotations)
        addAnnotations(to: uiView)
    }
    
    func makeCoordinator() -> MapViewRepresentable.Coordinator {
        Coordinator(self)
    }
    
    func setShowDetail(value: Bool) {
        showDetail = value
    }
    
    func setDetailId(value: String) {
        detailId = value
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        private let mapView: MapViewRepresentable
        let identifier = "Annotation"
        private let maxZoomLevel = 13
        private var previousZoomLevel: Int?
        private var currentZoomLevel: Int?  {
            willSet {
                self.previousZoomLevel = self.currentZoomLevel
            }
            didSet {
                guard let currentZoomLevel = self.currentZoomLevel else { return }
                guard let previousZoomLevel = self.previousZoomLevel else { return }
                var refreshRequired = false
                if currentZoomLevel > self.maxZoomLevel && previousZoomLevel <= self.maxZoomLevel {
                    refreshRequired = true
                }
                if currentZoomLevel <= self.maxZoomLevel && previousZoomLevel > self.maxZoomLevel {
                    refreshRequired = true
                }
                if refreshRequired {
                    let annotations = self.mapView.mapView.annotations
                    self.mapView.mapView.removeAnnotations(annotations)
                    self.mapView.mapView.addAnnotations(annotations)
                }
            }
        }
        private var shouldCluster: Bool {
            if let zoomLevel = self.currentZoomLevel, zoomLevel <= maxZoomLevel {
                return false
            }
            return true
        }
        
        
        init(_ mapView: MapViewRepresentable) {
            self.mapView = mapView
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let zoomWidth = mapView.visibleMapRect.size.width
            let zoomLevel = Int(log2(zoomWidth))
            self.currentZoomLevel = zoomLevel
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is ImageAnnotation else { return nil }
            
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation) as! ImageAnnotationView
            
            annotationView.canShowCallout = true
            annotationView.annotation = annotation
            
            if self.shouldCluster {
                annotationView.clusteringIdentifier = identifier
            } else {
                annotationView.clusteringIdentifier = nil
            }
            
            
            if let observationAnnotation = annotation as? ImageAnnotation {
                annotationView.image = observationAnnotation.image
            }
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard view is ImageAnnotationView else { return }
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard view is ImageAnnotationView else { return }
            if let imageAnnotation = view.annotation as? ImageAnnotation {
                self.mapView.setDetailId(value: imageAnnotation.id!)
                self.mapView.setShowDetail(value: true)
            }
            print("annotation is tapped")
        }
        
    }
    
    func addAnnotations(to mapView: MKMapView) {
        for image in mapMarkerImages {
            
            var finalImage: UIImage = UIImage(data: image.data)!
            finalImage = finalImage.scalePreservingAspectRatio(targetSize: CGSize(width: 48.0, height: 48.0))
            
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            let date: Date = formatter.date(from: image.date)!
            formatter.dateFormat = "dd.MM.yyyy"
            
            let annotation = ImageAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: image.lat, longitude: image.lng),
                title: formatter.string(from: date),
                image: finalImage,
                subtitle: image.source,
                id: image.id
            )
            
            mapView.addAnnotation(annotation)
        }
    }
}

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

class ImageAnnotationView: MKAnnotationView {
}
