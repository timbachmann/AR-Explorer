//
//  ContentView.swift
//  SwiftCamera
//
//  Created by Tim Bachmann on 28.01.22.
//

import SwiftUI
import Combine
import AVFoundation
import OpenAPIClient

final class CameraModel: ObservableObject {
    private let service = CameraService()
    
    @Published var photo: Photo!
    
    @Published var showAlertError = false
    
    @Published var isFlashOn = false
    
    @Published var willCapturePhoto = false
    
    var alertError: AlertError!
    
    var session: AVCaptureSession
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        self.session = service.session
        
        service.$photo.sink { [weak self] (photo) in
            guard let pic = photo else { return }
            self?.photo = pic
        }
        .store(in: &self.subscriptions)
        
        service.$shouldShowAlertView.sink { [weak self] (val) in
            self?.alertError = self?.service.alertError
            self?.showAlertError = val
        }
        .store(in: &self.subscriptions)
        
        service.$flashMode.sink { [weak self] (mode) in
            self?.isFlashOn = mode == .on
        }
        .store(in: &self.subscriptions)
        
        service.$willCapturePhoto.sink { [weak self] (val) in
            self?.willCapturePhoto = val
        }
        .store(in: &self.subscriptions)
    }
    
    func configure() {
        service.checkForPermissions()
        service.configure()
    }
    
    func capturePhoto() {
        service.capturePhoto()
    }
    
    func flipCamera() {
        service.changeCamera()
    }
    
    func zoom(with factor: CGFloat) {
        service.set(zoom: factor)
    }
    
    func switchFlash() {
        service.flashMode = service.flashMode == .on ? .off : .on
    }
}

struct CameraView: View {
    @StateObject var model = CameraModel()
    @Binding var selectedTab: ContentView.Tab
    @State var currentZoomFactor: CGFloat = 1.0
    @EnvironmentObject var imageData: ImageData
    @State var isLoading: Bool = false
    
    var captureButton: some View {
        Button(action: {
            model.capturePhoto()
            isLoading = true
        }, label: {
            Circle()
                .foregroundColor(.white)
                .frame(width: 78, height: 78, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 70, height: 70, alignment: .center)
                )
        })
    }
    
    var capturedPhotoThumbnail: some View {
        Group {
            if model.photo != nil {
                if !$isLoading.wrappedValue {
                    Image(uiImage: model.photo.image!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 54, height: 54)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        
                } else {
                    ProgressView()
                        .padding()
                        .frame(width: 54, height: 54)
                        .foregroundColor(Color.accentColor)
                        .onAppear(perform: {
                            savePhotoToList()
                        })
                }
                
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 54, height: 54, alignment: .center)
                    .foregroundColor(.gray)
            }
        }
    }
    
    var flipCameraButton: some View {
        Button(action: {
            model.flipCamera()
        }, label: {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 54, height: 54, alignment: .center)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .foregroundColor(.white))
        })
    }
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20.0) {
                    Button(action: {
                        model.switchFlash()
                    }, label: {
                        Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 20, weight: .medium, design: .default))
                    })
                        .accentColor(model.isFlashOn ? .yellow : .white)
                    
                    if selectedTab == .camera {
                        CameraPreview(session: model.session)
                            .gesture(
                                DragGesture().onChanged({ (val) in
                                    //  Only accept vertical drag
                                    if abs(val.translation.height) > abs(val.translation.width) {
                                        //  Get the percentage of vertical screen space covered by drag
                                        let percentage: CGFloat = -(val.translation.height / reader.size.height)
                                        //  Calculate new zoom factor
                                        let calc = currentZoomFactor + percentage
                                        //  Limit zoom factor to a maximum of 5x and a minimum of 1x
                                        let zoomFactor: CGFloat = min(max(calc, 1), 5)
                                        //  Store the newly calculated zoom factor
                                        currentZoomFactor = zoomFactor
                                        //  Sets the zoom factor to the capture device session
                                        model.zoom(with: zoomFactor)
                                    }
                                })
                            )
                            .onAppear {
                                model.configure()
                            }
                            .alert(isPresented: $model.showAlertError, content: {
                                Alert(title: Text(model.alertError.title), message: Text(model.alertError.message), dismissButton: .default(Text(model.alertError.primaryButtonTitle), action: {
                                    model.alertError.primaryAction?()
                                }))
                            })
                            .overlay(
                                Group {
                                    if model.willCapturePhoto {
                                        Color.black
                                    }
                                }
                            )
                            .animation(Animation.easeInOut, value: currentZoomFactor)
                        
                    }
                    HStack {
                        capturedPhotoThumbnail
                        
                        Spacer()
                        
                        captureButton
                        
                        Spacer()
                        
                        flipCameraButton
                        
                    }
                    .onChange(of: model.photo, perform: { newPhoto in
                        savePhotoToList()
                    })
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .statusBar(hidden: true)
        }
    }
}

extension CameraView {
    
    func savePhotoToList() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        let imageToSaveDirectly = ApiImage(id: model.photo.id , data: model.photo.originalData , lat: model.photo.coordinates.latitude, lng: model.photo.coordinates.longitude, date: formatter.string(from: date), source: "iPhone", bearing: 30)
        
        if !imageData.capVisImages.contains(imageToSaveDirectly) {
            imageData.capVisImages.append(imageToSaveDirectly)
            
            let imageToUpload = NewImageRequest(id: model.photo.id, data: model.photo.originalData, lat: model.photo.coordinates.latitude, lng: model.photo.coordinates.longitude, date: formatter.string(from: date), source: "iPhone", bearing: 30)
            
            dump(imageToUpload)
            
            ImageAPI.createImage(newImageRequest: imageToUpload) { (response, error) in
                guard error == nil else {
                    print(error ?? "error")
                    isLoading = false
                    return
                }
                
                if (response != nil) {
                    isLoading = false
                    dump(response)
                }
            }
        }
    }
}

//struct CameraView_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraView()
//    }
//}
