//
//  MyViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 10/2/24.
//

import Foundation
import Combine

final class MyViewModel: BaseObject, ViewModelType {
    private let myViewService: MyViewService
    
    @Published var output = Output()
    
    var input = Input()
    var cancellable = Set<AnyCancellable>()
    
    init(
        myViewService: MyViewService
    ) {
        self.myViewService = myViewService
        super.init()
        transform()
    }
}

extension MyViewModel {
    struct Input {
        var generateDays = PassthroughSubject<Void, Never>()
        var selectDay = PassthroughSubject<Date, Never>()
        var changeMonth = PassthroughSubject<Int, Never>()
        var changeYearMonth = PassthroughSubject<(year: Int, month: Int), Never>()
        var disappearPicker = PassthroughSubject<Void, Never>()
        var deleteGesture = PassthroughSubject<Int, Never>()
        var realDeleteMovie = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        var isRequestDelete = false
        var deleteMovieId = 0
        var currentYearMonth = Date()
        var currentYearMonthString = ""
        var selectDate = Date()
        var selectMonthDays = [Day]()
        
        var isPickerPresent = false
    }
    
    func transform() {
        input.generateDays
            .sink { [weak self] _ in
                guard let self else { return }
                output.currentYearMonthString = myViewService.currentMonthYearString(for: output.currentYearMonth) // 설정된 날짜의 년, 월 문자열로 생성
                
                let days = myViewService.generateDays(for: output.currentYearMonth) // 설정된 달에 대한 날짜 생성
                output.selectMonthDays = days
            }
            .store(in: &cancellable)
        
        input.selectDay
            .sink { [weak self] value in
                guard let self else { return }
                output.selectDate = value
            }
            .store(in: &cancellable)
        
        input.changeMonth
            .sink { [weak self] value in
                guard let self else { return }
                let date = myViewService.changeMonth(by: value, for: output.currentYearMonth)
                output.currentYearMonth = date
                
                output.currentYearMonthString = myViewService.currentMonthYearString(for: date)
                
                let days = myViewService.generateDays(for: output.currentYearMonth)
                output.selectMonthDays = days
            }
            .store(in: &cancellable)
        
        input.isPickerPresentToggle
            .sink { [weak self] _ in
                guard let self else { return }
                output.isPickerPresent.toggle()
            }
            .store(in: &cancellable)
        
        input.changeYearMonth
            .sink { [weak self] value in
                guard let self else { return }
                let date = myViewService.changeYearMonth(by: value, for: output.currentYearMonth)
                output.currentYearMonth = date
                
                output.currentYearMonthString = myViewService.currentMonthYearString(for: date)
            }
            .store(in: &cancellable)
        
        input.disappearPicker
            .sink { [weak self] _ in
                guard let self else { return }
                let days = myViewService.generateDays(for: output.currentYearMonth)
                output.selectMonthDays = days
            }
            .store(in: &cancellable)
        
        input.deleteGesture
            .sink { [weak self] movieId in
                guard let self else { return }
                output.isRequestDelete = true
                output.deleteMovieId = movieId
            }
            .store(in: &cancellable)
        
        input.realDeleteMovie
            .sink { [weak self] movieId in
                guard let self else { return }
                myViewService.requestDeleteMovie(movieId: movieId) // 저장된 영화 삭제
                
                let days = myViewService.generateDays(for: output.currentYearMonth)
                output.selectMonthDays = days // 날짜 데이터 reload
            }
            .store(in: &cancellable)
    }
}

extension MyViewModel {
    enum Action {
        case viewOnTask
        case selectDay(day: Date)
        case changeMonth(value: Int)
        
        case pickerButtonTap
        case changeYearMonth(year: Int, month: Int)
        case disappearPicker
        case deleteGesture(movieId: Int)
        case realDelete(movieId: Int)
    }
    
    func action(_ action: Action) {
        switch action {
        case .viewOnTask:
            input.generateDays.send(())
        case .selectDay(let day):
            input.selectDay.send(day)
        case .changeMonth(let value):
            input.changeMonth.send(value)
            
        case .pickerButtonTap:
            input.isPickerPresentToggle.send(())
        case .changeYearMonth(let year, let month):
            input.changeYearMonth.send((year, month))
        case .disappearPicker:
            input.disappearPicker.send(())
            
        case .deleteGesture(let movieId):
            input.deleteGesture.send(movieId)
        case .realDelete(let movieId):
            input.realDeleteMovie.send(movieId)
        }
    }
}
