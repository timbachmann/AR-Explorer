//
//  AppDelegate.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 02.04.22.
//

import Foundation
import UIKit

/**
 AppDelegate to manage notifications
 */
class AppDelegate: NSObject, UIApplicationDelegate {
    
    /**
     Sets notification center delegate after launch
     */
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    /**
     Resets icon badge after launch
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.applicationIconBadgeNumber = 0
        return true
    }
    
    /**
     Resets icon badge when app becomes active
     */
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    /**
     Resets icon badge when app will enter foreground
     */
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /**
     Receive notification when application is in foreground
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let notiName = Notification.Name("capVisAR")
        NotificationCenter.default.post(name:notiName , object: notification.request.content)
        completionHandler([.banner, .sound])
    }
    
    /**
     Receive notification when application is in background
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notiName = Notification.Name("capVisAR")
        NotificationCenter.default.post(name:notiName , object: response.notification.request.content)
        completionHandler()
    }
}
