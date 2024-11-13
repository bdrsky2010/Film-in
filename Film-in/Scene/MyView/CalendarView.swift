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
            calendarHeader()
            calendarSection()
        }
    }
    
    @ViewBuilder
    private func calendarHeader() -> some View {
        HStack {
            HStack(spacing: 4) {
                Text(viewModel.output.currentMonthYearString)
                    .font(.headline)
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.app)
                    .rotationEffect(.degrees(isPickerPresented ? 90 : 0))
            }
            .foregroundStyle(isPickerPresented ? .app : .primary)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPickerPresented.toggle()
                }
            }
            
            Spacer()
            
            if !isPickerPresented {
                HStack(spacing: 20) {
                    Button {
                        viewModel.action(.changeMonth(value: -1))
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    
                    Button {
                        viewModel.action(.changeMonth(value: 1))
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                .font(.title3)
                .bold()
                .foregroundStyle(.app)
            }
        }
    }
    
    @ViewBuilder
    private func calendarSection() -> some View {
        VStack {
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
            .foregroundStyle(isSelect ? .white : .appText)
            
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
