//
//  CalendarManager.swift
//  Film-in
//
//  Created by Minjae Kim on 11/5/24.
//

import Foundation

struct Day: Hashable, Identifiable {
    let id = UUID()
    let _date: Date
    let isData: Bool
    
    var date: Date {
        if let date = Calendar.current.date(byAdding: .day, value: -1, to: _date) {
            return date
        }
        return _date
    }
    
    init(date: Date, isData: Bool) {
        self._date = date
        self.isData = isData
    }
}

protocol CalendarManager {
    func generateDays(for date: Date) -> [Date]
    func changeMonth(by value: Int, for currentDate: Date) -> Date
    func changeYearMonth(by value: (year: Int, month: Int), for currentDate: Date) -> Date
    func selectDay(_ date: Date) -> Date?
    func generateLocalizedYears(from pastYear: Int, to futureYear: Int) async -> [Int: String]
    func generateLocalizedMonths() -> [Int: String]
}

final class DefaultCalendarManager: CalendarManager {
    private var currentDate = Date()
    
    func generateDays(for date: Date) -> [Date] {
        var days = [Date]()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let firstOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth)
        else { return [] }
        
        let firstWeekDay = calendar.component(.weekday, from: firstOfMonth)
        
        let leadingEmptyDays = (firstWeekDay + 6) % 7 // 일 월 화 수 목 금 토
        
        for _ in 0..<leadingEmptyDays {
            days.append(Date.distantPast)
        }
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        let trailingEmptyDays = 7 - (days.count % 7)
        
        if trailingEmptyDays < 7 {
            for _ in 0..<trailingEmptyDays {
                days.append(Date.distantFuture)
            }
        }
        
        return days
    }
    
    func changeMonth(by value: Int, for currentDate: Date) -> Date {
        guard let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) else {
            return currentDate
        }
        return newDate
    }
    
    func changeYearMonth(by value: (year: Int, month: Int), for currentDate: Date) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = value.year
        dateComponents.month = value.month
        dateComponents.day = 1
        
        return Calendar.current.date(from: dateComponents) ?? currentDate
    }
    
    func selectDay(_ date: Date) -> Date? {
        if date != Date.distantPast && date != Date.distantFuture {
            return date
        }
        return nil
    }
    
    func generateLocalizedYears(from pastYear: Int, to futureYear: Int) async -> [Int : String] {
        var yearSuffix = ""
        
        if let preferredLanguage = Locale.preferredLanguages.first {
            if preferredLanguage.hasPrefix("ko") {
                yearSuffix = "년"
            } else if preferredLanguage.hasPrefix("ja") {
                yearSuffix = "年"
            } else {
                yearSuffix = ""
            }
        } else {
            yearSuffix = ""
        }
        
        return Dictionary(uniqueKeysWithValues: (pastYear...futureYear).map { ($0, "\($0)" + yearSuffix) })
    }
    
    func generateLocalizedMonths() -> [Int: String] {
        let dateFormatter = Date.dateFormatter
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMM"
        
        return Dictionary(uniqueKeysWithValues: (1...12).map { month in
            let dateComponents = DateComponents(calendar: Calendar.current, month: month)
            let date = Calendar.current.date(from: dateComponents) ?? Date()
            return (month, dateFormatter.string(from: date)) // 언어별 월 형식 반환
        })
    }
}
