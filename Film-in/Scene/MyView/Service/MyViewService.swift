//
//  MyViewService.swift
//  Film-in
//
//  Created by Minjae Kim on 10/2/24.
//

import Foundation
import RealmSwift

protocol MyViewService: AnyObject {
    func requestDeleteMovie(movieId: Int)
    func generateDays() -> [Day]
}

final class DefaultMyViewService: BaseObject {
    private let databaseRepository: DatabaseRepository
    private let localNotificationManager: LocalNotificationManager
    private let calendarManager: CalendarManager
    
    init(
        databaseRepository: DatabaseRepository,
        localNotificationManager: LocalNotificationManager,
        calendarManager: CalendarManager
    ) {
        self.databaseRepository = databaseRepository
        self.localNotificationManager = localNotificationManager
        self.calendarManager = calendarManager
    }
}

extension DefaultMyViewService: MyViewService {
    func requestDeleteMovie(movieId: Int) {
        databaseRepository.deleteMovie(movieId: movieId)
        
        Task {
            await removePendingNotification(movieId: movieId)
        }
    }
    
    private func removePendingNotification(movieId: Int) async {
        do {
            try await localNotificationManager.removeNotification(movieId: movieId)
        } catch {
            print(error)
        }
    }
    
    func generateDays() -> [Day] {
        guard let user = databaseRepository.user else { return [] }
        
        let days = calendarManager.generateDays()
        
        let result = days.map {
            let isData = binarySearchMovie(user.wantMovies, $0) || binarySearchMovie(user.watchedMovies, $0)
            return Day(date: $0, isData: isData)
        }
        
        return result
    }
    
    private func binarySearchMovie(_ list: List<MovieTable>, _ target: Date) -> Bool {
        var left = 0
        var right = list.count - 1
        var mid: Int
        
        while left <= right {
            mid = (left + right) / 2

            if list[mid].date == target { return true }
            else if list[mid].date > target { right = mid - 1 }
            else { left = mid + 1 }
        }
        
        return false
    }
}
