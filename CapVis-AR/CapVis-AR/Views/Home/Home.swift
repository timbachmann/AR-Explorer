//
//  Home.swift
//  CapVis
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
    @State private var detailImage: Image?
    @State private var detailDate: Text?
    @State private var detailSource: Text?
    
    private var filteredImages: [ApiImage] {
        imageData.capVisImages.filter { capVisImage in
            (!showFavoritesOnly)
        }
    }
    
    private let buttonSize: CGFloat = 42.0
    private let buttonOpacity: CGFloat = 0.95
    @State private var locationManager = CLLocationManager()
    @State private var trackingMode: MKUserTrackingMode = .follow
    @State private var mapType: MKMapType = .hybrid
    @State private var showDetail: Bool = false
    @State private var cl = CLLocationCoordinate2D(latitude: CLLocationManager().location?.coordinate.latitude ?? 34.011_286, longitude: CLLocationManager().location?.coordinate.longitude ?? -116.166_868)
    @State private var coordinateRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: CLLocationManager().location?.coordinate.latitude ?? 34.011_286, longitude: CLLocationManager().location?.coordinate.longitude ?? -116.166_868), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    
    
    var body: some View {
        ZStack {
            MapViewRepresentable(mapMarkerImages: $imageData.capVisImages,showDetail: $showDetail, detailId: $detailId, region: coordinateRegion, mapType: mapType, showsUserLocation: true, userTrackingMode: .follow)
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
                            isLoading = true
                            ImageAPI.getAllImages() { (response, error) in
                                guard error == nil else {
                                    print(error ?? "error")
                                    return
                                }
                                
                                if (response != nil) {
                                    imageData.capVisImages = response?.apiImages ?? imageData.capVisImages
                                    dump(response?.apiImages)
                                    isLoading = false
                                    
                                }
                            }
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
                        .onChange(of: mapType) { tag in
                            applyMapTypeChange()
                        }
                    }.padding()
                }
                .frame(width: 300, height: 100)
                .cornerRadius(20).shadow(radius: 20)
            }
            
            if $showDetail.wrappedValue {
                ZStack {
                    ZStack {
                        Color.white
                        VStack {
                            detailImage?
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250)
                            Spacer()
                            detailDate?
                                .fontWeight(Font.Weight.heavy)
                            detailSource?
                                .fontWeight(Font.Weight.regular)
                        }
                        .padding()
                        .onAppear { loadImage() }
                    }
                    .frame(width: 300, height: 400)
                    .cornerRadius(20).shadow(radius: 20)
                    .onTapGesture {
                        showDetail = false
                    }
                }
            }
        }
    }
}

extension Home {
    
    func loadImage(){
        if let index = imageData.capVisImages.firstIndex(where: {$0.id == detailId}) {
            let apiImage: ApiImage = imageData.capVisImages[index]
            let uiImage = UIImage(data: apiImage.data)
            detailImage = Image(uiImage: uiImage!)
            
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            let date: Date = formatter.date(from: apiImage.date)!
            formatter.dateFormat = "dd.MM.yyyy - HH:mm:ss"
            
            detailDate = Text(formatter.string(from: date))
            detailSource = Text(apiImage.source)
        }
    }
    
    func applyMapTypeChange() {
        mapStyleSheetVisible = false
        MKMapView.appearance().mapType = mapType
    }
    
    func zoomOnLocation() {
        let span: Double = locationButtonCount % 2 == 0 ? 0.01 : 0.011
        coordinateRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: CLLocationManager().location?.coordinate.latitude ?? 34.011_286, longitude: CLLocationManager().location?.coordinate.longitude ?? -116.166_868), span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span))
        locationButtonCount += 1
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
