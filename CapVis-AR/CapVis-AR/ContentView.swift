//
//  ContentView.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 09.02.22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        struct ContentView: View {
            @State private var selectedTab: Tab = .home
            
            enum Tab {
                case home
                case camera
                case ar
            }
            
            var body: some View {
                TabView(selection: $selectedTab) {
                    CameraView()
                        .tabItem {
                            Label("Camera", systemImage: "camera")
                        }
                        .tag(Tab.camera)
                    
                    Home()
                        .tabItem {
                            Label("Home", systemImage: "map")
                        }
                        .tag(Tab.home)
                    AR()
                        .tabItem {
                            Label("AR", systemImage: "arkit")
                        }
                        .tag(Tab.ar)
                }
            }
        }

        struct ContentView_Previews: PreviewProvider {
            static var previews: some View {
                ContentView()
            }
        }
