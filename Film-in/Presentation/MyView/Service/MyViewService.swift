//
//  MyViewService.swift
//  Film-in
//
//  Created by Minjae Kim on 10/2/24.
//

import Foundation
import Combine
import RealmSwift

protocol MyViewService: AnyObject {
    func requestDeleteMovie(movieId: Int) -> AnyPublisher<Void, Never>
    func generateDays(for date: Date) -> [Day]
    func changeMonth(by value: Int, for currentDate: Date) -> Date
    func changeYearMonth(by value: (year: Int, month: Int), for currentDate: Date) -> Date
    func currentMonthYearString(for currentDate: Date) -> String
    func generateLocalizedYears(from pastYear: Int, to futureYear: Int) -> AnyPublisher<[Int: String], Never>
    func generateLocalizedMonths() -> [Int: String]
    func judgedIsEnglish() -> Bool
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
    func requestDeleteMovie(movieId: Int) -> AnyPublisher<Void, Never> {
        databaseRepository.deleteMovie(movieId: movieId)
        
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                await removePendingNotification(movieId: movieId)
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func removePendingNotification(movieId: Int) async {
        do {
            try await localNotificationManager.removeNotification(movieId: movieId)
        } catch {
            print(error)
        }
    }
    
    func generateDays(for date: Date) -> [Day] {
        guard let user = databaseRepository.user else { return [] }
        
        let days = calendarManager.generateDays(for: date)
        
        let result = days.map {
            guard let date = Calendar.current.date(byAdding: .day, value: -1, to: $0) else {
                return Day(date: $0, isData: false)
            }
            let isData = binarySearchMovie(in: user.wantMovies, target: date) || binarySearchMovie(in: user.watchedMovies, target: date)
            return Day(date: $0, isData: isData)
        }
        
        return result
    }
    
    func changeMonth(by value: Int, for currentDate: Date) -> Date {
        return calendarManager.changeMonth(by: value, for: currentDate)
    }
    
    func changeYearMonth(by value: (year: Int, month: Int), for currentDate: Date) -> Date {
        return calendarManager.changeYearMonth(by: value, for: currentDate)
    }
    
    private func binarySearchMovie(in list: List<MovieTable>, target: Date) -> Bool {
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
    
    func currentMonthYearString(for currentDate: Date) -> String {
        return calendarManager.currentMonthYearString(for: currentDate)
    }
    
    func generateLocalizedYears(from pastYear: Int, to futureYear: Int) -> AnyPublisher<[Int : String], Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let localizedYears = await calendarManager.generateLocalizedYears(from: pastYear, to: futureYear)
                promise(.success(localizedYears))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func generateLocalizedMonths() -> [Int: String] {
        return calendarManager.generateLocalizedMonths()
    }
    
    func judgedIsEnglish() -> Bool {
        guard let preferredLanguage = Locale.preferredLanguages.first else { return true }
        return preferredLanguage.hasPrefix("en")
    }
}

extension Date {
    fileprivate var yearMonthDay: DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.year, .month, .day], from: self)
    }
    
    fileprivate static func < (lhs: Date, rhs: Date) -> Bool {
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
    
    fileprivate static func == (lhs: Date, rhs: Date) -> Bool {
        return Calendar.current.isDate(lhs, inSameDayAs: rhs)
    }
    
    fileprivate static func > (lhs: Date, rhs: Date) -> Bool {
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
