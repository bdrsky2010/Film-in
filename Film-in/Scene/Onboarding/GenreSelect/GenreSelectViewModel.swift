//
//  GenreSelectViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 9/24/24.
//

import Foundation
import Combine

final class GenreSelectViewModel: BaseObject, ViewModelType {
    private let genreSelectService: GenreSelectService
    private let networkMonitor: NetworkMonitor
    
    @Published var output = Output()
    
    var cancellable = Set<AnyCancellable>()
    var input = Input()
    
    init(
        genreSelectService: GenreSelectService,
        networkMonitor: NetworkMonitor
    ) {
        self.genreSelectService = genreSelectService
        self.networkMonitor = networkMonitor
        super.init()
        transform()
    }
}

extension GenreSelectViewModel {
    struct Input {
        let viewOnTask = PassthroughSubject<Void, Never>()
        let changedGenres = PassthroughSubject<Void, Never>()
        let addGenre = PassthroughSubject<MovieGenre, Never>()
        let removeGenre = PassthroughSubject<MovieGenre, Never>()
        let createUser = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var networkConnect = true
        var genres = [MovieGenre]()
        var selectedGenres = Set<MovieGenre>()
        var selectedGenreRows = [[MovieGenre]]()
    }
    
    func transform() {
        input.viewOnTask
            .sink {
                Task { [weak self] in
                    guard let self else { return }
                    await fetchGenres()
                }
            }
            .store(in: &cancellable)
        
        input.changedGenres
            .sink { [weak self] in
                guard let self else { return }
                output.selectedGenreRows = GenreHandler.getRows(
                    genres: output.selectedGenres,
                    spacing: 40,
                    fontSize: 16,
                    windowWidth: GenreHandler.windowWidth)
            }
            .store(in: &cancellable)
        
        input.addGenre
            .sink { [weak self] genre in
                guard let self else { return }
                
                if output.selectedGenres.contains(genre) {
                    output.selectedGenres.remove(genre)
                } else {
                    output.selectedGenres.insert(genre)
                }
            }
            .store(in: &cancellable)
        
        input.removeGenre
            .sink { [weak self] genre in
                guard let self else { return }
                output.selectedGenres.remove(genre)
            }
            .store(in: &cancellable)
        
        input.createUser
            .sink { [weak self] _ in
                guard let self else { return }
                genreSelectService.createUser(genres: output.selectedGenres)
            }
            .store(in: &cancellable)
    }
    
    @MainActor
    private func fetchGenres() async {
        guard networkMonitor.networkType != .notConnect else {
            output.networkConnect = false
            return
        }
        output.networkConnect = true
        let query = MovieGenreQuery(language: "longLanguageCode".localized)
        let result = await genreSelectService.fetchGenres(query: query)
        switch result {
        case .success(let success):
            output.genres = success
        case .failure(let failure):
            print(failure)
        }
    }
}

extension GenreSelectViewModel {
    enum Action {
        case viewOnTask
        case refresh
        case changedGenres
        case addGenre(_ genre: MovieGenre)
        case removeGenre(_ genre: MovieGenre)
        case createUser
    }
    
    func action(_ action: Action) {
        switch action {
        case .viewOnTask:
            input.viewOnTask.send(())
        case .refresh:
            input.viewOnTask.send(())
        case .changedGenres:
            input.changedGenres.send(())
        case .addGenre(let genre):
            input.addGenre.send(genre)
        case .removeGenre(let genre):
            input.removeGenre.send(genre)
        case .createUser:
            input.createUser.send(())
        }
    }
}
