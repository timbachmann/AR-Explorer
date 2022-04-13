//
//  AppDelegate.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 02.04.22.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.applicationIconBadgeNumber = 0
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("Test")
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("Test")
        application.applicationIconBadgeNumber = 0
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let notiName = Notification.Name("capVisAR")
        NotificationCenter.default.post(name:notiName , object: notification.request.content)
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let notiName = Notification.Name("capVisAR")
        NotificationCenter.default.post(name:notiName , object: response.notification.request.content)
        completionHandler()
    }
}
