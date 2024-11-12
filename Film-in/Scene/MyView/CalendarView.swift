//
//  CalendarView.swift
//  Film-in
//
//  Created by Minjae Kim on 11/5/24.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: MyViewModel
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekDays = Calendar.current.shortWeekdaySymbols
    
    var body: some View {
        VStack {
            HStack {
                Text(currentMonthYear)
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(viewModel.output.selectMonthDays, id: \.id) { value in
                    DayView(
                        select: viewModel.output.selectDate,
                        currentMonth: viewModel.output.currentMonth,
                        value: value
                    )
                    .onTapGesture {
                        viewModel.action(.selectDay(day: value.date))
                    }
                }
            }
        }
    }
    
    var currentMonthYear: String {
        let formatter = Date.dateFormatter
        
        if let preferredLanguage = Locale.preferredLanguages.first {
            if preferredLanguage.hasPrefix("ko") {
                formatter.dateFormat = "yyyy년 MMM"
            } else if preferredLanguage.hasPrefix("ja") {
                formatter.dateFormat = "yyyy年 MMM"
            } else {
                formatter.dateFormat = "MMM yyyy"
            }
        } else {
            formatter.dateFormat = "MMM yyyy"
        }
        return formatter.string(from: viewModel.output.currentMonth)
    }
}

struct DayView: View {
    let select: Date
    let currentMonth: Date
    let value: Day
        
    var body: some View {
        let calendar = Calendar.current
        let current = calendar.dateComponents([.year, .month], from: currentMonth)
        let date = calendar.dateComponents([.year, .month, .day], from: value.date)
        let selectDate = calendar.dateComponents([.year, .month, .day], from: select)
        let isSelect = date.year == selectDate.year && date.month == selectDate.month && date.day == selectDate.day
        
        if current.year == date.year && current.month == date.month {
            ZStack(alignment: .bottom) {
                if isSelect {
                    GeometryReader { proxy in
                        Rectangle()
                            .frame(height: proxy.size.width)
                            .foregroundStyle(.app)
                    }
                }
                
                Text("\(date.day ?? 0)")
                    .font(.headline)
                    .padding(.vertical, 8)
                if value.isData {
                    Circle()
                        .frame(width: 5, height: 5)
                }
            }
            .foregroundStyle(isSelect ? .appLightGray : .appText)
            
        } else {
            Text("")
                .font(.headline)
                .padding(.vertical, 8)
        }
    }
}

#Preview {
    MyView(
        viewModel: MyViewModel(
            myViewService: DefaultMyViewService(
                databaseRepository: RealmRepository.shared,
                localNotificationManager: DefaultLocalNotificationManager.shared,
                calendarManager: DefaultCalendarManager()
            )
        )
    )
}
