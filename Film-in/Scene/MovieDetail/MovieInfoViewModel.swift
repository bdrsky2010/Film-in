//
//  MovieInfoViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 9/27/24.
//

import Foundation
import Combine

final class MovieInfoViewModel: BaseViewModel, ViewModelType {
    private let movieInfoService: MovieInfoService
    private let networkMonitor: NetworkMonitor
    private let movieId: Int
    
    @Published var output = Output()
    
    var input = Input()
    var cancellable = Set<AnyCancellable>()
    
    
    init(
        movieInfoService: MovieInfoService,
        networkMonitor: NetworkMonitor,
        movieId: Int
    ) {
        self.movieInfoService = movieInfoService
        self.networkMonitor = networkMonitor
        self.movieId = movieId
        super.init()
        transform()
    }
}

extension MovieInfoViewModel {
    struct Input {
        var viewOnTask = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var networkConnect = true
        var isShowAlert = false
        var movieDetail = MovieInfo(id: 0, title: "", overview: "", genres: [], runtime: 0, rating: 0.0, releaseDate: "")
        var creditInfo = [CreditInfo]()
        var movieSimilars = [MovieSimilar.Movie]()
        var movieImages = MovieImages(backdrops: [], posterss: [])
        var movieVideos = [MovieVideo]()
    }
    
    func transform() {
        input.viewOnTask
            .sink {
                Task { [weak self] in
                    guard let self else { return }
                    await fetchMovieInfo()
                }
            }
            .store(in: &cancellable)
    }
}

extension MovieInfoViewModel {
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

extension MovieInfoViewModel {
    @MainActor
    private func fetchMovieInfo() async {
        guard networkMonitor.networkType != .notConnect else {
            output.networkConnect = false
            return
        }
        output.networkConnect = true
        
        do {
            try await fetchDetail()
            try await fetchCredit()
            try await fetchSimilar()
            try await fetchImages()
            try await fetchVideos()
        } catch {
            output.isShowAlert = true
        }
    }
    
    @MainActor
    private func fetchDetail() async throws {
        let query = MovieDetailQuery(movieId: movieId, language: "longLanguageCode".localized)
        let result = await movieInfoService.fetchMovieDetail(query: query)
        switch result {
        case .success(let success):
            output.movieDetail = success
        case .failure(let failure):
            print(#function, failure)
            throw failure
        }
    }
    
    @MainActor
    private func fetchCredit() async throws {
        let query = MovieCreditQuery(movieId: movieId, language: "longLanguageCode".localized)
        let result = await movieInfoService.fetchMovieCredit(query: query)
        switch result {
        case .success(let success):
            output.creditInfo = success
        case .failure(let failure):
            print(#function, failure)
            throw failure
        }
    }
    
    @MainActor
    private func fetchSimilar() async throws {
        let query = MovieSimilarQuery(movieId: movieId, language: "longLanguageCode".localized, page: 1)
        let result = await movieInfoService.fetchMovieSimilar(query: query)
        switch result {
        case .success(let success):
            output.movieSimilars = success.movies
        case .failure(let failure):
            print(#function, failure)
            throw failure
        }
    }
    
    @MainActor
    private func fetchImages() async throws {
        let query = MovieImagesQuery(movieId: movieId, imageLanguage: "\("shortLanguageCode".localized),en,null")
        let result = await movieInfoService.fetchMovieImages(query: query)
        switch result {
        case .success(let success):
            output.movieImages = success
        case .failure(let failure):
            print(#function, failure)
            throw failure
        }
    }
    
    @MainActor
    private func fetchVideos() async throws {
        let query = MovieVideosQuery(movieId: movieId, language: "longLanguageCode".localized)
        let result = await movieInfoService.fetchMovieVideos(query: query)
        switch result {
        case .success(let success):
            output.movieVideos = success
        case .failure(let failure):
            print(#function, failure)
            throw failure
        }
    }
}