//
//  DateSetupViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 10/1/24.
//

import Foundation
import Combine

final class DateSetupViewModel: BaseViewModel, ViewModelType {
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
            .sink { _ in
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        try await dateSetupService.requestPermission()
                    } catch {
                        output.isError = true
                    }
                }
            }
            .store(in: &cancellable)
        
        input.wantOrWatched
            .sink { _ in
                Task { [weak self] in
                    guard let self else { return }
                    await saveMovie()
                }
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
    @MainActor
    private func saveMovie() async {
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
            do {
                if output.isAlarm {
                    try await dateSetupService.registPushAlarm(movie: (movie.movieId, movie.title), date: output.selection)
                }
                output.isSuccess = true
            } catch {
                output.isSuccess = false
                output.isError = true
            }
        case .watched:
            output.isSuccess = true
        }
    }
}
