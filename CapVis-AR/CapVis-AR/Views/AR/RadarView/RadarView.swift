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
    @Binding var applyAnnotations: Bool
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
    }
    
    func makeCoordinator() -> RadarView.Coordinator {
        Coordinator(self, mapImages: $mapMarkerImages)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        @Binding var mapImages: [ApiImage]
        private let mapView: RadarView
        private var route: MKRoute? = nil
        let identifier = "radar"
        
        init(_ mapView: RadarView, mapImages: Binding<[ApiImage]>) {
            self.mapView = mapView
            _mapImages = mapImages
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            print("vewrvvrvw")
            if annotation is PointAnnotation {
                print("test")
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation) as! RadarAnnotationView
                annotationView.canShowCallout = false
                annotationView.annotation = annotation
                return annotationView
                
            } else {
                return nil
            }
        }
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

