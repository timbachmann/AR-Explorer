//
//  GalleryView.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 10.03.22.
//

import SwiftUI
import OpenAPIClient

struct GalleryView: View {
    
    @Binding var images: [ApiImage]
    @Binding var showSelf: Bool
    @State var showDetail: Bool = true
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    private let threeColumnGrid = [
        GridItem(.flexible(minimum: 40)),
        GridItem(.flexible(minimum: 40)),
        GridItem(.flexible(minimum: 40)),
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: threeColumnGrid, spacing: 20) {
                ForEach(images) { item in
                    
                    NavigationLink(destination: DetailView(image: item, images: $images, showSelf: $showDetail)) {
                        
                        Image(uiImage: UIImage(data: item.thumbnail)!)
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fill)
                            .cornerRadius(4)
                    }
                }
            }.padding()
        }
        .navigationTitle(Text("Photos"))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            self.mode.wrappedValue.dismiss()
            showSelf = false
        }){
            HStack {
                Image(systemName: "chevron.backward")
                Text("Back")
            }
            
        })
        
    }
}

//struct GalleryView_Previews: PreviewProvider {
//    static var previews: some View {
//        GalleryView(showSelf: true)
//            .environmentObject(ImageData())
//    }
//}
