//
//  SearchViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 12/1/24.
//

import Foundation
import Combine

final class SearchViewModel: BaseObject, ViewModelType {
    private let searchSerivce: SearchService
    private let networkMonitor: NetworkMonitor
    
    private var loadData: [String : Bool] = [:]
    
    @Published private(set) var output = Output()

    private(set) var input = Input()
    private(set) var cancellable = Set<AnyCancellable>()
    
    init(
        searchSerivce: SearchService,
        networkMonitor: NetworkMonitor
    ) {
        self.searchSerivce = searchSerivce
        self.networkMonitor = networkMonitor
        super.init()
        transform()
    }
}

extension SearchViewModel {
    struct Input {
        let viewOnTask = PassthroughSubject<Void, Never>()
        let refresh = PassthroughSubject<Void, Never>()
        let onDismissAlert = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var networkConnect = true
        var isShowAlert = false
        var trendingMovie = [MovieData]()
        var popularPeople = [PopularPerson]()
    }
    
    func transform() {
        input.viewOnTask
            .sink(with: self) { owner, _ in
                owner.fetchData()
            }
            .store(in: &cancellable)
        
        input.refresh
            .sink(with: self) { owner, _ in
                owner.loadData = [:]
                owner.fetchData()
            }
            .store(in: &cancellable)
        
        input.onDismissAlert
            .sink(with: self) { owner, _ in
                owner.output.isShowAlert = false
            }
            .store(in: &cancellable)
    }
}

extension SearchViewModel {
    enum Action {
        case viewOnTask
        case refresh
        case onDismissAlert
    }
    
    func action(_ action: Action) {
        switch action {
        case .viewOnTask:
            input.viewOnTask.send(())
        case .refresh:
            input.refresh.send(())
        case .onDismissAlert:
            input.onDismissAlert.send(())
        }
    }
}

extension SearchViewModel {
    private func fetchData() {
        guard networkMonitor.networkType != .notConnect else {
            output.networkConnect = false
            return
        }
        output.networkConnect = true
        
        guard loadData.count == 0 else { return }
        
        fetchTrendingMovie()
        fetchTrendingPeople()
    }
    
    private func fetchTrendingMovie() {
        let publisher = searchSerivce.fetchTrendingMovie()
        publisher
            .receive(on: DispatchQueue.main)
            .sink(with: self) { owner, result in
                switch result {
                case .success(let movie):
                    owner.output.trendingMovie = movie
                    owner.dataLoad(for: #function)
                case .failure(let error):
                    owner.errorHandling()
                    print(error)
                }
            }
            .store(in: &cancellable)
    }
    
    private func fetchTrendingPeople() {
        let publisher = searchSerivce.fetchPopularPeople()
        publisher
            .receive(on: DispatchQueue.main)
            .sink(with: self) { owner, result in
                switch result {
                case .success(let people):
                    owner.output.popularPeople = people
                    owner.dataLoad(for: #function)
                case .failure(let error):
                    owner.errorHandling()
                    print(error)
                }
            }
            .store(in: &cancellable)
    }
}

extension SearchViewModel {
    private func errorHandling() {
        if !output.isShowAlert { output.isShowAlert = true }
    }
    
    private func dataLoad(for key: String) {
        loadData[key] = true
    }
}
