//
//  AppDelegate.swift
//  Assignment
//
//  Created by Muhammad Irfan Tarar.
//

import UIKit
import AVKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        return true
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

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
            // Handle the URL here
            handleIncomingURL(url)
            return true
        }
        return false
    }

    func handleIncomingURL(_ url: URL) {
        let urlString = url.absoluteString
        print("Received URL: \(urlString)")
        
        // Here, you can parse the URL to extract any parameters or information you need
        // For example, if your URL is in the format "https://example.com/download?referrer=user123",
        // you can extract the referrer information.
        
        // Example parsing logic:
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for item in queryItems {
                if item.name == "referrer" {
                    if let referrer = item.value {
                        print("Referrer: \(referrer)")
                        // Now you have the referrer information, you can store/process it as needed
                        // For example, save it to UserDefaults or send it to your server.
                    }
                }
            }
        }
    }

}

