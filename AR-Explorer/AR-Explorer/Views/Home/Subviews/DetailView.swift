//
//  DetailView.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 10.03.22.
//

import SwiftUI
import OpenAPIClient

/**
 
 */
struct DetailView: View {
    
    @State var currentScale: CGFloat = 1.0
    @State var previousScale: CGFloat = 1.0
    @State var currentOffset = CGSize.zero
    @State var previousOffset = CGSize.zero
    
    @State private var detailImage: Image?
    @State private var detailDate: Text?
    @State private var detailYaw: Text?
    @State private var detailSource: Text?
    var imageIndex: Int?
    @State var image: ApiImage = ApiImage()
    @State var index: Int? = nil
    @State var isLoading: Bool = true
    @State private var showingOptions = false
    @State private var showingUpdate = false
    @Binding var selectedTab: ContentView.Tab
    @EnvironmentObject var imageData: ImageData
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            if $isLoading.wrappedValue {
                ProgressView()
            } else {
                VStack {
                    Spacer()
                    detailImage?
                        .resizable()
                        .zIndex(1)
                        .aspectRatio(contentMode: .fit)
                        .offset(x: self.currentOffset.width, y: self.currentOffset.height)
                        .scaleEffect(max(self.currentScale, 1.0))
                        .gesture(MagnificationGesture()
                            .onChanged { value in
                                let delta = value / self.previousScale
                                self.previousScale = value
                                self.currentScale = self.currentScale * delta
                            }
                            .onEnded { value in self.previousScale = 1.0 }
                        )
                        .clipped()
                    Spacer()
                    Button(action: {
                        if image != ApiImage() {
                            imageData.navigationImage = image
                            selectedTab = .ar
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "arrow.triangle.turn.up.right.diamond")
                                .foregroundColor(Color(uiColor: UIColor.systemBackground))
                            Text("Directions in AR")
                                .foregroundColor(Color(uiColor: UIColor.systemBackground))
                        }
                    })
                    .frame(width: 200.0, height: 48.0)
                    .background(Color.accentColor)
                    .cornerRadius(10.0, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .onAppear {
            loadImage()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    detailDate ?? Text("").font(.headline)
                    detailSource ?? Text("").font(.subheadline)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingUpdate = true
                }, label: {
                    Image(systemName: "globe.europe.africa")
                        .foregroundColor(Color.accentColor)
                })
                .actionSheet(isPresented: $showingUpdate) {
                    return ActionSheet(title: Text("Make image public?"), buttons: [
                        .destructive(Text("Yes")){
                            
                            let localIndex = imageData.imagesToUpload.firstIndex{$0.id == image.id}
                            if (localIndex != nil) {
                                return
                            }
                            ImageAPI.updateImageById(userID: UIDevice.current.identifierForVendor!.uuidString, imageId: image.id) { (response, error) in
                                guard error == nil else {
                                    print(error ?? "Could not update image!")
                                    return
                                }
                                
                                if (response != nil) {
                                    imageData.explorerImages.remove(at: imageIndex!)
                                    imageData.saveImagesToFile()
                                    self.mode.wrappedValue.dismiss()
                                    dump(response)
                                }
                            }
                        },
                        .cancel()
                    ])
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingOptions = true
                }, label: {
                    Image(systemName: "trash.circle")
                        .foregroundColor(Color.accentColor)
                })
                .actionSheet(isPresented: $showingOptions) {
                    return ActionSheet(title: Text("Delete image?"), buttons: [
                        .destructive(Text("Delete")){
                            
                            let localIndex = imageData.imagesToUpload.firstIndex{$0.id == image.id}
                            if (localIndex != nil) {
                                imageData.imagesToUpload.remove(at: localIndex!)
                            }
                            ImageAPI.deleteImageById(userID: UIDevice.current.identifierForVendor!.uuidString, imageId: image.id) { (response, error) in
                                guard error == nil else {
                                    print(error ?? "Could not delete image!")
                                    return
                                }
                                
                                if (response != nil) {
                                    imageData.explorerImages.remove(at: imageIndex!)
                                    imageData.saveImagesToFile()
                                    self.mode.wrappedValue.dismiss()
                                    dump(response)
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

extension DetailView {
    
    /**
     
     */
    func loadImage() {
        image = imageData.explorerImages[imageIndex ?? 0]
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = .current
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date: Date = formatter.date(from: image.date)!
        formatter.dateFormat = "dd.MM.yyyy - HH:mm:ss"
        
        detailDate = Text(formatter.string(from: date))
        detailSource = Text(image.source)
        detailYaw = Text("Yaw: " + String(image.yaw))
        
        if image.data == Data() {
            ImageAPI.getImageById(userID: UIDevice.current.identifierForVendor!.uuidString, imageId: image.id) { (response, error) in
                guard error == nil else {
                    print(error ?? "Unknown Error")
                    return
                }
                
                if (response != nil) {
                    index = imageData.explorerImages.firstIndex{$0.id == image.id}!
                    imageData.explorerImages[index!].data = response!.data
                    image = imageData.explorerImages[index!]
                    setImage()
                    dump(response)
                }
            }
        } else {
            setImage()
        }
    }
    
    /**
     
     */
    func setImage() {
        let uiImage = UIImage(data: image.data)
        detailImage = Image(uiImage: uiImage!)
        isLoading = false
    }
}
