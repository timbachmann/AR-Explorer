//
//  AR.swift
//  CapVis
//
//  Created by Tim Bachmann on 28.01.22.
//

import SwiftUI
import ARKit

struct AR: View {
    
    @ObservedObject var arDelegate = ARDelegate()
    
    var body: some View {
        ZStack {
            ARViewRepresentable(arDelegate: arDelegate)
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

struct AR_Previews: PreviewProvider {
    static var previews: some View {
        AR()
    }
}



