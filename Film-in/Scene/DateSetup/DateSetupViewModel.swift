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
    let movie: (movieId: Int, title: String, backdrop: String, poster: String)
    
    let type: DateSetupType
    
    @Published var output = Output()
    
    var input = Input()
    var cancellable = Set<AnyCancellable>()
    
    init(
        dateSetupService: DateSetupService,
        movie: (movieId: Int, title: String, backdrop: String, poster: String),
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
            .sink { [weak self] _ in
                guard let self else { return }
                output.isDone = true
            }
            .store(in: &cancellable)
        
        input.requestPermission
            .sink { [weak self] _ in
                guard let self else { return }
                let publisher = dateSetupService.requestPermission()
                publisher
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] result in
                        guard let self else { return }
                        switch result {
                        case .success():
                            break
                        case .failure(_):
                            output.isError = true
                        }
                    }
                    .store(in: &cancellable)
            }
            .store(in: &cancellable)
        
        input.wantOrWatched
            .sink { [weak self] _ in
                guard let self else { return }
                saveMovie()
            }
            .store(in: &cancellable)
        
        input.moveToSetting
            .sink { [weak self] _ in
                guard let self else { return }
                dateSetupService.goToSetting()
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
            movieId: movie.movieId,
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
                    movie: (movie.movieId, movie.title),
                    date: output.selection
                )
                publisher
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] result in
                        guard let self else { return }
                        switch result {
                        case .success():
                            output.isSuccess = true
                        case .failure(_):
                            output.isSuccess = false
                            output.isError = true
                        }
                    }
                    .store(in: &cancellable)
            }
        case .watched:
            output.isSuccess = true
        }
    }
}
