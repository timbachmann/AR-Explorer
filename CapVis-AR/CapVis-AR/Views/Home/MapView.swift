//
//  MapViewRepresentable.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 11.02.22.
//

import SwiftUI
import MapKit
import OpenAPIClient


struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    var locationManager = CLLocationManager()
    func setupManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    @Binding var mapMarkerImages: [ApiImage]
    @Binding var navigationImage: ApiImage?
    @Binding var selectedTab: ContentView.Tab
    @Binding var showDetail: Bool
    @Binding var detailId: String
    @Binding var zoomOnLocation: Bool
    @Binding var changeMapType: Bool
    @Binding var applyAnnotations: Bool
    let region: MKCoordinateRegion
    let mapType: MKMapType
    let showsUserLocation: Bool
    let userTrackingMode: MKUserTrackingMode
    let identifier = "Annotation"
    let clusterIdentifier = "Cluster"
    let mapView = MKMapView()
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        setupManager()
        mapView.delegate = context.coordinator
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: identifier)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: clusterIdentifier)
        mapView.setRegion(region, animated: true)
        mapView.mapType = mapType
        mapView.showsUserLocation = showsUserLocation
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        if changeMapType {
            uiView.mapType = mapType
        }
        if zoomOnLocation {
            uiView.setRegion(region, animated: true)
            zoomOnLocation = false
        }
        if applyAnnotations {
            uiView.removeAnnotations(uiView.annotations)
            addAnnotations(to: uiView)
            applyAnnotations = false
        }
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        Coordinator(self, mapImages: $mapMarkerImages, detailId: $detailId, showDetail: $showDetail, navigationImage: $navigationImage, selectedTab: $selectedTab)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        @Binding var mapImages: [ApiImage]
        @Binding var showDetail: Bool
        @Binding var detailId: String
        @Binding var navigationImage: ApiImage?
        @Binding var selectedTab: ContentView.Tab
        private let mapView: MapView
        private var route: MKRoute? = nil
        let identifier = "Annotation"
        let clusterIdentifier = "Cluster"
        private let maxZoomLevel = 11
        private var previousZoomLevel: Int?
        private var currentZoomLevel: Int?  {
            willSet { self.previousZoomLevel = self.currentZoomLevel }
            didSet { checkZoomLevel() }
        }
        private var shouldCluster: Bool {
            if let zoomLevel = self.currentZoomLevel, zoomLevel <= maxZoomLevel { return false }
            return true
        }
        
        private func checkZoomLevel() {
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
        
        init(_ mapView: MapView, mapImages: Binding<[ApiImage]>, detailId: Binding<String>, showDetail: Binding<Bool>, navigationImage: Binding<ApiImage?>, selectedTab: Binding<ContentView.Tab>) {
            self.mapView = mapView
            _mapImages = mapImages
            _detailId = detailId
            _showDetail = showDetail
            _navigationImage = navigationImage
            _selectedTab = selectedTab
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let zoomWidth = mapView.visibleMapRect.size.width
            let zoomLevel = Int(log2(zoomWidth))
            self.currentZoomLevel = zoomLevel
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if annotation is ImageAnnotation {
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation) as! ImageAnnotationView
                annotationView.canShowCallout = true
                annotationView.annotation = annotation
                annotationView.clusteringIdentifier = self.shouldCluster ? identifier : nil
                return annotationView
                
            } else if annotation is MKClusterAnnotation {
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: clusterIdentifier, for: annotation) as! ClusterAnnotationView
                annotationView.canShowCallout = true
                annotationView.annotation = annotation
                return annotationView
            } else {
                return nil
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard view is ImageAnnotationView else { return }
            if let imageAnnotation = view.annotation as? ImageAnnotation {
                view.canShowCallout = true
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                let directionsButton: UIButton = UIButton(type: .detailDisclosure)
                directionsButton.tag = 123
                if imageAnnotation.route == nil {
                    directionsButton.setImage(UIImage(systemName: "arrow.triangle.turn.up.right.diamond"), for: .normal)
                } else {
                    directionsButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
                }
                view.leftCalloutAccessoryView = directionsButton
            }
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard view is ImageAnnotationView else { return }
            
            if let imageAnnotation = view.annotation as? ImageAnnotation {
                detailId = imageAnnotation.id!
                
                if let controlDetail = control as? UIButton {
                    if controlDetail.tag == 123 {
                        self.navigationImage = self.mapImages[self.mapImages.firstIndex(where: {$0.id == imageAnnotation.id})!]
                        selectedTab = .ar
                    } else {
                        showDetail = true
                    }
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyOverlay = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(overlay: polyOverlay)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 3
                return renderer
                
            } else if let circleOverlay = overlay as? MKCircle {
                let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
                circleRenderer.fillColor = .blue
                circleRenderer.alpha = 0.1
                return circleRenderer
                
            } else {
                return MKOverlayRenderer()
            }
            
        }
    }
    
    func addAnnotations(to mapView: MKMapView) {
        for image in mapMarkerImages {
            
            var finalImage: UIImage = UIImage(data: image.thumbnail)!
            finalImage = finalImage.scalePreservingAspectRatio(targetSize: CGSize(width: 48.0, height: 48.0))
            
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = .current
            formatter.timeZone = .current
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
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
    
    func addCircle(to view: MKMapView) {
        
        let radius: Double = 50
        if !view.overlays.isEmpty { view.removeOverlays(view.overlays) }
        
        let aCircle = MKCircle(center: view.centerCoordinate, radius: radius)
        let mapRect = aCircle.boundingMapRect
        
        view.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
        view.addOverlay(aCircle)
    }
}




