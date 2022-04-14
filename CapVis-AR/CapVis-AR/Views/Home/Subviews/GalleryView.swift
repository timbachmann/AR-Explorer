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
    @State private var showingOptions: Bool = false
    @State private var sortingOption: String = "None"
    @State private var notSelectingImages: Bool = true
    @State private var selectedImages: [String] = []
    @Binding var selectedTab: ContentView.Tab
    
    private let threeColumnGrid = [
        GridItem(.flexible(minimum: 40)),
        GridItem(.flexible(minimum: 40)),
        GridItem(.flexible(minimum: 40)),
    ]
    
    var isSelectedOverlay: some View {
        ZStack{
            Color.gray.opacity(0.3)
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Circle()
                        .foregroundColor(Color.white)
                        .frame(width: 21.0, height: 21.0)
                        .padding(5.0)
                        .overlay(
                            Image(systemName: "checkmark.circle.fill").foregroundColor(Color.accentColor)
                            
                        )
                }
            }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: threeColumnGrid, spacing: 20) {
                ForEach(imageData.capVisImages) { item in
                    
                    if $notSelectingImages.wrappedValue {
                        NavigationLink(destination: DetailView(imageIndex: imageData.capVisImages.firstIndex(of: item)!, selectedTab: $selectedTab)) {
                            Image(uiImage: UIImage(data: item.thumbnail)!)
                                .resizable()
                                .scaledToFill()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fill)
                                .cornerRadius(4)
                        }
                    } else {
                        Image(uiImage: UIImage(data: item.thumbnail)!)
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fill)
                            .cornerRadius(4)
                        .overlay(selectedImages.contains(item.id) ? isSelectedOverlay : nil)
                                        
                            .onTapGesture {
                                if selectedImages.contains(item.id) {
                                    selectedImages.remove(at: selectedImages.firstIndex(of: item.id)!)
                                } else {
                                    selectedImages.append(item.id)
                                }
                            }
                    }
                }
            }
            .padding()
            .onChange(of: sortingOption) { newSelection in
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
            .onChange(of: notSelectingImages) { newValue in
                selectedImages.removeAll()
            }
        }
        .navigationTitle(Text("Photos"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    $notSelectingImages.wrappedValue.toggle()
                }, label: {
                    if $notSelectingImages.wrappedValue {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(Color.accentColor)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.accentColor)
                    }
                })
                
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if $notSelectingImages.wrappedValue {
                    Button(action: {
                        showingOptions = true
                    }, label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(Color.accentColor)
                    })
                    .confirmationDialog("Sort list by", isPresented: $showingOptions, titleVisibility: .visible) {
                        ForEach(["Date", "Radius"], id: \.self) { sortOption in
                            Button(sortOption) {
                                sortingOption = sortOption
                            }
                        }
                    }
                } else {
                    Button(action: {
                        showingOptions = true
                    }, label: {
                        Image(systemName: "trash.circle")
                            .foregroundColor(Color.accentColor)
                    })
                    .actionSheet(isPresented: $showingOptions) {
                        return ActionSheet(title: Text("Delete selected images?"), buttons: [
                            .destructive(Text("Delete")) {
                                for imageId in selectedImages {
                                    let localIndex = imageData.imagesToUpload.firstIndex{$0.id == imageId}
                                    if (localIndex != nil) {
                                        imageData.imagesToUpload.remove(at: localIndex!)
                                    }
                                    ImageAPI.deleteImageById(userID: UIDevice.current.identifierForVendor!.uuidString, imageId: imageId) { (response, error) in
                                        guard error == nil else {
                                            print(error ?? "Could not delete image!")
                                            return
                                        }
                                        
                                        if (response != nil) {
                                            imageData.capVisImages.remove(at: imageData.capVisImages.firstIndex(where: {$0.id == imageId})!)
                                            imageData.saveImagesToFile()
                                            dump(response)
                                        }
                                    }
                                }
                            },
                            .cancel()
                        ])
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
