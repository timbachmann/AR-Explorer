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
    
    
    var body: some View {
        ZStack {
            if selectedTab == .ar {
                ARViewRepresentable(arDelegate: arDelegate)
            } else {
                Color.black
            }
            
            VStack {
                Spacer()
                Text(arDelegate.message)
                    .foregroundColor(Color.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
            }
        }.edgesIgnoringSafeArea(.top)
    }
}

//struct AR_Previews: PreviewProvider {
//    static var previews: some View {
//
//    }
//}



