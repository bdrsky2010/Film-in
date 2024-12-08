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
        var onChangeSearchQuery = PassthroughSubject<String, Never>()
        var onSubmitSearchQuery = PassthroughSubject<String, Never>()
    }
    
    struct Output {
    }
    
    func transform() {
        input.onChangeSearchQuery
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { query in
                print(query)
            }
            .store(in: &cancellable)
        
        input.onSubmitSearchQuery
            .throttle(for: 10, scheduler: RunLoop.main, latest: true)
            .sink { query in
                print(query)
            }
            .store(in: &cancellable)
    }
}

extension SearchResultViewModel {
    enum Action {
        case onChangeSearchQuery(_ query: String)
        case onSubmitSearchQuery(_ query: String)
    }
    
    func action(_ action: Action) {
        switch action {
        case .onChangeSearchQuery(let query):
            input.onChangeSearchQuery.send(query)
        case .onSubmitSearchQuery(let query):
            input.onSubmitSearchQuery.send(query)
        }
    }
}
