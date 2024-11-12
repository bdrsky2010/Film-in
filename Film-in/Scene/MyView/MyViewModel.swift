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
        var deleteGesture = PassthroughSubject<Int, Never>()
        var realDeleteMovie = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        var isRequestDelete = false
        var deleteMovieId = 0
        var currentMonth = Date()
        var currentMonthYearString = ""
        var selectDate = Date()
        var selectMonthDays = [Day]()
    }
    
    func transform() {
        input.generateDays
            .sink { [weak self] _ in
                guard let self else { return }
                output.currentMonthYearString = myViewService.currentMonthYearString(for: output.currentMonth) // 설정된 날짜의 년, 월 문자열로 생성
                
                let days = myViewService.generateDays(for: output.currentMonth) // 설정된 달에 대한 날짜 생성
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
                let date = myViewService.changeMonth(by: value, for: output.currentMonth)
                output.currentMonth = date
                
                output.currentMonthYearString = myViewService.currentMonthYearString(for: date)
                
                let days = myViewService.generateDays(for: output.currentMonth)
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
                myViewService.requestDeleteMovie(movieId: movieId)
            }
            .store(in: &cancellable)
    }
}

extension MyViewModel {
    enum Action {
        case viewOnTask
        case selectDay(day: Date)
        case changeMonth(value: Int)
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
        case .deleteGesture(let movieId):
            input.deleteGesture.send(movieId)
        case .realDelete(let movieId):
            input.realDeleteMovie.send(movieId)
        }
    }
}

extension DateSetupViewModel {
    
}

