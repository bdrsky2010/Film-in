//
//  SearchResultViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 12/5/24.
//

import Foundation
import Combine

final class SearchResultViewModel: BaseObject, ViewModelType {
    private let networkMonitor: NetworkMonitor
    
    private var previousQuery = ""
    
    @Published var output = Output()

    var input = Input()
    var cancellable = Set<AnyCancellable>()
    
    init(
        networkMonitor: NetworkMonitor
    ) {
        self.networkMonitor = networkMonitor
        super.init()
        transform()
    }
}

extension SearchResultViewModel {
    struct Input {
        var onFocusTextField = PassthroughSubject<Void, Never>()
        var onChangeSearchQuery = PassthroughSubject<String, Never>()
        var onSubmitSearchQuery = PassthroughSubject<String, Never>()
        var onDismiss = PassthroughSubject<Void, Never>()
        var getRandomSearchQuery = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var isSearched = false
        var isFetching = false
        
        var randomSearchQuery = ""
    }
    
    func transform() {
        input.onFocusTextField
            .sink(with: self) { owner, _ in
                owner.output.isSearched = false
            }
            .store(in: &cancellable)
        
        input.onChangeSearchQuery
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink(with: self) { owner, query in
                print(query)
            }
            .store(in: &cancellable)
        
        input.onSubmitSearchQuery
            .throttle(for: 10, scheduler: RunLoop.main, latest: true)
            .sink(with: self) { owner, query in
                owner.output.isSearched = true
                
                if owner.previousQuery != query {
                    owner.output.isFetching = true
                    Task {
                        // TODO: TMDB Search(Movie / People) API Request
                        try await Task.sleep(nanoseconds: 1_500_000_000)
                        owner.output.isFetching = false
                    }
                    owner.previousQuery = query
                }
            }
            .store(in: &cancellable)
        
        input.onDismiss
            .sink(with: self) { owner, _ in
                owner.output.isSearched = true
            }
            .store(in: &cancellable)
        
        input.getRandomSearchQuery
            .sink(with: self) { owner, _ in
                owner.output.randomSearchQuery = owner.getRandomMCUMovie()
            }
            .store(in: &cancellable)
    }
}

extension SearchResultViewModel {
    enum Action {
        case onFocusTextField
        case onChangeSearchQuery(_ query: String)
        case onSubmitSearchQuery(_ query: String)
        case onDismiss
        case getRandomSearchQuery
    }
    
    func action(_ action: Action) {
        switch action {
        case .onFocusTextField:
            input.onFocusTextField.send(())
        case .onChangeSearchQuery(let query):
            input.onChangeSearchQuery.send(query)
        case .onSubmitSearchQuery(let query):
            input.onSubmitSearchQuery.send(query)
        case .onDismiss:
            input.onDismiss.send(())
        case .getRandomSearchQuery:
            input.getRandomSearchQuery.send(())
        }
    }
}

extension SearchResultViewModel {
    private func getRandomMCUMovie() -> String {
        let mcuMovies: [String] = [
            "Iron Man",
            "The Incredible Hulk",
            "Iron Man 2",
            "Thor",
            "Captain America: The First Avenger",
            "The Avengers",
            "Iron Man 3",
            "Thor: The Dark World",
            "Captain America: The Winter Soldier",
            "Guardians of the Galaxy",
            "Avengers: Age of Ultron",
            "Ant-Man",
            "Captain America: Civil War",
            "Doctor Strange",
            "Guardians of the Galaxy Vol. 2",
            "Spider-Man: Homecoming",
            "Thor: Ragnarok",
            "Black Panther",
            "Avengers: Infinity War",
            "Ant-Man and the Wasp",
            "Captain Marvel",
            "Avengers: Endgame",
            "Spider-Man: Far From Home",
            "Black Widow",
            "Shang-Chi and the Legend of the Ten Rings",
            "Eternals",
            "Spider-Man: No Way Home",
            "Doctor Strange in the Multiverse of Madness",
            "Thor: Love and Thunder",
            "Black Panther: Wakanda Forever",
            "Ant-Man and the Wasp: Quantumania",
            "Guardians of the Galaxy Vol. 3",
            "The Marvels"
        ]
        
        return mcuMovies.randomElement() ?? "Spider Man"
    }
}
