//
//  ARDelegate.swift
//  CapVis
//
//  Created by Tim Bachmann on 28.01.22.
//

import Foundation
import ARKit
import UIKit

class ARDelegate: NSObject, ARSCNViewDelegate, ObservableObject {
    @Published var message:String = "starting AR"
    
    func setARView(_ arView: ARSCNView) {
        self.arView = arView
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arView.session.run(configuration)
        
        arView.delegate = self
        arView.scene = SCNScene()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnARView))
        arView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panOnARView))
        arView.addGestureRecognizer(panGesture)
    }
    
    @objc func panOnARView(sender: UIPanGestureRecognizer) {
        guard let arView = arView else { return }
        let location = sender.location(in: arView)
        switch sender.state {
        case .began:
            if let node = nodeAtLocation(location) {
                trackedNode = node
            }
        case .changed:
            if let node = trackedNode {
                if let result = raycastResult(fromLocation: location) {
                    moveNode(node, raycastResult:result)
                }
            }
        default:
            ()
        }
    }
    
    @objc func tapOnARView(sender: UITapGestureRecognizer) {
        //guard let arView = arView else { return }
        //let location = sender.location(in: arView)
        placeImage()
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print("camera did change \(camera.trackingState)")
        switch camera.trackingState {
        case .limited(_):
            message = "Tracking limited"
        case .normal:
            message =  "Tracking ready"
        case .notAvailable:
            message = "Tracking not available"
        }
    }
    
    // MARK: - Private
    private var arView: ARSCNView?
    private var images:[SCNNode] = []
    private var trackedNode:SCNNode?
    
    private func placeImage() {
        let imageNode = createImageNode()
        
        arView?.scene.rootNode.addChildNode(imageNode)
        images.append(imageNode)
        
        nodesUpdated()
    }
    
    private func moveNode(_ node:SCNNode, raycastResult:ARRaycastResult) {
        node.simdWorldTransform = raycastResult.worldTransform
        nodesUpdated()
    }
    
    private func nodeAtLocation(_ location:CGPoint) -> SCNNode? {
        guard let arView = arView else { return nil }
        let result = arView.hitTest(location, options: nil)
        return result.first?.node
    }
    
    private func nodesUpdated() {
        if images.count >= 1 {
            message = "AR image(s) placed"
        }
        else {
            message = "Image not placed"
        }
    }
    
    private func raycastResult(fromLocation location: CGPoint) -> ARRaycastResult? {
        guard let arView = arView,
              let query = arView.raycastQuery(from: location,
                                        allowing: .existingPlaneGeometry,
                                        alignment: .horizontal) else { return nil }
        let results = arView.session.raycast(query)
        return results.first
    }
    
    func removeImage(node:SCNNode) {
        node.removeFromParentNode()
        images.removeAll(where: { $0 == node })
    }
    
    func createImageNode() -> SCNNode {
        let image = UIImage(named: "santorini")
        let width = image?.size.width ?? 1
        let height = image?.size.height ?? 0.2
        
        let scnPlane = SCNPlane(width: width*0.0005, height: height*0.0005)
        
        let circleNode = SCNNode(geometry: scnPlane)
        circleNode.geometry?.firstMaterial?.diffuse.contents = image
        circleNode.worldPosition = SCNVector3(0,0,-2)
        // circleNode.simdWorldTransform = result.worldTransform
        
        return circleNode
    }
}
