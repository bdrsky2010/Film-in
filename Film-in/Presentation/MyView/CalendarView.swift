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
    private let pastYear = Calendar.current.component(.year, from: Date()) - 100
    private let futureYear = Calendar.current.component(.year, from: Date()) + 100
    
    var body: some View {
        VStack {
            calendarHeader()
            ZStack {
                calendarSection()
                if viewModel.output.isPickerPresent {
                    calendarPicker()
                }
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
                    .rotationEffect(.degrees(viewModel.output.isPickerPresent ? 90 : 0))
            }
            .foregroundStyle(viewModel.output.isPickerPresent ? .app : .primary)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.action(.pickerButtonTap)
                }
                
                if !viewModel.output.isPickerPresent {
                    viewModel.action(.disappearPicker)
                }
            }
            
            Spacer()
            
            if !viewModel.output.isPickerPresent {
                HStack(spacing: 20) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.action(.changeMonth(value: -1))
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.action(.changeMonth(value: 1))
                        }
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
                    Text(verbatim: "\(day)")
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
            if viewModel.output.isEnglish {
                Picker("", selection: $viewModel.output.selectMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(verbatim: viewModel.output.localizedMonths[month] ?? "").tag(month)
                    }
                }
                .pickerStyle(.wheel)
                
                Picker("", selection: $viewModel.output.selectYear) {
                    ForEach(pastYear...futureYear, id: \.self) { year in
                        Text(verbatim: viewModel.output.localizedYears[year] ?? "").tag(year)
                    }
                }
                .pickerStyle(.wheel)
                
            } else {
                Picker("", selection: $viewModel.output.selectYear) {
                    ForEach(pastYear...futureYear, id: \.self) { year in
                        Text(verbatim: viewModel.output.localizedYears[year] ?? "").tag(year)
                    }
                }
                .pickerStyle(.wheel)
                
                Picker("", selection: $viewModel.output.selectMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(verbatim: viewModel.output.localizedMonths[month] ?? "").tag(month)
                    }
                }
                .pickerStyle(.wheel)
            }
        }
        .frame(maxHeight: .infinity)
        .background(.background)
        .valueChanged(value: viewModel.output.selectYear) { _ in
            let selectYear = viewModel.output.selectYear
            let selectMonth = viewModel.output.selectMonth
            viewModel.action(.changeYearMonth(year: selectYear, month: selectMonth))
        }
        .valueChanged(value: viewModel.output.selectMonth) { _ in
            let selectYear = viewModel.output.selectYear
            let selectMonth = viewModel.output.selectMonth
            viewModel.action(.changeYearMonth(year: selectYear, month: selectMonth))
        }
        .task {
            viewModel.action(.pickerOnTask(past: pastYear, future: futureYear))
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
                
                Text(verbatim: "\(date.day ?? 0)")
                    .font(.ibmPlexMonoMedium(size: 17))
                    .padding(.vertical, 8)
                if value.isData {
                    Circle()
                        .frame(width: 5, height: 5)
                }
            }
            .foregroundStyle(isSelect ? .white : .appText)
            
        } else {
            Text(verbatim: "")
                .font(.headline)
                .padding(.vertical, 8)
        }
    }
}
