//
//  Home.swift
//  CapVis
//
//  Created by Tim Bachmann on 27.01.22.
//

import SwiftUI
import MapKit
import ARKit

struct Home: View {
    
    @EnvironmentObject var imageData: ImageData
    @State private var showFavoritesOnly = false
    @State private var mapStyleSheetVisible: Bool = false
    
    private var filteredImages: [CapVisImage] {
        imageData.capVisImages.filter { capVisImage in
            (!showFavoritesOnly)
        }
    }
    
    private let buttonSize: CGFloat = 42.0
    private let buttonOpacity: CGFloat = 0.95
    @State private var images: [MapMarkerImage] = []
    @State private var locationManager = CLLocationManager()
    @State private var showMapAlert = false
    @State private var trackingMode = MKUserTrackingMode.follow
    @State private var mapType: MKMapType = .standard
    @State private var coordinateRegion = MKCoordinateRegion.init(center: CLLocationManager().location?.coordinate ?? CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    
    
    var body: some View {
        ZStack {
            MapViewRepresentable(mapMarkerImages: $images, region: coordinateRegion, mapType: mapType, showsUserLocation: true, userTrackingMode: trackingMode)
                .edgesIgnoringSafeArea(.top)
            
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    VStack(spacing: 0) {
                        Button(action: {
                            mapStyleSheetVisible = !mapStyleSheetVisible
                        }, label: {
                            Image(systemName: "map")
                                .padding()
                                .foregroundColor(Color.accentColor)
                        })
                            .frame(width: buttonSize, height: buttonSize)
                            .background(Color.white.opacity(buttonOpacity))
                            .cornerRadius(10.0, corners: [.topLeft, .topRight])
                        
                        Divider()
                            .frame(width: buttonSize)
                            .background(Color.white.opacity(buttonOpacity))
                        
                        Button(action: {
                            zoomOnLocation()
                        }, label: {
                            Image(systemName: "location")
                                .padding()
                                .foregroundColor(Color.accentColor)
                        })
                            .clipShape(Rectangle())
                            .frame(width: buttonSize, height: buttonSize)
                            .background(Color.white.opacity(buttonOpacity))
                        
                        Divider()
                            .frame(width: buttonSize)
                            .background(Color.white.opacity(buttonOpacity))
                        
                        Button(action: {
                            images = imageData.capVisImages.map { MapMarkerImage(title: $0.name, coordinate: $0.locationCoordinate) }
                        }, label: {
                            Image(systemName: "text.magnifyingglass")
                                .padding()
                                .foregroundColor(Color.accentColor)
                        })
                            .frame(width: buttonSize, height: buttonSize)
                            .background(Color.white.opacity(buttonOpacity))
                            .cornerRadius(10.0, corners: [.bottomLeft, .bottomRight])
                    }
                    .padding(.top, 56)
                    Spacer()
                }
                .padding(8.0)
            }
            
            if $mapStyleSheetVisible.wrappedValue {
                ZStack {
                    Color.white
                    VStack {
                        Text("Map Style")
                        Spacer()
                        Picker("", selection: $mapType) {
                            Text("Standard").tag(MKMapType.standard)
                            Text("Satellite").tag(MKMapType.satellite)
                            Text("Hybrid").tag(MKMapType.hybrid)
                        }
                            .pickerStyle(SegmentedPickerStyle())
                            .font(.largeTitle)
                            .onChange(of: mapType) { tag in mapStyleSheetVisible = false }
                    }.padding()
                }
                .frame(width: 300, height: 100)
                .cornerRadius(20).shadow(radius: 20)
            }
        }
    }
}

extension Home {
    func zoomOnLocation() {
        coordinateRegion = MKCoordinateRegion.init(center: CLLocationManager().location?.coordinate ?? CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .environmentObject(ImageData())
    }
}
