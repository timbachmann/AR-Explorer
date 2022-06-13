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
 Observable class SettingsModel to represent current settings.
 Contains functions to save and load settings from the app's cache directory
 */
class SettingsModel: ObservableObject {
    @Published var serverAddress: String = OpenAPIClientAPI.basePath
    @Published var userThumbRight: Bool = true
    
    /**
     Initialize settings by loading from cache
     */
    init() {
        loadSettings { (data, error) in
            if let retrievedData = data {
                self.serverAddress = retrievedData.serverAddress
                self.userThumbRight = retrievedData.userThumbRight
            }
        }
    }
    
    /**
     Loads previously saved settings from cache and returns them
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
     Saves current settings to cache while invalidating old state
     */
    func saveSettingsToFile() {
        let path = getCacheDirectoryPath().appendingPathComponent("settings.json")
        do {
            try FileManager.default.removeItem(atPath: path.path)
        } catch let error as NSError {
            print("Unable to delete old Settings \(error.debugDescription)")
        }
        
        let settings = Settings(serverAddress: serverAddress,  userThumbRight: userThumbRight)
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
