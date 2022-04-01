//
//  ARViewRepresentable.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 28.01.22.
//

import ARKit
import SwiftUI
import OpenAPIClient

struct ARViewRepresentable: UIViewRepresentable {
    let arDelegate:ARDelegate
    @EnvironmentObject var imageData: ImageData
    @EnvironmentObject var locationManagerModel: LocationManagerModel
    
    func makeUIView(context: Context) -> some UIView {
        let arView = ARSCNView(frame: .zero)
        arView.showsStatistics = true
        arView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        arDelegate.setARView(arView)
        loadImageNodes()
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func loadImageNodes() {
        for var apiImage in imageData.capVisImages {
            if apiImage.data == Data() {
                ImageAPI.getImageById(imageId: apiImage.id) { (response, error) in
                    guard error == nil else {
                        print(error ?? "Unknown Error")
                        return
                    }

                    if (response != nil) {
                        apiImage.data = response!.data
                        createImageNode(image: apiImage)
                        dump(response)
                    }
                }
            } else {
                createImageNode(image: apiImage)
            }
        }
    }
    
    func createImageNode(image: ApiImage) {
            let nodeLocation = CLLocation(latitude: image.lat, longitude: image.lng)
            let distance = locationManagerModel.location.distance(from: nodeLocation)
            
            if distance < 50 {
                let image = UIImage(data: image.data, scale: CGFloat(1.0))!
                let width = image.size.height
                let height = image.size.width
                
                let scnPlane = SCNPlane(width: width*0.0008, height: height*0.0008)
                
                let imageNode = SCNNode(geometry: scnPlane)
                imageNode.geometry?.firstMaterial?.diffuse.contents = image
                imageNode.geometry?.firstMaterial?.isDoubleSided = true
                imageNode.rotation = SCNVector4Make(0, 0, 1, .pi / -2)
                imageNode.worldPosition = translateNode(nodeLocation)
                
                arDelegate.placeImage(imageNode: imageNode)
            }
    }
    
    func translateNode (_ location: CLLocation) -> SCNVector3 {
        let locationTransform = GeometryUtils.transformMatrix(matrix_identity_float4x4, locationManagerModel.location, location)
        return SCNVector3Make(locationTransform.columns.3.x, locationTransform.columns.3.y, locationTransform.columns.3.z)
    }
}

struct ARViewRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        ARViewRepresentable(arDelegate: ARDelegate())
    }
}
