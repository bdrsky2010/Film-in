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
        var viewOnTask = PassthroughSubject<Void, Never>()
        var deleteGesture = PassthroughSubject<Int, Never>()
        var realDeleteMovie = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        var isRequestDelete = false
        var deleteMovieId = 0
    }
    
    func transform() {
        input.viewOnTask
            .sink { [weak self] _ in
                guard let self else { return }
                let days = myViewService.generateDays()
                print(days)
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
        case deleteGesture(movieId: Int)
        case realDelete(movieId: Int)
    }
    
    func action(_ action: Action) {
        switch action {
        case .viewOnTask:
            input.viewOnTask.send(())
        case .deleteGesture(let movieId):
            input.deleteGesture.send(movieId)
        case .realDelete(let movieId):
            input.realDeleteMovie.send(movieId)
        }
    }
}

extension DateSetupViewModel {
    
}

