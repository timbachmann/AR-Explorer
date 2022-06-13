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
    @State var userThumbLeft: Bool = true
    
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
                
                GroupBox(label:
                    Label("Control Center Alignment", systemImage: "hand.point.up")
                ) {
                    VStack() {
                        Toggle(isOn: $userThumbLeft) {
                            Text("Left handed use")
                        }
                    }
                }
                .padding([.leading, .trailing, .top])
                .onAppear(perform: {
                    userThumbLeft = !settingsModel.userThumbRight
                })
                .onChange(of: userThumbLeft) { value in
                    settingsModel.userThumbRight = !userThumbLeft
                    settingsModel.saveSettingsToFile()
                }

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
