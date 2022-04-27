//
//  ImageData.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 10.02.22.
//

import Foundation
import Combine
import OpenAPIClient

/**
 Observable class image data to represent current images and images to upload.
 Contains functions to save and load data from the app's cache directory
 */
class ImageData: ObservableObject {
    @Published var explorerImages: [ApiImage] = []
    @Published var imagesToUpload: [ApiImage] = []
    @Published var localFilesSynced: Bool = true
    @Published var navigationImage: ApiImage? = nil
    
    /**
     Initialize images by loading from cache
     */
    init() {
        loadAllImages { (data, error) in
            if let retrievedData = data {
                self.explorerImages = retrievedData
                self.explorerImages.sort(by: { $0.date < $1.date })
            }
        }
        
        loadLocalImages { (data, error) in
            if let retrievedData = data {
                self.imagesToUpload = retrievedData
                self.localFilesSynced = self.imagesToUpload.isEmpty
            }
        }
    }
    
    /**
     Loads previously queried images from cache and returns list
     */
    func loadAllImages(completion: @escaping (_ data: [ApiImage]?, _ error: String?) -> ())  {
        var images: [ApiImage] = []
        var receivedError: String?
        
        DispatchQueue.global(qos: .background).async {
            let cachePath = self.getCacheDirectoryPath().appendingPathComponent("images")
            let fileManager: FileManager = FileManager.default
            
            
            do {
                let imageFolders: [URL] = try fileManager.contentsOfDirectory(at: cachePath, includingPropertiesForKeys: nil)
                
                for imageFolder in imageFolders {
                    var metaData: MetaData
                    let metaPath = imageFolder.appendingPathComponent("\(imageFolder.lastPathComponent).json")
                    
                    do {
                        let rawMetaData = try Data(contentsOf: metaPath)
                        let decoder = JSONDecoder()
                        metaData = try decoder.decode(MetaData.self, from: rawMetaData)
                        
                        var imageData: Data
                        let fullImagePath = imageFolder.appendingPathComponent("\(imageFolder.lastPathComponent).jpg")
                        
                        do {
                            imageData = try Data(contentsOf: fullImagePath)
                        } catch {
                            imageData = Data()
                        }
                        
                        var thumbData: Data
                        let thumbPath = imageFolder.appendingPathComponent("\(imageFolder.lastPathComponent)-thumb.jpg")
                        
                        do {
                            thumbData = try Data(contentsOf: thumbPath)
                        } catch {
                            thumbData = Data()
                        }
                        
                        images.append(ApiImage(id: metaData.id, data: imageData, thumbnail: thumbData, lat: metaData.lat, lng: metaData.lng, date: metaData.date, source: metaData.source, bearing: metaData.bearing, yaw: metaData.yaw, pitch: metaData.pitch, publicImage: metaData.publicImage))
                        
                    } catch {
                        receivedError = "Couldn't parse \(metaPath.path) as \(MetaData.self):\n\(error)"
                    }
                }
            } catch {
                receivedError = "Couldn't iterate cache directory!"
            }
            
            DispatchQueue.main.async {
                completion(images, receivedError)
            }
        }
    }
    
    /**
     Loads previously captured but not yet uploaded images from cache and returns list
     */
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
    
    /**
     Saves all images to cache while invalidating old state
     */
    func saveImagesToFile() {
        let path = getCacheDirectoryPath().appendingPathComponent("images")
        do {
            try FileManager.default.removeItem(atPath: path.path)
        } catch let error as NSError {
            print("Unable to delete directory \(error.debugDescription)")
        }
        
        for image in self.explorerImages {
            let folderPath = getCacheDirectoryPath().appendingPathComponent("images").appendingPathComponent(image.id)
            do {
                try FileManager.default.createDirectory(atPath: folderPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print("Unable to create directory \(error.debugDescription)")
            }
            let meta = MetaData(id: image.id, lat: image.lat, lng: image.lng, date: image.date, source: image.source, bearing: image.bearing, yaw: image.yaw, pitch: image.pitch, publicImage: image.publicImage)
            
            let metaPath = folderPath.appendingPathComponent("\(image.id).json")
            do {
                let jsonDataLocal = try JSONEncoder().encode(meta)
                try jsonDataLocal.write(to: metaPath)
            } catch {
                print("Error writing metadata file: \(error)")
            }
            
            if image.data != Data() {
                let imagePath = folderPath.appendingPathComponent("\(image.id).jpg")
                do {
                    try image.data.write(to: imagePath)
                } catch {
                    print("Error writing full image file: \(error)")
                }
            }
            
            if image.thumbnail != Data() {
                let thumbPath = folderPath.appendingPathComponent("\(image.id)-thumb.jpg")
                do {
                    try image.thumbnail.write(to: thumbPath)
                } catch {
                    print("Error writing thumbnail file: \(error)")
                }
            }
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
    
    /**
     Returns cache directory path
     */
    func getCacheDirectoryPath() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
}
