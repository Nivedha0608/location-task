//
//  AppDelegate.swift
//  UpdatedNewProject
//
//  Created by Nivedha Moorthy on 01/07/24.
//

import UIKit
import RealmSwift
import CoreLocation
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                
                    migration.enumerateObjects(ofType: LocationModel.className()) { oldObject, newObject in
                        newObject?["userId"] = ""
                    }
                }
            })
        Realm.Configuration.defaultConfiguration = config

      
       
        GMSServices.provideAPIKey("AIzaSyCX-Isgizqa9JgdvzF-CJsHD-XLmW87S6U")
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        LocationManager.shared.fetchAndSaveLocation()
        completionHandler(.newData)
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

