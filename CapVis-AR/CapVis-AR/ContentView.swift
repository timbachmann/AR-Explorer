//
//  ContentView.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 09.02.22.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    let pub = NotificationCenter.default.publisher(for: Notification.Name("capVisAR"))
    
    enum Tab {
        case home
        case ar
    }
    
    init() {
        UITabBar.appearance().barTintColor = .systemBackground
        UITabBar.appearance().unselectedItemTintColor = UIColor(named: "TabBarUnselected")
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Home()
                .tabItem {
                    Label("Home", systemImage: "map")
                }
                .tag(Tab.home)
            AR(selectedTab: $selectedTab)
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
