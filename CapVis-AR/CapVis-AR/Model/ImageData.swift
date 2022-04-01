//
//  ImageData.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 10.02.22.
//

import Foundation
import Combine
import OpenAPIClient

class ImageData: ObservableObject {
    @Published var capVisImages: [ApiImage] = []
    @Published var imagesToUpload: [ApiImage] = []
    @Published var localFilesSynced: Bool = true
    private static var instance: ImageData? = nil
    
    init() {
        ImageData.instance = self
        loadAllImages { (data, error) in
            if let retrievedData = data {
                self.capVisImages = retrievedData
            }
        }
        
        loadLocalImages { (data, error) in
            if let retrievedData = data {
                self.imagesToUpload = retrievedData
                self.localFilesSynced = self.imagesToUpload.isEmpty
            }
        }
    }
    
    class func getInstance() -> ImageData? {
        return instance
    }
    
    func loadAllImages(completion: @escaping (_ data: [ApiImage]?, _ error: String?) -> ())  {
        var images: [ApiImage]?
        var receivedError: String?
        
        DispatchQueue.global(qos: .background).async{
            let data: Data
            let path = self.getCacheDirectoryPath().appendingPathComponent("imageData.json")
            
            do {
                data = try Data(contentsOf: path)
            } catch {
                return
            }
            
            do {
                let decoder = JSONDecoder()
                images = try decoder.decode([ApiImage].self, from: data)
            } catch {
                receivedError = "Couldn't parse \(path.path) as \([ApiImage].self):\n\(error)"
            }
            
            DispatchQueue.main.async {
                completion(images, receivedError)
            }
        }
    }
    
    func loadLocalImages(completion: @escaping (_ data: [ApiImage]?, _ error: String?) -> ())  {
        var images: [ApiImage]?
        var receivedError: String?
        
        DispatchQueue.global(qos: .background).async{
            let data: Data
            let path = self.getCacheDirectoryPath().appendingPathComponent("newImages.json")
            
            do {
                data = try Data(contentsOf: path)
            } catch {
                return
            }
            
            do {
                let decoder = JSONDecoder()
                images = try decoder.decode([ApiImage].self, from: data)
            } catch {
                receivedError = "Couldn't parse \(path.path) as \([ApiImage].self):\n\(error)"
            }
            
            DispatchQueue.main.async {
                completion(images, receivedError)
            }
        }
    }
    
    func saveImagesToFile() {
        let path = getCacheDirectoryPath().appendingPathComponent("imageData.json")
        
        do {
            let jsonData = try JSONEncoder().encode(self.capVisImages)
            try jsonData.write(to: path)
        } catch {
            print("Error writing to JSON file: \(error)")
        }
        
        let pathLocal = getCacheDirectoryPath().appendingPathComponent("newImages.json")
        
        do {
            let jsonDataLocal = self.imagesToUpload.isEmpty ? Data() : try JSONEncoder().encode(self.imagesToUpload)
            try jsonDataLocal.write(to: pathLocal)
        } catch {
            print("Error writing to JSON file: \(error)")
        }
        dump(imagesToUpload)
        self.localFilesSynced = self.imagesToUpload.isEmpty
    }
    
    func getCacheDirectoryPath() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
}
