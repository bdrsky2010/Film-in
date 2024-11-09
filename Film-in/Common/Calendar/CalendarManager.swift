//
//  CalendarManager.swift
//  Film-in
//
//  Created by Minjae Kim on 11/5/24.
//

import Foundation

struct Day {
    let date: Date
    var isData: Bool
    
    init(date: Date, isData: Bool = false) {
        self.date = date
        self.isData = isData
    }
}

protocol CalendarManager {
    func generateDays(for date: Date) -> [Date]
    func changeMonth(by value: Int, for currentDate: Date) -> Date?
    func selectDay(_ date: Date) -> Date?
}

final class DefaultCalendarManager: CalendarManager {
    private var currentDate = Date()
    
    func generateDays(for date: Date) -> [Date] {
        let calendar = Calendar.current
        
        // 해당 날짜의 year와 month만 추출
        guard let monthRange = calendar.range(of: .day, in: .month, for: date),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }
        
        // monthRange 범위로 날짜 배열 생성
        return monthRange.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    func changeMonth(by value: Int, for currentDate: Date) -> Date? {
        guard let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) else {
            return nil
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
