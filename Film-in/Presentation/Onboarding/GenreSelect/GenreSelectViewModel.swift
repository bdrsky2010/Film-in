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
        var isShowAlert = false
        var genres = [MovieGenre]()
        var selectedGenres = Set<MovieGenre>()
        var selectedGenreRows = [[MovieGenre]]()
    }
    
    func transform() {
        input.viewOnTask
            .sink(with: self) { owner, _ in
                owner.fetchGenres()
            }
            .store(in: &cancellable)
        
        input.changedGenres
            .sink(with: self) { owner, _ in
                owner.output.selectedGenreRows = GenreHandler.getRows(
                    genres: owner.output.selectedGenres,
                    spacing: 40,
                    fontSize: 16,
                    windowWidth: GenreHandler.windowWidth)
            }
            .store(in: &cancellable)
        
        input.addGenre
            .sink(with: self) { owner, genre in
                if owner.output.selectedGenres.contains(genre) {
                    owner.output.selectedGenres.remove(genre)
                } else {
                    owner.output.selectedGenres.insert(genre)
                }
            }
            .store(in: &cancellable)
        
        input.removeGenre
            .sink(with: self) { owner, genre in
                owner.output.selectedGenres.remove(genre)
            }
            .store(in: &cancellable)
        
        input.createUser
            .sink(with: self) { owner, _ in
                owner.genreSelectService.createUser(genres: owner.output.selectedGenres)
            }
            .store(in: &cancellable)
    }
    
    private func fetchGenres() {
        guard networkMonitor.networkType != .notConnect else {
            output.networkConnect = false
            return
        }
        output.networkConnect = true
        let query = MovieGenreQuery(language: "longLanguageCode".localized)
        let publisher = genreSelectService.fetchGenres(query: query)
        publisher
            .receive(on: DispatchQueue.main)
            .sink(with: self) { owner, result in
                switch result {
                case .success(let genres):
                    owner.output.genres = genres
                case .failure(let error):
                    owner.output.isShowAlert = true
                    print(error)
                }
            }
            .store(in: &cancellable)
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
