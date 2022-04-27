//
//  Settings.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 20.04.22.
//

import SwiftUI
import OpenAPIClient

/**
 
 */
struct SettingsView: View {
    
    @EnvironmentObject var settingsModel: SettingsModel
    @State var serverAddress: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                GroupBox(label:
                    Label("Server Address", systemImage: "link.icloud")
                ) {
                    VStack(alignment: .leading) {
                        TextField(settingsModel.serverAddress, text: $serverAddress, onCommit: {
                            settingsModel.serverAddress = serverAddress
                            settingsModel.saveSettingsToFile()
                        })
                    }
                }
                .padding([.leading, .trailing, .top])
                .onAppear(perform: {
                    serverAddress = settingsModel.serverAddress
                })
                                
                Spacer()
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
