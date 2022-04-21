//
//  CameraView.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 28.01.22.
//

import SwiftUI
import Combine
import CoreLocation
import AVFoundation
import OpenAPIClient

/**
 
 */
struct CameraView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var model = CameraModel()
    @State var currentZoomFactor: CGFloat = 1.0
    @EnvironmentObject var imageData: ImageData
    @EnvironmentObject var locationManagerModel: LocationManagerModel
    @State var isLoading: Bool = false
    
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
                    
                    CameraPreview(session: model.session)
                        .gesture(
                            DragGesture().onChanged({ (val) in
                                if abs(val.translation.height) > abs(val.translation.width) {
                                    let percentage: CGFloat = -(val.translation.height / reader.size.height)
                                    let calc = currentZoomFactor + percentage
                                    let zoomFactor: CGFloat = min(max(calc, 1), 5)
                                    currentZoomFactor = zoomFactor
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
                    
                    HStack {
                        if model.photo != nil {
                            if !$isLoading.wrappedValue {
                                Image(uiImage: UIImage(data: model.photo.originalData)!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 54, height: 54)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .onAppear(perform: {
                                        dismiss()
                                    })
                                
                            } else {
                                ProgressView()
                                    .padding()
                                    .frame(width: 54, height: 54)
                                    .foregroundColor(Color.accentColor)
                            }
                            
                        } else {
                            Button(action: {
                                dismiss()
                            }, label: {
                                HStack {
                                    Image(systemName: "chevron.backward")
                                    Text("Back")
                                }
                            })
                        }
                        
                        Spacer()
                        Button(action: {
                            model.capturePhoto(heading: locationManagerModel.heading)
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
                        Spacer()
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
                    .onChange(of: model.photo, perform: { newPhoto in
                        savePhotoToList()
                    })
                    .padding(.horizontal, 20)
                    Spacer()
                }
            }
            .statusBar(hidden: true)
            .navigationBarHidden(true)
        }
    }
}

extension CameraView {
    
    /**
     
     */
    func dismiss() {
        self.model.session.stopRunning()
        self.mode.wrappedValue.dismiss()
    }
    
    /**
     
     */
    func savePhotoToList() {
        print("Saving photo...")
        let date = Date()
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = .current
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let imageToSaveLocally = ApiImage(id: model.photo.id , data: model.photo.originalData, thumbnail: model.photo.originalData , lat: model.photo.coordinates.latitude, lng: model.photo.coordinates.longitude, date: formatter.string(from: date), source: UIDevice.current.name, bearing: Int(model.photo.heading.trueHeading), yaw: model.photo.yaw, pitch: model.photo.pitch)
        
        if !imageData.explorerImages.contains(imageToSaveLocally) && !imageData.imagesToUpload.contains(imageToSaveLocally){
            imageData.explorerImages.append(imageToSaveLocally)
            imageData.imagesToUpload.append(imageToSaveLocally)
            imageData.saveImagesToFile()
        }
        isLoading = false
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
