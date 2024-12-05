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
    
    @Published var output = Output()
    
    var input = Input()
    var cancellable = Set<AnyCancellable>()
    
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
    }
    
    struct Output {
        var networkConnect = true
        var isShowAlert = false
        var trendingMovie = [MovieData]()
        var popularPeople = [PopularPerson]()
    }
    
    func transform() {
        input.viewOnTask
            .sink { [weak self] in
                guard let self else { return }
                fetchData()
            }
            .store(in: &cancellable)
        
        input.refresh
            .sink { [weak self] in
                guard let self else { return }
                loadData = [:]
                fetchData()
            }
            .store(in: &cancellable)
    }
}

extension SearchViewModel {
    enum Action {
        case viewOnTask
        case refresh
    }
    
    func action(_ action: Action) {
        switch action {
        case .viewOnTask:
            input.viewOnTask.send(())
        case .refresh:
            input.refresh.send(())
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
        let query = TrendingQuery(language: "longLanguageCode".localized)
        let publisher = searchSerivce.fetchTrendingMovie(query: query)
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let movie):
                    output.trendingMovie = movie
                    dataLoad(for: #function)
                case .failure(let error):
                    print(error)
                    errorHandling()
                }
            }
            .store(in: &cancellable)
    }
    
    private func fetchTrendingPeople() {
        let query = PopularQuery(language: "longLanguageCode".localized)
        let publisher = searchSerivce.fetchPopularPeople(query: query)
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let people):
                    output.popularPeople = people
                    dataLoad(for: #function)
                case .failure(let error):
                    print(error)
                    errorHandling()
                }
            }
            .store(in: &cancellable)
    }
}

extension SearchViewModel {
    private func errorHandling() {
        if !output.isShowAlert {
            output.isShowAlert = true
        }
    }
    
    private func dataLoad(for key: String) {
        loadData[key] = true
    }
}
