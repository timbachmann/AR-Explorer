//
//  RadarView.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 04.04.22.
//

import Foundation

import SwiftUI
import MapKit
import OpenAPIClient


struct RadarView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    var locationManager = CLLocationManager()
    func setupManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    @Binding var mapMarkerImages: [ApiImage]
    @Binding var navigationImage: ApiImage?
    @Binding var redrawImages: Bool
    @Binding var applyAnnotations: Bool
    @State var polyline: MKPolyline? = nil
    let identifier = "radar"
    let mapView = MKMapView()
    
    func makeUIView(context: UIViewRepresentableContext<RadarView>) -> MKMapView {
        setupManager()
        mapView.delegate = context.coordinator
        mapView.register(RadarAnnotationView.self, forAnnotationViewWithReuseIdentifier: identifier)
        mapView.cameraZoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 100.0)
        mapView.mapType = .satellite
        mapView.camera.pitch = 0.0
        mapView.userTrackingMode = .followWithHeading
        mapView.showsUserLocation = true
        mapView.showsBuildings = true
        mapView.isZoomEnabled = false
        mapView.isPitchEnabled = false
        mapView.isUserInteractionEnabled = false
        
        if navigationImage != nil {
            addRoute(to: mapView)
        }
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<RadarView>) {
        //uiView.setRegion(MKCoordinateRegion(center: CLLocationManager().location!.coordinate, latitudinalMeters: 30.0, longitudinalMeters: 30.0), animated: true)
        uiView.setUserTrackingMode(.followWithHeading, animated: true)
        if applyAnnotations {
            uiView.removeAnnotations(uiView.annotations)
            addAnnotations(to: uiView)
            applyAnnotations = false
        }
        
        if redrawImages {
            if navigationImage != nil {
                if polyline != nil {
                    removePolyline(from: uiView)
                }
                addRoute(to: uiView)
            } else {
                if polyline != nil {
                    removePolyline(from: uiView)
                }
            }
        }
    }
    
    func makeCoordinator() -> RadarView.Coordinator {
        Coordinator(self, mapImages: $mapMarkerImages)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        @Binding var mapImages: [ApiImage]
        private let mapView: RadarView
        let identifier = "radar"
        
        init(_ mapView: RadarView, mapImages: Binding<[ApiImage]>) {
            self.mapView = mapView
            _mapImages = mapImages
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is PointAnnotation {
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation) as! RadarAnnotationView
                annotationView.canShowCallout = false
                annotationView.annotation = annotation
                return annotationView
                
            } else {
                return nil
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
    
    func addRoute(to mapView: MKMapView) {
        let request = MKDirections.Request()
        request.transportType = .walking
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.location!.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: navigationImage!.lat, longitude: navigationImage!.lng)))
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let mapRoute = response?.routes.first else {
                return
            }
            polyline = mapRoute.polyline
            mapView.addOverlay(polyline!)
        }
    }
    
    func removePolyline(from mapView: MKMapView) {
        mapView.removeOverlay(polyline!)
    }
    
    func addAnnotations(to mapView: MKMapView) {
        for image in mapMarkerImages {
            let annotation = PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: image.lat, longitude: image.lng))
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

final class PointAnnotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

