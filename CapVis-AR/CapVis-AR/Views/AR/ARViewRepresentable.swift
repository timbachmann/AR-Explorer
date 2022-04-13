//
//  ARViewRepresentable.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 28.01.22.
//

import ARKit
import SwiftUI
import OpenAPIClient
import CoreMotion

struct ARViewRepresentable: UIViewRepresentable {
    let arDelegate:ARDelegate
    @Binding var redrawImages: Bool
    @EnvironmentObject var imageData: ImageData
    @EnvironmentObject var locationManagerModel: LocationManagerModel
    @State var nodes: [SCNNode] = []
    
    func makeUIView(context: Context) -> some UIView {
        let arView = ARSCNView(frame: .zero)
        //arView.showsStatistics = true
        //arView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        arDelegate.setARView(arView)
        loadImageNodes()
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if redrawImages {
            arDelegate.removeAllNodes()
            loadImageNodes()
            redrawImages = false
        }
    }
    
    func loadImageNodes() {
        for apiImage in imageData.capVisImages {
            let nodeLocation = CLLocation(latitude: apiImage.lat, longitude: apiImage.lng)
            let distance = locationManagerModel.location.distance(from: nodeLocation)
            
            if distance < 50 {
                if apiImage.data == Data() {
                    ImageAPI.getImageById(userID: UIDevice.current.identifierForVendor!.uuidString, imageId: apiImage.id) { (response, error) in
                        guard error == nil else {
                            print(error ?? "Unknown Error")
                            return
                        }
                        
                        if (response != nil) {
                            let index = imageData.capVisImages.firstIndex(where: {$0.id == apiImage.id})!
                            imageData.capVisImages[index].data = response!.data
                            createImageNode(image: imageData.capVisImages[index], location: nodeLocation)
                            dump(response)
                        }
                    }
                } else {
                    createImageNode(image: apiImage, location: nodeLocation)
                }
            }
        }
    }
    
    func createImageNode(image: ApiImage, location: CLLocation) {
        
        let imageUI = UIImage(data: image.data, scale: CGFloat(1.0))!
        var width: CGFloat = 0
        var height: CGFloat = 0
        let finalYaw = image.yaw - 90.0
        if image.pitch != -1.0 && image.pitch != 1.0 {
            width = imageUI.size.height
            height = imageUI.size.width
        } else {
            width = imageUI.size.width
            height = imageUI.size.height
        }
        
        let scnPlane = SCNPlane(width: width*0.0008, height: height*0.0008)
        let imageNode = SCNNode(geometry: scnPlane)
        imageNode.geometry?.firstMaterial?.diffuse.contents = imageUI
        imageNode.geometry?.firstMaterial?.isDoubleSided = true
        
        imageNode.worldPosition = translateNode(location)

        let currentOrientation = GLKQuaternionMake(imageNode.orientation.x, imageNode.orientation.y, imageNode.orientation.z, imageNode.orientation.w)
        let bearingRotation = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(-Float(image.bearing)), 0, 1, 0)
        let yawRotation = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(finalYaw), 0, 0, 1)
        let finalOrientation = GLKQuaternionMultiply(GLKQuaternionMultiply(currentOrientation, bearingRotation), yawRotation)
        imageNode.orientation = SCNQuaternion(finalOrientation.x, finalOrientation.y, finalOrientation.z, finalOrientation.w)
         
        arDelegate.placeImage(imageNode: imageNode)
    }
    
    func translateNode (_ location: CLLocation) -> SCNVector3 {
        let locationTransform = GeometryUtils.transformMatrix(matrix_identity_float4x4, locationManagerModel.location, location)
        return SCNVector3Make(locationTransform.columns.3.x, locationTransform.columns.3.y, locationTransform.columns.3.z)
    }
}

struct ARViewRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        ARViewRepresentable(arDelegate: ARDelegate(), redrawImages: .constant(false))
    }
}

extension simd_quatf {
    init(_ cmq: CMQuaternion) {
        self.init(ix: Float(cmq.x), iy: Float(cmq.y), iz: Float(cmq.z), r: Float(cmq.w))
    }
}
