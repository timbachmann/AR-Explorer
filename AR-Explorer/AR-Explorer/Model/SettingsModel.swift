//
//  SettingsModel.swift
//  AR-Explorer
//
//  Created by Tim Bachmann on 21.04.22.
//

import Foundation
import Combine
import OpenAPIClient

/**
 
 */
class SettingsModel: ObservableObject {
    @Published var serverAddress: String = OpenAPIClientAPI.basePath
    
    /**
     
     */
    init() {
        loadSettings { (data, error) in
            if let retrievedData = data {
                self.serverAddress = retrievedData.serverAddress
            }
        }
    }
    
    /**
     
     */
    func loadSettings(completion: @escaping (_ data: Settings?, _ error: String?) -> ())  {
        var settings: Settings? = nil
        var receivedError: String?
        
        DispatchQueue.global(qos: .background).async {
            let cachePath = getCacheDirectoryPath().appendingPathComponent("settings.json")
            do {
                let rawSettings = try Data(contentsOf: cachePath)
                let decoder = JSONDecoder()
                settings = try decoder.decode(Settings.self, from: rawSettings)
            } catch {
                receivedError = "Couldn't load settings!"
            }
            
            DispatchQueue.main.async {
                completion(settings, receivedError)
            }
        }
    }
    
    
    /**
    
     */
    func saveSettingsToFile() {
        let path = getCacheDirectoryPath().appendingPathComponent("settings.json")
        do {
            try FileManager.default.removeItem(atPath: path.path)
        } catch let error as NSError {
            print("Unable to delete old Settings \(error.debugDescription)")
        }
        
        let settings = Settings(serverAddress: serverAddress)
        do {
            let jsonDataLocal = try JSONEncoder().encode(settings)
            try jsonDataLocal.write(to: path)
        } catch {
            print("Error writing settings file: \(error)")
        }
    }
}

/**
 Returns cache directory
 */
func getCacheDirectoryPath() -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
}
