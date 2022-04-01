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
    
    private let buttonSize: CGFloat = 48.0
    private let buttonOpacity: CGFloat = 0.95
    @EnvironmentObject var imageData: ImageData
    @EnvironmentObject var locationManagerModel: LocationManagerModel
    @State private var showFavoritesOnly = false
    @State private var mapStyleSheetVisible: Bool = false
    @State private var locationButtonCount: Int = 0
    @State private var isLoading: Bool = false
    @State private var detailId: String = ""
    @State private var showGallery: Bool = false
    @State private var showFilter: Bool = false
    @State private var locationManager = CLLocationManager()
    @State private var trackingMode: MKUserTrackingMode = .follow
    @State private var mapType: MKMapType = .standard
    @State private var showDetail: Bool = false
    @State private var uploadProgress = 0.0
    @State private var showUploadProgress: Bool = false
    @State private var zoomOnLocation: Bool = false
    @State private var changeMapType: Bool = false
    @State private var applyAnnotations: Bool = false
    @State private var coordinateRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: CLLocationManager().location?.coordinate.latitude ?? 47.559_601, longitude: CLLocationManager().location?.coordinate.longitude ?? 7.588_576), span: MKCoordinateSpan(latitudeDelta: 0.0051, longitudeDelta: 0.0051))
    
    var body: some View {
        NavigationView {
            ZStack {
                MapView(mapMarkerImages: $imageData.capVisImages,showDetail: $showDetail, detailId: $detailId, zoomOnLocation: $zoomOnLocation, changeMapType: $changeMapType, applyAnnotations: $applyAnnotations, region: coordinateRegion, mapType: mapType, showsUserLocation: true, userTrackingMode: .follow)
                    .edgesIgnoringSafeArea(.top)
                    .onChange(of: imageData.capVisImages) { tag in
                        applyAnnotations = true
                    }
                
                VStack {
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
                                .background(Color(UIColor.systemBackground).opacity(buttonOpacity))
                                .cornerRadius(10.0, corners: [.topLeft, .topRight])
                                
                                Divider()
                                    .frame(width: buttonSize)
                                    .background(Color(UIColor.systemBackground).opacity(buttonOpacity))
                                
                                Button(action: {
                                    requestZoomOnLocation()
                                }, label: {
                                    Image(systemName: "location")
                                        .padding()
                                        .foregroundColor(Color.accentColor)
                                })
                                .clipShape(Rectangle())
                                .frame(width: buttonSize, height: buttonSize)
                                .background(Color(UIColor.systemBackground).opacity(buttonOpacity))
                                
                                Divider()
                                    .frame(width: buttonSize)
                                    .background(Color(UIColor.systemBackground).opacity(buttonOpacity))
                                
                                NavigationLink(destination: GalleryView(images: $imageData.capVisImages, showSelf: $showGallery), isActive: $showGallery) {
                                    EmptyView()
                                }
                                
                                Button(action: {
                                    $showGallery.wrappedValue.toggle()
                                }, label: {
                                    Image(systemName: "square.grid.2x2")
                                        .padding()
                                        .foregroundColor(Color.accentColor)
                                })
                                .clipShape(Rectangle())
                                .frame(width: buttonSize, height: buttonSize)
                                .background(Color(UIColor.systemBackground).opacity(buttonOpacity))
                                
                                Divider()
                                    .frame(width: buttonSize)
                                    .background(Color(UIColor.systemBackground).opacity(buttonOpacity))
                                
                                Button(action: {
                                    if !$imageData.localFilesSynced.wrappedValue {
                                        syncLocalFiles()
                                    }
                                }, label: {
                                    if $imageData.localFilesSynced.wrappedValue {
                                        Image(systemName: "checkmark.icloud")
                                            .padding()
                                            .foregroundColor(Color.accentColor)
                                    } else {
                                        Image(systemName: "arrow.counterclockwise.icloud")
                                            .padding()
                                            .foregroundColor(Color.accentColor)
                                    }
                                })
                                .clipShape(Rectangle())
                                .frame(width: buttonSize, height: buttonSize)
                                .background(Color(UIColor.systemBackground).opacity(buttonOpacity))
                                
                                Divider()
                                    .frame(width: buttonSize)
                                    .background(Color(UIColor.systemBackground).opacity(buttonOpacity))
                                
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
                                .background(Color(UIColor.systemBackground).opacity(buttonOpacity))
                                .cornerRadius(10.0, corners: [.bottomLeft, .bottomRight])
                            }
                            Spacer()
                        }
                        .padding(8.0)
                    }
                    if $showUploadProgress.wrappedValue {
                        ZStack {
                            Color(UIColor.systemBackground)
                            HStack {
                                ProgressView(value: uploadProgress)
                                    .padding()
                                Image(systemName: "icloud.and.arrow.up")
                            }
                            .padding()
                        }
                        .frame(height: 32)
                    }
                }
                
                if $showDetail.wrappedValue {
                    NavigationLink(destination: DetailView(image: imageData.capVisImages[imageData.capVisImages.firstIndex(where: {$0.id == detailId})!], images: $imageData.capVisImages, showSelf: $showDetail), isActive: $showDetail) {
                        EmptyView()
                    }
                }
                
                if $mapStyleSheetVisible.wrappedValue {
                    ZStack {
                        Color(UIColor.systemBackground)
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
                    FilterView(images: $imageData.capVisImages, showSelf: $showFilter, isLoading: $isLoading, locationManager: locationManagerModel)
                        .frame(width: 350, height: 600)
                        .cornerRadius(20).shadow(radius: 20)
                }
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
    }
}

extension Home {
    
    func applyMapTypeChange() {
        changeMapType = true
        mapStyleSheetVisible = false
        MKMapView.appearance().mapType = mapType
    }
    
    func requestZoomOnLocation() {
        zoomOnLocation = true
        let span: Double = locationButtonCount % 2 == 0 ? 0.005001 : 0.005002
        coordinateRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: CLLocationManager().location?.coordinate.latitude ?? 47.559_601, longitude: CLLocationManager().location?.coordinate.longitude ?? 7.588_576), span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span))
        locationButtonCount += 1
    }
    
    func syncLocalFiles() {
        let progFrac: Double = (1.0/Double(imageData.imagesToUpload.count))
        showUploadProgress = true
        
        for newImage in imageData.imagesToUpload {
            
            let newImageRequest = NewImageRequest(id: newImage.id, data: newImage.data, lat: newImage.lat, lng: newImage.lng, date: newImage.date, source: newImage.source, bearing: newImage.bearing)
            
            ImageAPI.createImage(newImageRequest: newImageRequest) { (response, error) in
                guard error == nil else {
                    print(error ?? "error")
                    return
                }
                
                if (response != nil) {
                    dump(response)
                    imageData.imagesToUpload.remove(at: imageData.imagesToUpload.firstIndex(of: newImage)!)
                    uploadProgress += progFrac
                    imageData.localFilesSynced = imageData.imagesToUpload.isEmpty
                    showUploadProgress = !imageData.imagesToUpload.isEmpty
                    imageData.saveImagesToFile()
                }
            }
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

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
