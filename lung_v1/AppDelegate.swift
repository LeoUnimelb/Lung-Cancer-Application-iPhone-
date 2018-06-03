
//  AppDelegate.swift
//  Created by XILE on 1/5/18.
//  Copyright © 2018 XILE. All rights reserved.
//  This .swfit is used to do configurations after the application is launched


import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    //set navigationBar's appearance
    UINavigationBar.appearance().tintColor = .white
    UINavigationBar.appearance().barTintColor = .black
    //create new a new LocationManager object and request for authorize before location service is in usage
    let locationManager = LocationManager.shared
    locationManager.requestWhenInUseAuthorization()
    //add Firebase configuartion
    FirebaseApp.configure()
    //add notcification
    UNUserNotificationCenter.current().delegate = self
    return true
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
  }
  
}

extension AppDelegate: UNUserNotificationCenterDelegate{
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler(.alert)
  }
  
}
