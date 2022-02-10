//
//  Home.swift
//  CapVis
//
//  Created by Tim Bachmann on 27.01.22.
//

import SwiftUI
import MapKit

struct Home: View {
    
    @EnvironmentObject var imageData: ImageData
    @State private var showFavoritesOnly = false
    
    var filteredImages: [CapVisImage] {
        imageData.capVisImages.filter { capVisImage in
            (!showFavoritesOnly)
        }
    }
    @State var locationManager = CLLocationManager()
    @State var showMapAlert = false
    @State var trackingMode = MapUserTrackingMode.follow
    @State var coordinateRegion = MKCoordinateRegion.init(center: CLLocationManager().location?.coordinate ?? CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $coordinateRegion, interactionModes: .all, showsUserLocation: true, userTrackingMode: $trackingMode, annotationItems: filteredImages)
                { (capVisImage) in
                    MapMarker(coordinate: capVisImage.locationCoordinate,
                                tint: Color.red);
                    }
                .ignoresSafeArea(edges: .top)
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    VStack {
                        Button(action: {
                            // capVisImage = CapVisImage.init(lat: 47.61497, long: 7.66457)
                        }, label: {
                            Image(systemName: "map")
                        })
                            .padding(10.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10.0)
                                    .stroke(lineWidth: 2.0)
                                    .fill(Color.accentColor)
                            ).background(RoundedRectangle(cornerRadius: 10.0).fill(Color.white.opacity(0.3)))
                        Button(action: {
                            zoomOnLocation()
                        }, label: {
                            Image(systemName: "location")
                        })
                            .padding(10.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10.0)
                                    .stroke(lineWidth: 2.0)
                                    .fill(Color.accentColor)
                            ).background(RoundedRectangle(cornerRadius: 10.0).fill(Color.white.opacity(0.3)))
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "text.magnifyingglass")
                        })
                            .padding(10.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10.0)
                                    .stroke(lineWidth: 2.0)
                                    .fill(Color.accentColor)
                            ).background(RoundedRectangle(cornerRadius: 10.0).fill(Color.white.opacity(0.3)))
                    }
                    .padding(20.0)
                    Spacer()
                }
            }
        }
    }
}

extension Home {
    func zoomOnLocation() {
        coordinateRegion = MKCoordinateRegion.init(center: CLLocationManager().location?.coordinate ?? CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .environmentObject(ImageData())
    }
}
