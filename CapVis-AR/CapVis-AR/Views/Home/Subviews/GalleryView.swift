//
//  GalleryView.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 10.03.22.
//

import SwiftUI
import OpenAPIClient

struct GalleryView: View {
    
    @EnvironmentObject var imageData: ImageData
    @State private var showingOptions = false
    @State private var selection = "None"
    
    private let threeColumnGrid = [
        GridItem(.flexible(minimum: 40)),
        GridItem(.flexible(minimum: 40)),
        GridItem(.flexible(minimum: 40)),
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: threeColumnGrid, spacing: 20) {
                ForEach(imageData.capVisImages) { item in
                    NavigationLink(destination: DetailView(imageIndex: imageData.capVisImages.firstIndex(of: item)!)) {
                        Image(uiImage: UIImage(data: item.thumbnail)!)
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fill)
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
            .onChange(of: selection) { newSelection in
                switch newSelection {
                case "Date":
                    imageData.capVisImages.sort(by: { $0.date < $1.date })
                case "Radius":
                    //imageData.capVisImages.sort(by: { $0.date > $1.date })
                    print("Not implemented")
                default:
                    print("No sorting option selected")
                }
                
            }
        }
        .navigationTitle(Text("Photos"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingOptions = true
                }, label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .padding()
                        .foregroundColor(Color.accentColor)
                })
                .confirmationDialog("Sort list by", isPresented: $showingOptions, titleVisibility: .visible) {
                    ForEach(["Date", "Radius"], id: \.self) { sortOption in
                        Button(sortOption) {
                            selection = sortOption
                        }
                    }
                }
            }
        }
    }
}

//struct GalleryView_Previews: PreviewProvider {
//    static var previews: some View {
//        GalleryView(showSelf: true)
//            .environmentObject(ImageData())
//    }
//}
