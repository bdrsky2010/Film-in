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
    
    private(set) var input = Input()
    private(set) var cancellable = Set<AnyCancellable>()
    
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
        
        var isPickerPresentToggle = PassthroughSubject<Void, Never>()
        var isEnglishJudge = PassthroughSubject<Void, Never>()
        var setupLocalizedYears = PassthroughSubject<(past: Int, future: Int), Never>()
        var setupLocalizedMonths = PassthroughSubject<Void, Never>()
        var setupSelectYearMonth = PassthroughSubject<Void, Never>()
        var changeYearMonth = PassthroughSubject<(year: Int, month: Int), Never>()
        var disappearPicker = PassthroughSubject<Void, Never>()
        
        var deleteGesture = PassthroughSubject<Int, Never>()
        var realDeleteMovie = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        var currentYearMonth = Date()
        var currentYearMonthString = ""
        var selectDate = Date()
        var selectMonthDays = [Day]()
        
        var isPickerPresent = false
        var isEnglish = false
        var localizedYears: [Int: String] = [:]
        var localizedMonths: [Int: String] = [:]
        var selectYear = 1
        var selectMonth = 1
        
        var isRequestDelete = false
        var deleteMovieId = 0
    }
    
    func transform() {
        input.generateDays
            .sink(with: self) { owner, _ in
                let currentYearMonthString = owner.myViewService.currentMonthYearString(for: owner.output.currentYearMonth) // 설정된 날짜의 년, 월 문자열로 생성
                owner.output.currentYearMonthString = currentYearMonthString
                
                let days = owner.myViewService.generateDays(for: owner.output.currentYearMonth) // 설정된 달에 대한 날짜 생성
                owner.output.selectMonthDays = days
            }
            .store(in: &cancellable)
        
        input.selectDay
            .sink(with: self) { owner, value in
                owner.output.selectDate = value
            }
            .store(in: &cancellable)
        
        input.changeMonth
            .sink(with: self) { owner, value in
                let date = owner.myViewService.changeMonth(by: value, for: owner.output.currentYearMonth)
                owner.output.currentYearMonth = date
                
                owner.output.currentYearMonthString = owner.myViewService.currentMonthYearString(for: date)
                
                let days = owner.myViewService.generateDays(for: owner.output.currentYearMonth)
                owner.output.selectMonthDays = days
            }
            .store(in: &cancellable)
        
        input.isPickerPresentToggle
            .sink(with: self) { owner, _ in
                owner.output.isPickerPresent.toggle()
            }
            .store(in: &cancellable)
        
        input.isEnglishJudge
            .sink(with: self) { owner, _ in
                owner.output.isEnglish = owner.myViewService.judgedIsEnglish()
            }
            .store(in: &cancellable)
        
        input.setupLocalizedYears
            .sink(with: self) { owner, value in
                owner.myViewService.generateLocalizedYears(from: value.past, to: value.future)
                    .receive(on: DispatchQueue.main)
                    .sink(with: owner) { owner, localizedYears in
                        owner.output.localizedYears = localizedYears
                    }
                    .store(in: &owner.cancellable)
            }
            .store(in: &cancellable)
        
        input.setupLocalizedMonths
            .sink(with: self) { owner, _ in
                let localizedMonths = owner.myViewService.generateLocalizedMonths()
                owner.output.localizedMonths = localizedMonths
            }
            .store(in: &cancellable)
        
        input.setupSelectYearMonth
            .sink(with: self) { owner, _ in
                let currentDate = owner.output.currentYearMonth
                let currentYearMonth = Calendar.current.dateComponents([.year, .month], from: currentDate)
                
                if let year = currentYearMonth.year,
                   let month = currentYearMonth.month {
                    owner.output.selectYear = year
                    owner.output.selectMonth = month
                }
            }
            .store(in: &cancellable)
        
        input.changeYearMonth
            .sink(with: self) { owner, value in
                let date = owner.myViewService.changeYearMonth(by: value, for: owner.output.currentYearMonth)
                owner.output.currentYearMonth = date
                
                let currentYearMonthString = owner.myViewService.currentMonthYearString(for: date)
                owner.output.currentYearMonthString = currentYearMonthString
            }
            .store(in: &cancellable)
        
        input.disappearPicker
            .sink(with: self) { owner, _ in
                let days = owner.myViewService.generateDays(for: owner.output.currentYearMonth)
                owner.output.selectMonthDays = days
                owner.output.localizedYears = [:]
                owner.output.localizedMonths = [:]
            }
            .store(in: &cancellable)
        
        input.deleteGesture
            .sink(with: self) { owner, movieId in
                owner.output.isRequestDelete = true
                owner.output.deleteMovieId = movieId
            }
            .store(in: &cancellable)
        
        input.realDeleteMovie
            .sink(with: self) { owner, movieId in
                owner.myViewService.requestDeleteMovie(movieId: movieId) // 저장된 영화 삭제
                    .receive(on: DispatchQueue.main)
                    .sink(with: self) { owner, _ in
                        let days = owner.myViewService.generateDays(for: owner.output.currentYearMonth)
                        owner.output.selectMonthDays = days // 날짜 데이터 reload
                    }
                    .store(in: &owner.cancellable)
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
        case pickerOnTask(past: Int, future: Int)
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
        case .pickerOnTask(let past, let future):
            input.isEnglishJudge.send(())
            input.setupLocalizedYears.send((past, future))
            input.setupLocalizedMonths.send(())
            input.setupSelectYearMonth.send(())
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
