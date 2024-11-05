//
//  CalendarManager.swift
//  Film-in
//
//  Created by Minjae Kim on 11/5/24.
//

import Foundation

protocol CalendarManager {
    func generateDays()
}

final class DefaultCalendarManager: CalendarManager {
    func generateDays() {
        var days = [Date]()
    }
}
