//
//  ContentView.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 09.02.22.
//

import SwiftUI
import Combine

/**
 Contains main tab view with map and ar tab.
 Receiver for notification events.
 */
struct ContentView: View {
    @State private var selectedTab: Tab = .home
    let pub = NotificationCenter.default.publisher(for: Notification.Name("capVisAR"))
    
    public enum Tab {
        case home
        case ar
    }
    
    init() {
        UITabBar.appearance().barTintColor = .systemBackground
        UITabBar.appearance().unselectedItemTintColor = UIColor(named: "TabBarUnselected")
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MapTab(selectedTab: $selectedTab)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(Tab.home)
            ARTab(selectedTab: $selectedTab)
                .tabItem {
                    Label("AR", systemImage: "arkit")
                }
                .tag(Tab.ar)
        }
        .onReceive(pub) { data in
             if data.object is UNNotificationContent {
                 selectedTab = .ar
             }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ImageData())
    }
}
