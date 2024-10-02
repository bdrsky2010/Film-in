//
//  LocalNotificationManager.swift
//  Film-in
//
//  Created by Minjae Kim on 10/1/24.
//

import Foundation
import UserNotifications
import UIKit

enum AuthorizationError: Error {
    case notDetermined
}

protocol LocalNotificationManager: AnyObject {
    func requestPermission() async throws
    func schedule(movie: (id: Int, title: String), date: Date) async throws
    func removeNotification(movieId: Int) async throws
    func moveToSettings()
}

final class DefaultLocalNotificationManager {
    static let shared = DefaultLocalNotificationManager()
    
    private let center: UNUserNotificationCenter
    
    private init(
        center: UNUserNotificationCenter = UNUserNotificationCenter.current()
    ) {
        self.center = center
    }
}

extension DefaultLocalNotificationManager: LocalNotificationManager {
    func requestPermission() async throws {
        try await center.requestAuthorization(options: [.alert, .badge, .sound])
    }
    
    func schedule(movie: (id: Int, title: String), date: Date) async throws {
        // Obtain the notification settings.
        let settings = await center.notificationSettings()
        
        // Verify the authorization status.
        guard (settings.authorizationStatus == .authorized) ||
                (settings.authorizationStatus == .provisional) else {
            throw AuthorizationError.notDetermined
        }
        
        // 알림 내용
        let content = UNMutableNotificationContent()
        content.title = "notificationMessage".localized
        content.subtitle = movie.title
        content.userInfo = ["id": movie.id]
        
        // 알림 조건
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // 알림 설정
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
    
        // 알림 예약
        try await center.add(request)
        print(await center.pendingNotificationRequests())
    }
    
    func removeNotification(movieId: Int) async {
        let pendingNotificationRequests = await center.pendingNotificationRequests()
        let identifiers = pendingNotificationRequests.filter {
            guard let id = $0.content.userInfo["id"] as? Int else { return false }
            return id == movieId
        }.map {
            $0.identifier
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        print(await center.pendingNotificationRequests())
    }
    
    func moveToSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:]) { success in
                if success {
                    print("Opened settings.")
                } else {
                    print("Failed to open settings.")
                }
            }
        }
    }
}
