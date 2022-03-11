//
//  Home.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 27.01.22.
//

import SwiftUI
import MapKit
import ARKit
import OpenAPIClient

struct Home: View {
    @EnvironmentObject var imageData: ImageData
    @State private var showFavoritesOnly = false
    @State private var mapStyleSheetVisible: Bool = false
    @State private var locationButtonCount: Int = 0
    @State private var isLoading: Bool = false
    @State private var detailId: String = ""
    @State private var showGallery: Bool = false
    private let buttonSize: CGFloat = 48.0
    private let buttonOpacity: CGFloat = 0.95
    @State private var showFilter: Bool = false
    @State private var locationManager = CLLocationManager()
    @State private var trackingMode: MKUserTrackingMode = .follow
    @State private var mapType: MKMapType = .standard
    @State private var showDetail: Bool = false
    @State private var coordinateRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: CLLocationManager().location?.coordinate.latitude ?? 34.011_286, longitude: CLLocationManager().location?.coordinate.longitude ?? -116.166_868), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    private var filteredImages: [ApiImage] {
        imageData.capVisImages.filter { capVisImage in
            (!showFavoritesOnly)
        }
    }
    
    var body: some View {
        ZStack {
            MapView(mapMarkerImages: $imageData.capVisImages,showDetail: $showDetail, detailId: $detailId, region: coordinateRegion, mapType: mapType, showsUserLocation: true, userTrackingMode: .follow)
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
                            $showGallery.wrappedValue.toggle()
                        }, label: {
                            Image(systemName: "square.grid.2x2")
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
                            $showFilter.wrappedValue.toggle()
                        }, label: {
                            if $isLoading.wrappedValue {
                                ProgressView()
                                    .padding()
                                    .foregroundColor(Color.accentColor)
                            } else {
                                Image(systemName: "text.magnifyingglass")
                                    .padding()
                                    .foregroundColor(Color.accentColor)
                            }
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
            
            if $showGallery.wrappedValue {
                NavigationView {
                    NavigationLink(destination: GalleryView(images: $imageData.capVisImages, showSelf: $showGallery), isActive: $showGallery) {}
                }
            }
            
            if $showDetail.wrappedValue {
                NavigationView {
                    NavigationLink(destination: DetailView(image: imageData.capVisImages[imageData.capVisImages.firstIndex(where: {$0.id == detailId})!], showSelf: $showDetail), isActive: $showDetail) {}
                }
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
                            Text("Flyover").tag(MKMapType.hybridFlyover)
                            Text("Hybrid").tag(MKMapType.hybrid)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .font(.largeTitle)
                        .onChange(of: mapType) { tag in
                            applyMapTypeChange()
                        }
                    }.padding()
                }
                .frame(width: 300, height: 100)
                .cornerRadius(20).shadow(radius: 20)
            }
            
            if $showFilter.wrappedValue {
                FilterView(images: $imageData.capVisImages, showSelf: $showFilter, isLoading: $isLoading)
                .frame(width: 350, height: 600)
                .cornerRadius(20).shadow(radius: 20)
            }
        }
    }
}

extension Home {
    
    func applyMapTypeChange() {
        mapStyleSheetVisible = false
        MKMapView.appearance().mapType = mapType
    }
    
    func zoomOnLocation() {
        let span: Double = locationButtonCount % 2 == 0 ? 0.01 : 0.011
        coordinateRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: CLLocationManager().location?.coordinate.latitude ?? 34.011_286, longitude: CLLocationManager().location?.coordinate.longitude ?? -116.166_868), span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span))
        locationButtonCount += 1
    }
    
    func getCacheDirectoryPath() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
    
    func saveImagesToFile(images: [ApiImage]) {
        let path = getCacheDirectoryPath().appendingPathComponent("imageData.json")
        
        do {
            let jsonData = try JSONEncoder().encode(images)
            try jsonData.write(to: path)
        } catch {
            print("Error writing to JSON file: \(error)")
        }
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

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        if lhs.center.latitude == rhs.center.latitude && lhs.span.latitudeDelta == rhs.span.latitudeDelta && lhs.span.longitudeDelta == rhs.span.longitudeDelta {
            return true
        } else {
            return false
        }
    }
}
