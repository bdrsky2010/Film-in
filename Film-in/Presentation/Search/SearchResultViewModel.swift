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
    private let searchResultService: SearchResultService
    
    private var previousQuery = ""
    
    @Published private(set) var output = Output()

    private(set) var input = Input()
    private(set) var cancellable = Set<AnyCancellable>()
    
    init(
        networkMonitor: NetworkMonitor,
        searchResultService: SearchResultService
    ) {
        self.networkMonitor = networkMonitor
        self.searchResultService = searchResultService
        super.init()
        transform()
    }
}

extension SearchResultViewModel {
    struct Input {
        var onRefresh = PassthroughSubject<Void, Never>()
        var onDismissAlert = PassthroughSubject<Void, Never>()
        var onFocusTextField = PassthroughSubject<Void, Never>()
        var onChangeSearchQuery = PassthroughSubject<String, Never>()
        var onSubmitSearchQuery = PassthroughSubject<String, Never>()
        var onDismiss = PassthroughSubject<Void, Never>()
        var getRandomSearchQuery = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var isShowAlert = false
        var isSearched = false
        var multiSearchList = [RelatedKeyword]()
        var randomSearchQuery = ""
    }
    
    func transform() {
        input.onDismissAlert
            .sink(with: self) { owner, _ in
                owner.output.isShowAlert = false
            }
            .store(in: &cancellable)
        
        input.onFocusTextField
            .sink(with: self) { owner, _ in
                owner.output.isSearched = false
            }
            .store(in: &cancellable)
        
        input.onChangeSearchQuery
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink(with: self) { owner, query in
                let searchQuery = SearchQuery(query: query)
                let publisher = owner.searchResultService.fetchMultiSearch(query: searchQuery)
                publisher
                    .receive(on: DispatchQueue.main)
                    .sink(with: owner) { owner, result in
                        switch result {
                        case .success(let multiSearch):
                            owner.output.multiSearchList = multiSearch
                        case .failure(let error):
                            owner.errorHandling()
                            print(error)
                        }
                    }
                    .store(in: &owner.cancellable)
            }
            .store(in: &cancellable)
        
        input.onSubmitSearchQuery
            .throttle(for: 10, scheduler: RunLoop.main, latest: true)
            .sink(with: self) { owner, query in
                owner.output.isSearched = true
                
                if owner.previousQuery != query {
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
                owner.output.randomSearchQuery = owner.searchResultService.getRandomMCUMovie()
            }
            .store(in: &cancellable)
    }
}

extension SearchResultViewModel {
    enum Action {
        case onDismissAlert
        case onFocusTextField
        case onChangeSearchQuery(_ query: String)
        case onSubmitSearchQuery(_ query: String)
        case onDismiss
        case getRandomSearchQuery
    }
    
    func action(_ action: Action) {
        switch action {
        case .onDismissAlert:
            input.onDismissAlert.send(())
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
    private func errorHandling() {
        if !output.isShowAlert { output.isShowAlert = true }
    }
}
