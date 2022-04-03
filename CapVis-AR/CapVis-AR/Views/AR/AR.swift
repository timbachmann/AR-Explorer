//
//  AR.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 28.01.22.
//

import SwiftUI
import ARKit

struct AR: View {
    
    @Binding var selectedTab: ContentView.Tab
    @ObservedObject var arDelegate = ARDelegate()
    @State var redrawImages: Bool = false
    
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



