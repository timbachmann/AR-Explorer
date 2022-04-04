//
//  AR.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 28.01.22.
//

import SwiftUI
import ARKit
import MapKit

struct AR: View {
    
    @EnvironmentObject var imageData: ImageData
    @Binding var selectedTab: ContentView.Tab
    @ObservedObject var arDelegate = ARDelegate()
    @State var redrawImages: Bool = false
    @State private var applyAnnotations: Bool = true
    @State private var coordinateRegion = MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: CLLocationManager().location?.coordinate.latitude ?? 47.559_601, longitude: CLLocationManager().location?.coordinate.longitude ?? 7.588_576), span: MKCoordinateSpan(latitudeDelta: 0.0051, longitudeDelta: 0.0051))
    
    var body: some View {
        ZStack {
            Color.black
            if selectedTab == .ar {
                ARViewRepresentable(arDelegate: arDelegate, redrawImages: $redrawImages)
            } else {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .padding()
                    .foregroundColor(Color.accentColor)
            }
            
            VStack {
                HStack {
                    Spacer()
                    RadarView(mapMarkerImages: $imageData.capVisImages, applyAnnotations: $applyAnnotations, region: coordinateRegion)
                        .frame(width: 96.0, height: 96.0)
                        .clipShape(
                            Circle()
                                .size(width: 120.0, height: 96.0)
                                .offset(x: -12.0, y: 0)
                            )
                        .onChange(of: imageData.capVisImages) { tag in
                            applyAnnotations = true
                        }
                        .offset(x: 0.0, y: 40)
                }
                Spacer()
                HStack (alignment: .center){
                    Spacer()
                    Text(arDelegate.message)
                        .foregroundColor(Color.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                    Spacer()
                    Button(action: {
                        $redrawImages.wrappedValue.toggle()
                    }, label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .padding()
                            .foregroundColor(Color.accentColor)
                    })
                    .frame(width: 48.0, height: 48.0)
                    .background(Color(UIColor.systemBackground).opacity(0.95))
                    .cornerRadius(10.0, corners: [.bottomLeft, .bottomRight, .topLeft, .topRight])
                }
            }
            .padding()
                    
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct AR_Previews: PreviewProvider {
    static var previews: some View {
        AR(selectedTab: .constant(ContentView.Tab.ar))
            .environmentObject(ImageData())
    }
}



