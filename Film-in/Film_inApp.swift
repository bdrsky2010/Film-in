//
//  Film_inApp.swift
//  Film-in
//
//  Created by Minjae Kim on 9/19/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

@main
struct Film_inApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("onboarding") private var isOnboarding = false
    @State private var isLaunch = false
    
    var body: some Scene {
        WindowGroup {
            if isOnboarding {
                if !isLaunch {
                    LaunchScreenView(isWave: $isLaunch)
                } else {
                    MainTabView()
                }
            } else {
                GenreSelectFactory.makeView()
            }
//            CustomPagingView()
        }
    }
}
