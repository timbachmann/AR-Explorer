//
//  CapVis_ARApp.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 09.02.22.
//

import SwiftUI

@main
struct CapVis_ARApp: App {
    @StateObject private var imageData = ImageData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(imageData)
        }
    }
}
