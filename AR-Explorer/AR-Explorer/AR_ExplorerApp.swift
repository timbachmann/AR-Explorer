//
//  CapVis_ARApp.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 09.02.22.
//

import SwiftUI

/**
 Starting point for the CapVis-AR application.
 Initializes App delegate to deal with notifications and environment objects to pass to child views.
 */
@main
struct AR_ExplorerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var imageData = ImageData()
    @StateObject private var locationManagerModel = LocationManagerModel()
    @StateObject private var settingsModel = SettingsModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(imageData)
                .environmentObject(locationManagerModel)
                .environmentObject(settingsModel)
        }
    }
}
