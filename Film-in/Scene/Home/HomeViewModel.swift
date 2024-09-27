//
//  HomeViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 9/26/24.
//

import Foundation
import Combine

final class HomeViewModel: BaseViewModel, ViewModelType {
    private let homeService: HomeService
    private let networkMonitor: NetworkMonitor
    
    private var isRecommended = false
    private var recommendTotalPage = 0
    
    @Published var output = Output()
    
    var input = Input()
    var cancellable = Set<AnyCancellable>()
    
    
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
            .sink {
                Task { [weak self] in
                    guard let self else { return }
                    await fetchMovies()
                }
            }
            .store(in: &cancellable)
    }
}

extension HomeViewModel {
    enum Action {
        case viewOnTask
        case refresh
    }
    
    func action(_ action: Action) {
        switch action {
        case .viewOnTask:
            input.viewOnTask.send(())
        case .refresh:
            input.viewOnTask.send(())
        }
    }
}

extension HomeViewModel {
    @MainActor
    private func fetchMovies() async {
        guard networkMonitor.networkType != .notConnect else {
            output.networkConnect = false
            return
        }
        output.networkConnect = true
        
        do {
            try await fetchTrending()
            try await fetchNowPlaying()
            try await fetchUpcoming()
            try await fetchRecommend()
        } catch {
            output.isShowAlert = true
        }
    }
    
    @MainActor
    private func fetchTrending() async throws {
        let query = TrendingQuery(language: "longLanguageCode".localized)
        let result = await homeService.fetchTrending(query: query)
        switch result {
        case .success(let success):
            output.trendingMovies = success
        case .failure(let failure):
            print(#function, failure)
            throw failure
        }
    }
    
    @MainActor
    private func fetchNowPlaying() async throws {
        let query = HomeMovieQuery(
            language: "longLanguageCode".localized,
            page: 1,
            region: "regionCode".localized
        )
        let result = await homeService.fetchNowPlaying(query: query)
        switch result {
        case .success(let success):
            output.nowPlayingMovies = success
        case .failure(let failure):
            print(#function, failure)
            throw failure
        }
    }
    
    @MainActor
    private func fetchUpcoming() async throws {
        let query = HomeMovieQuery(
            language: "longLanguageCode".localized,
            page: 1,
            region: "regionCode".localized
        )
        let result = await homeService.fetchUpcoming(query: query)
        switch result {
        case .success(let success):
            output.upcomingMovies = success
        case .failure(let failure):
            print(#function, failure)
            throw failure
        }
    }
    
    @MainActor
    private func fetchRecommend() async throws {
        let query = HomeMovieQuery(
            language: "longLanguageCode".localized,
            page: isRecommended ? Int.random(in: 1...recommendTotalPage) : 1,
            region: "regionCode".localized
        )
        let result = await homeService.fetchDiscover(query: query)
        switch result {
        case .success(let success):
            if isRecommended {
                isRecommended = false
                output.recommendMovies = success
            } else {
                if let totalPage = success.totalPage {
                    isRecommended = true
                    recommendTotalPage = totalPage <= 500 ? totalPage : 500
                    try await fetchRecommend()
                } else {
                    output.recommendMovies = success
                }
            }
        case .failure(let failure):
            print(#function, failure)
            throw failure
        }
    }
}
