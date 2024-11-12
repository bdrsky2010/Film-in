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
        
        let days = calendarManager.generateDays(for: Date())
        
        let result = days.map {
            let calendar = Calendar.current
            guard let date = calendar.date(byAdding: .day, value: -1, to: $0) else {
                return Day(date: $0, isData: false)
            }
            let isData = binarySearchMovie(user.wantMovies, date) || binarySearchMovie(user.watchedMovies, date)
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

private extension Date {
    private var yearMonthDay: DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.year, .month, .day], from: self)
    }
    
    static func < (lhs: Date, rhs: Date) -> Bool {
        let left = lhs.yearMonthDay
        let right = rhs.yearMonthDay
        
        if let lYear = left.year,
           let lMonth = left.month,
           let lDay = left.day,
           let rYear = right.year,
           let rMonth = right.month,
           let rDay = right.day {
            
            if lYear != rYear {
                return lYear < rYear
            }
            if lMonth != rMonth {
                return lMonth < rMonth
            }
            return lDay < rDay
        }
        return false
    }
    
    static func == (lhs: Date, rhs: Date) -> Bool {
        let left = lhs.yearMonthDay
        let right = rhs.yearMonthDay
        
        return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day
    }
    
    static func > (lhs: Date, rhs: Date) -> Bool {
        let left = lhs.yearMonthDay
        let right = rhs.yearMonthDay
        
        if let lYear = left.year,
           let lMonth = left.month,
           let lDay = left.day,
           let rYear = right.year,
           let rMonth = right.month,
           let rDay = right.day {
            
            if lYear != rYear {
                return lYear > rYear
            }
            if lMonth != rMonth {
                return lMonth > rMonth
            }
            return lDay > rDay
            
        }
        return false
    }
}
