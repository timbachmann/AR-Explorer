//
//  ImageData.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 10.02.22.
//

import Foundation
import Combine
import OpenAPIClient

final class ImageData: ObservableObject {
    @Published var capVisImages: [ApiImage] = load()
}

func load() -> [ApiImage] {
    let data: Data
    let path = getCacheDirectoryPath().appendingPathComponent("imageData.json")
    
    do {
        data = try Data(contentsOf: path)
    } catch {
        return []
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode([ApiImage].self, from: data)
    } catch {
        fatalError("Couldn't parse \(path.path) as \([ApiImage].self):\n\(error)")
    }
}

func getCacheDirectoryPath() -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
}
