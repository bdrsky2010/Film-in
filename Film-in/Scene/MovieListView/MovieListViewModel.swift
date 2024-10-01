//
//  MovieListViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 9/29/24.
//

import Foundation
import Combine

enum UsedTo {
    case nowPlaying
    case upcoming
    case recommend
    case similar(_ movieId: Int)
    case search(_ text: String)
}

final class MovieListViewModel: BaseViewModel, ViewModelType {
    private let movieListService: MovieListService
    private let networkMonitor: NetworkMonitor
    private let usedTo: UsedTo
    
    private var recentPage = 1
    private var isLastPage = false
    
    @Published var output = Output()
    
    var input = Input()
    var cancellable = Set<AnyCancellable>()
    
    init(
        movieListService: MovieListService,
        networkMonitor: NetworkMonitor,
        usedTo: UsedTo
    ) {
        self.movieListService = movieListService
        self.networkMonitor = networkMonitor
        self.usedTo = usedTo
        super.init()
        transform()
    }
}

extension MovieListViewModel {
    struct Input {
        var viewOnTask = PassthroughSubject<Void, Never>()
        var nextPage = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var networkConnect = true
        var isShowAlert = false
        var isPagination = false
        var movies = HomeMovie(movies: [])
    }
    
    func transform() {
        input.viewOnTask
            .sink {
                Task { [weak self] in
                    guard let self else { return }
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        output.isShowAlert = false
                    }
                    await firstFetch()
                }
            }
            .store(in: &cancellable)
        
        input.nextPage
            .sink {
                Task { [weak self] in
                    guard let self else { return }
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        output.isShowAlert = false
                    }
                    await nextFetch()
                }
            }
            .store(in: &cancellable)
    }
}

extension MovieListViewModel {
    enum Action {
        case viewOnTask
        case refresh
        case lastElement
    }
    
    func action(_ action: Action) {
        switch action {
        case .viewOnTask:
            input.viewOnTask.send(())
        case .refresh:
            input.viewOnTask.send(())
        case .lastElement:
            input.nextPage.send(())
        }
    }
}

extension MovieListViewModel {
    @MainActor
    private func firstFetch() async {
        guard networkMonitor.networkType != .notConnect else {
            output.networkConnect = false
            return
        }
        output.networkConnect = true
        
        await fetchMovie(page: 1)
    }
    
    @MainActor
    private func nextFetch() async {
        guard networkMonitor.networkType != .notConnect else {
            output.networkConnect = false
            return
        }
        output.networkConnect = true
        output.isPagination = true
        defer { output.isPagination = false }
        
        guard !isLastPage else { return }
        await fetchMovie(page: recentPage + 1)
    }
    
    @MainActor
    private func fetchMovie(page: Int) async {
        do {
            switch usedTo {
            case .nowPlaying:
                try await fetchNowPlaying(page: page)
            case .upcoming:
                try await fetchUpcoming(page: page)
            case .recommend:
                try await fetchRecommend(page: page)
            case .similar(let movieId):
                try await fetchSimilar(movieId: movieId, page: page)
            case .search(_ ):
                break
            }
        } catch {
            output.isShowAlert = true
        }
    }
}

extension MovieListViewModel {
    @MainActor
    private func fetchNowPlaying(page: Int) async throws {
        let query = HomeMovieQuery(
            language: "longLanguageCode".localized,
            page: page,
            region: "regionCode".localized
        )
        let result = await movieListService.fetchNowPlaying(query: query)
        switch result {
        case .success(let success):
            if page == 1 {
                output.movies = success
            } else {
                output.movies.movies.append(contentsOf: success.movies)
            }
            
            if let responsePage = success.page,
               let responseTotalPage = success.totalPage
            {
                recentPage = responsePage
                isLastPage = responsePage == responseTotalPage
            }
        case .failure(let failure):
            print(#function, failure)
            throw failure
        }
    }
    
    @MainActor
    private func fetchUpcoming(page: Int) async throws {
        let query = HomeMovieQuery(
            language: "longLanguageCode".localized,
            page: page,
            region: "regionCode".localized
        )
        let result = await movieListService.fetchUpcoming(query: query)
        switch result {
        case .success(let success):
            if page == 1 {
                output.movies = success
            } else {
                output.movies.movies.append(contentsOf: success.movies)
            }
            
            if let responsePage = success.page,
               let responseTotalPage = success.totalPage
            {
                recentPage = responsePage
                isLastPage = responsePage == responseTotalPage
            }
        case .failure(let failure):
            print(#function, failure)
            throw failure
        }
    }
    
    @MainActor
    private func fetchRecommend(page: Int) async throws {
        let query = HomeMovieQuery(
            language: "longLanguageCode".localized,
            page: page,
            region: "regionCode".localized
        )
        let result = await movieListService.fetchDiscover(query: query)
        switch result {
        case .success(let success):
            if page == 1 {
                output.movies = success
            } else {
                output.movies.movies.append(contentsOf: success.movies)
            }
            
            if let responsePage = success.page,
               let responseTotalPage = success.totalPage
            {
                recentPage = responsePage
                isLastPage = responsePage == responseTotalPage
            }
        case .failure(let failure):
            print(#function, failure)
            throw failure
        }
    }
    
    @MainActor
    private func fetchSimilar(movieId: Int, page: Int) async throws {
        let query = MovieSimilarQuery(
            movieId: movieId,
            language: "longLanguageCode".localized,
            page: page
        )
        let result = await movieListService.fetchMovieSimilar(query: query)
        switch result {
        case .success(let success):
            if page == 1 {
                output.movies = success
            } else {
                output.movies.movies.append(contentsOf: success.movies)
            }
            
            if let responsePage = success.page,
               let responseTotalPage = success.totalPage
            {
                recentPage = responsePage
                isLastPage = responsePage == responseTotalPage
            }
        case .failure(let failure):
            print(#function, failure)
            throw failure
        }
    }
}
