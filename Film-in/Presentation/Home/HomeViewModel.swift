//
//  HomeViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 9/26/24.
//

import Foundation
import Combine

final class HomeViewModel: BaseObject, ViewModelType {
    private let homeService: HomeService
    private let networkMonitor: NetworkMonitor
    
    private var loadData: [String : Bool] = [:]
    
    @Published private(set) var output = Output()

    private(set) var input = Input()
    private(set) var cancellable = Set<AnyCancellable>()
    
    init(
        homeService: HomeService,
        networkMonitor: NetworkMonitor
    ) {
        self.homeService = homeService
        self.networkMonitor = networkMonitor
        super.init()
        transform()
    }
}

extension HomeViewModel {
    struct Input {
        let viewOnTask = PassthroughSubject<Void, Never>()
        let refresh = PassthroughSubject<Void, Never>()
        let onDismissAlert = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var networkConnect = true
        var isShowAlert = false
        var trendingMovies = HomeMovie(movies: [])
        var nowPlayingMovies = HomeMovie(movies: [])
        var upcomingMovies = HomeMovie(movies: [])
        var recommendMovies = HomeMovie(movies: [])
    }
    
    func transform() {
        input.viewOnTask
            .sink(with: self) { owner, _ in
                owner.fetchMovies()
            }
            .store(in: &cancellable)
        
        input.refresh
            .sink(with: self) { owner, _ in
                owner.loadData = [:]
                owner.fetchMovies()
            }
            .store(in: &cancellable)
        
        input.onDismissAlert
            .sink(with: self) { owner, _ in
                owner.output.isShowAlert = false
            }
            .store(in: &cancellable)
    }
}

extension HomeViewModel {
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

extension HomeViewModel {
    private func fetchMovies() {
        guard networkMonitor.networkType != .notConnect else {
            output.networkConnect = false
            return
        }
        output.networkConnect = true
        
        guard loadData.count == 0 else { return }
        
        fetchTrending()
        fetchNowPlaying()
        fetchUpcoming()
        fetchRecommend(
            isRecommend: false,
            recommendTotalPage: 1
        )
    }
    
    private func fetchTrending() {
        let query = TrendingQuery(language: "longLanguageCode".localized)
        let publisher = homeService.fetchTrending(query: query)
        publisher
            .receive(on: DispatchQueue.main)
            .sink(with: self) { owner, result in
                switch result {
                case .success(let trending):
                    owner.output.trendingMovies = trending
                    owner.dataLoad(for: #function)
                case .failure(_):
                    owner.errorHandling()
                }
            }
            .store(in: &cancellable)
    }
    
    private func fetchNowPlaying() {
        let query = HomeMovieQuery(
            language: "longLanguageCode".localized,
            page: 1,
            region: "regionCode".localized
        )
        let publisher = homeService.fetchNowPlaying(query: query)
        publisher
            .receive(on: DispatchQueue.main)
            .sink(with: self) { owner, result in
                switch result {
                case .success(let nowPlaying):
                    owner.output.nowPlayingMovies = nowPlaying
                    owner.dataLoad(for: #function)
                case .failure(_):
                    owner.errorHandling()
                }
            }
            .store(in: &cancellable)
    }
    
    private func fetchUpcoming() {
        let query = HomeMovieQuery(
            language: "longLanguageCode".localized,
            page: 1,
            region: "regionCode".localized
        )
        let publisher = homeService.fetchUpcoming(query: query)
        publisher
            .receive(on: DispatchQueue.main)
            .sink(with: self) { owner, result in
                switch result {
                case .success(let upcoming):
                    owner.output.upcomingMovies = upcoming
                    owner.dataLoad(for: #function)
                case .failure(_):
                    owner.errorHandling()
                }
            }
            .store(in: &cancellable)
    }
    
    private func fetchRecommend(
        isRecommend: Bool,
        recommendTotalPage: Int
    ) {
        let query = HomeMovieQuery(
            language: "longLanguageCode".localized,
            page: isRecommend ? Int.random(in: 1...recommendTotalPage) : 1,
            region: "regionCode".localized
        )
        let publisher = homeService.fetchDiscover(query: query)
        publisher
            .receive(on: DispatchQueue.main)
            .sink(with: self) { owner, result in
                switch result {
                case .success(let recommend):
                    if isRecommend {
                        owner.output.recommendMovies = recommend
                        owner.dataLoad(for: #function)
                    } else {
                        if let totalPage = recommend.totalPage {
                            owner.fetchRecommend(
                                isRecommend: true,
                                recommendTotalPage: totalPage <= 500 ? totalPage : 500
                            )
                        } else {
                            owner.output.recommendMovies = recommend
                            owner.dataLoad(for: #function)
                        }
                    }
                case .failure(let error):
                    owner.errorHandling()
                    print(#function, error)
                }
            }
            .store(in: &cancellable)
    }
}

extension HomeViewModel {
    private func errorHandling() {
        if !output.isShowAlert {
            output.isShowAlert = true
        }
    }
    
    private func dataLoad(for key: String) {
        loadData[key] = true
    }
}
