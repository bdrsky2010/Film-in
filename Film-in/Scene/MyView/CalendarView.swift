//
//  CalendarView.swift
//  Film-in
//
//  Created by Minjae Kim on 11/5/24.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: MyViewModel
    
    @State private var isPickerPresented = false
    @State private var selectYear = 1
    @State private var selectMonth = 1
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekDays = Calendar.current.shortWeekdaySymbols
    private let pastYear = Calendar.current.component(.year, from: Date()) - 100
    private let futureYear = Calendar.current.component(.year, from: Date()) + 100
    
    var body: some View {
        VStack {
            calendarHeader()
            ZStack {
                calendarSection()
                if isPickerPresented { calendarPicker() }
            }
        }
    }
    
    @ViewBuilder
    private func calendarHeader() -> some View {
        HStack {
            HStack(spacing: 4) {
                Text(viewModel.output.currentYearMonthString)
                    .font(.ibmPlexMonoSemiBold(size: 17))
                
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
                viewModel.action(.disappearPicker)
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
                        .font(.ibmPlexMonoMedium(size: 17))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(viewModel.output.selectMonthDays, id: \.id) { value in
                    DayView(
                        select: viewModel.output.selectDate,
                        currentMonth: viewModel.output.currentYearMonth,
                        value: value
                    )
                    .onTapGesture {
                        viewModel.action(.selectDay(day: value.date))
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func calendarPicker() -> some View {
        HStack {
            if isEnglish {
                Picker("", selection: $selectMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(localizedMonths[month - 1]).tag(month)
                    }
                }
                .pickerStyle(.wheel)
                
                Picker("", selection: $selectYear) {
                    ForEach(pastYear...futureYear, id: \.self) { year in
                        Text(localizedYears[year] ?? "").tag(year)
                    }
                }
                .pickerStyle(.wheel)
                
            } else {
                Picker("", selection: $selectYear) {
                    ForEach(pastYear...futureYear, id: \.self) { year in
                        Text(localizedYears[year] ?? "").tag(year)
                    }
                }
                .pickerStyle(.wheel)
                
                Picker("", selection: $selectMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(localizedMonths[month - 1]).tag(month)
                    }
                }
                .pickerStyle(.wheel)
            }
        }
        .frame(maxHeight: .infinity)
        .background(.background)
        .valueChanged(value: selectYear) { _ in
            viewModel.action(.changeYearMonth(year: selectYear, month: selectMonth))
        }
        .valueChanged(value: selectMonth) { _ in
            viewModel.action(.changeYearMonth(year: selectYear, month: selectMonth))
        }
        .task {
            let currentDate = viewModel.output.currentYearMonth
            let currentYearMonth = Calendar.current.dateComponents([.year, .month], from: currentDate)
            
            if let year = currentYearMonth.year,
               let month = currentYearMonth.month {
               
                selectYear = year
                selectMonth = month
            }
        }
    }
    
    private var isEnglish: Bool {
        if let preferredLanguage = Locale.preferredLanguages.first {
            return preferredLanguage.hasPrefix("en")
        }
        return true
    }
    
    private var localizedYears: [Int: String] {
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
    
    private var localizedMonths: [String] {

        let dateFormatter = Date.dateFormatter
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMM"
        
        return (1...12).map { month in
            let dateComponents = DateComponents(calendar: Calendar.current, month: month)
            let date = Calendar.current.date(from: dateComponents) ?? Date()
            return dateFormatter.string(from: date) // 언어별 월 형식 반환
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
                    .font(.ibmPlexMonoMedium(size: 17))
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
