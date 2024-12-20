//
//  DateSetupViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 10/1/24.
//

import Foundation
import Combine

final class DateSetupViewModel: BaseObject, ViewModelType {
    private let dateSetupService: DateSetupService
    private let movie: MovieData
    
    let type: DateSetupType
    
    @Published var output = Output()
    
    var input = Input()
    var cancellable = Set<AnyCancellable>()
    
    init(
        dateSetupService: DateSetupService,
        movie: MovieData,
        type: DateSetupType
    ) {
        self.dateSetupService = dateSetupService
        self.movie = movie
        self.type = type
        super.init()
        transform()
    }
}

extension DateSetupViewModel {
    struct Input {
        var done = PassthroughSubject<Void, Never>()
        var requestPermission = PassthroughSubject<Void, Never>()
        var wantOrWatched = PassthroughSubject<Void, Never>()
        var moveToSetting = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var selection = Date()
        var isAlarm = false
        var isDone = false
        var isError = false
        var isSuccess = false
    }
    
    func transform() {
        input.done
            .sink(with: self) { owner, _ in
                owner.output.isDone = true
            }
            .store(in: &cancellable)
        
        input.requestPermission
            .sink(with: self) { owner, _ in
                let publisher = owner.dateSetupService.requestPermission()
                publisher
                    .receive(on: DispatchQueue.main)
                    .sink(with: self) { owner, result in
                        switch result {
                        case .success():
                            break
                        case .failure(_):
                            owner.output.isError = true
                        }
                    }
                    .store(in: &owner.cancellable)
            }
            .store(in: &cancellable)
        
        input.wantOrWatched
            .sink(with: self) { owner, _ in
                owner.saveMovie()
            }
            .store(in: &cancellable)
        
        input.moveToSetting
            .sink(with: self) { owner, _ in
                owner.dateSetupService.goToSetting()
            }
            .store(in: &cancellable)
    }
}

extension DateSetupViewModel {
    enum Action {
        case done
        case requestPermission
        case wantOrWatched
        case moveToSetting
    }
    
    func action(_ action: Action) {
        switch action {
        case .done:
            input.done.send(())
        case .requestPermission:
            input.requestPermission.send(())
        case .wantOrWatched:
            input.wantOrWatched.send(())
        case .moveToSetting:
            input.moveToSetting.send(())
        }
    }
}

extension DateSetupViewModel {
    private func saveMovie() {
        let query = WantWatchedMovieQuery(
            movieId: movie._id,
            title: movie.title,
            backdrop: movie.backdrop,
            poster: movie.poster,
            date: output.selection,
            type: type,
            isAlarm: output.isAlarm
        )
        
        dateSetupService.saveWantOrWatchedMovie(query: query)
        
        switch type {
        case .want:
            if output.isAlarm {
                let publisher = dateSetupService.registPushAlarm(
                    movie: (movie._id, movie.title),
                    date: output.selection
                )
                publisher
                    .receive(on: DispatchQueue.main)
                    .sink(with: self) { owner, result in
                        switch result {
                        case .success():
                            owner.output.isSuccess = true
                        case .failure(_):
                            owner.output.isSuccess = false
                            owner.output.isError = true
                        }
                    }
                    .store(in: &cancellable)
            } else {
                output.isSuccess = true
            }
        case .watched:
            output.isSuccess = true
        }
    }
}
