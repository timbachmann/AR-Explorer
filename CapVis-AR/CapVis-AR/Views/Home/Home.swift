//
//  Home.swift
//  CapVis
//
//  Created by Tim Bachmann on 27.01.22.
//

import SwiftUI
import MapKit

struct Home: View {
    
    @State var locationManager = CLLocationManager()
    @State var showMapAlert = false
    @State var coordinateRegion = MKCoordinateRegion.init(center: CLLocationManager().location?.coordinate ?? CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    @State var trackingMode = MapUserTrackingMode.follow
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $coordinateRegion, interactionModes: .all, showsUserLocation: true, userTrackingMode: $trackingMode)
                .ignoresSafeArea(edges: .top)
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    VStack {
                        Button(action: {
                            
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
    ///Path to device settings if location is disabled
    func goToDeviceSettings() {
        guard let url = URL.init(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func zoomOnLocation() {
        coordinateRegion = MKCoordinateRegion.init(center: CLLocationManager().location?.coordinate ?? CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
