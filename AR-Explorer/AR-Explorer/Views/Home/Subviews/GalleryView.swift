//
//  GalleryView.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 10.03.22.
//

import SwiftUI
import OpenAPIClient

/**
 
 */
struct GalleryView: View {
    
    @EnvironmentObject var imageData: ImageData
    @State private var showingOptions: Bool = false
    @State private var sortingOption: String = "None"
    @State private var notSelectingImages: Bool = true
    @State private var showSettings: Bool = false
    @State private var selectedImages: [String] = []
    @Binding var selectedTab: ContentView.Tab
    private let gridWidth = (UIScreen.main.bounds.width-40)/3
    
    private let threeColumnGrid = [
        GridItem(.flexible(minimum: (UIScreen.main.bounds.width-40)/3, maximum: (UIScreen.main.bounds.width-40)/3)),
        GridItem(.flexible(minimum: (UIScreen.main.bounds.width-40)/3, maximum: (UIScreen.main.bounds.width-40)/3)),
        GridItem(.flexible(minimum: (UIScreen.main.bounds.width-40)/3, maximum: (UIScreen.main.bounds.width-40)/3)),
    ]
    
    /**
     
     */
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
    
    /**
     
     */
    var isPublicOverlay: some View {
        ZStack{
            VStack{
                HStack{
                    Spacer()
                    Image(systemName: "globe.europe.africa")
                        .foregroundColor(Color.white)
                        .frame(width: 21.0, height: 21.0)
                        .padding(5.0)
                }
                Spacer()
            }
        }
    }
    
    var body: some View {
        ScrollView {
            ///
            
            NavigationLink(destination: SettingsView(), isActive: $showSettings) {
                EmptyView()
            }
            
            LazyVGrid(columns: threeColumnGrid, spacing: 10) {
                ForEach(imageData.explorerImages) { item in
                    
                    if $notSelectingImages.wrappedValue {
                        NavigationLink(destination: DetailView(imageIndex: imageData.explorerImages.firstIndex(of: item)!, selectedTab: $selectedTab)) {
                            Image(uiImage: UIImage(data: item.thumbnail)!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: gridWidth, height: gridWidth)
                                .aspectRatio(1, contentMode: .fill)
                                .overlay(item.publicImage == 1 ? isPublicOverlay : nil)
                                .cornerRadius(2)
                                .clipped()
                        }
                    } else {
                        Image(uiImage: UIImage(data: item.thumbnail)!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: gridWidth, height: gridWidth)
                            .aspectRatio(1, contentMode: .fill)
                            .cornerRadius(2)
                            .clipped()
                            .overlay(
                                ZStack {
                                    item.publicImage == 1 ? isPublicOverlay : nil
                                    selectedImages.contains(item.id) ? isSelectedOverlay : nil
                                }
                            )
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
                case "Date (standard)":
                    imageData.explorerImages.sort(by: { $0.date < $1.date })
                case "Date (recent images first)":
                    imageData.explorerImages.sort(by: { $0.date > $1.date })
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
            ///
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
                        ForEach(["Date (standard)", "Date (recent images first)"], id: \.self) { sortOption in
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
                                            imageData.explorerImages.remove(at: imageData.explorerImages.firstIndex(where: {$0.id == imageId})!)
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
            
            ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        $showSettings.wrappedValue.toggle()
                    }, label: {
                        Image(systemName: "gear")
                            .foregroundColor(Color.accentColor)
                    })
            }
        }
    }
}
