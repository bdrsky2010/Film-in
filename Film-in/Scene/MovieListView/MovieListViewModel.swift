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

final class MovieListViewModel: BaseObject, ViewModelType {
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
            .sink { [weak self] in
                guard let self else { return }
                output.isShowAlert = false
                firstFetch()
            }
            .store(in: &cancellable)
        
        input.nextPage
            .sink { [weak self] in
                guard let self else { return }
                output.isShowAlert = false
                nextFetch()
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
    private func firstFetch() {
        guard networkMonitor.networkType != .notConnect else {
            output.networkConnect = false
            return
        }
        output.networkConnect = true
        
        fetchMovie(page: 1)
    }
    
    private func nextFetch() {
        guard networkMonitor.networkType != .notConnect else {
            output.networkConnect = false
            return
        }
        output.networkConnect = true
        output.isPagination = true // 페이지네이션 시작 설정
        defer { output.isPagination = false }  // 페이지네이션 완료 설정
        
        guard !isLastPage else { return }
        fetchMovie(page: recentPage + 1)
    }
}

extension MovieListViewModel {
    private func fetchMovie(page: Int) {
        switch usedTo {
        case .nowPlaying:
            fetchNowPlaying(page: page)
        case .upcoming:
            fetchUpcoming(page: page)
        case .recommend:
            fetchRecommend(page: page)
        case .similar(let movieId):
            fetchSimilar(movieId: movieId, page: page)
        case .search(_ ):
            break
        }
    }
    
    private func fetchNowPlaying(page: Int) {
        let query = HomeMovieQuery(
            language: "longLanguageCode".localized,
            page: page,
            region: "regionCode".localized
        )
        let publisher = movieListService.fetchNowPlaying(query: query)
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                resultHandler(result, page: page)
            }
            .store(in: &cancellable)
    }
    
    private func fetchUpcoming(page: Int) {
        let query = HomeMovieQuery(
            language: "longLanguageCode".localized,
            page: page,
            region: "regionCode".localized
        )
        let publisher = movieListService.fetchUpcoming(query: query)
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                resultHandler(result, page: page)
            }
            .store(in: &cancellable)
    }
    
    private func fetchRecommend(page: Int) {
        let query = HomeMovieQuery(
            language: "longLanguageCode".localized,
            page: page,
            region: "regionCode".localized
        )
        let publisher = movieListService.fetchDiscover(query: query)
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                resultHandler(result, page: page)
            }
            .store(in: &cancellable)
    }
    
    private func fetchSimilar(movieId: Int, page: Int) {
        let query = MovieSimilarQuery(
            movieId: movieId,
            language: "longLanguageCode".localized,
            page: page
        )
        let publisher = movieListService.fetchMovieSimilar(query: query)
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                resultHandler(result, page: page)
            }
            .store(in: &cancellable)
    }
}

extension MovieListViewModel {
    private func resultHandler(_ result: Result<HomeMovie, TMDBError>, page: Int) {
        switch result {
        case .success(let movies):
            if page == 1 {
                output.movies = movies
            } else {
                output.movies.movies.append(contentsOf: movies.movies)
            }
            
            if let responsePage = movies.page,
               let responseTotalPage = movies.totalPage
            {
                recentPage = responsePage
                isLastPage = responsePage == responseTotalPage
            }
        case .failure(_):
            if !output.isShowAlert { output.isShowAlert = true }
        }
    }
}
