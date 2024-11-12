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
    func selectDay(_ date: Date) -> Date?
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
    
    func selectDay(_ date: Date) -> Date? {
        if date != Date.distantPast && date != Date.distantFuture {
            return date
        }
        return nil
    }
}
