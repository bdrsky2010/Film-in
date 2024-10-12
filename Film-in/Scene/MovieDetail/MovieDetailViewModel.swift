//
//  MovieInfoViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 9/27/24.
//

import Foundation
import Combine

final class MovieDetailViewModel: BaseObject, ViewModelType {
    private let movieDetailService: MovieDetailService
    private let networkMonitor: NetworkMonitor
    let movieId: Int
    
    @Published var output = Output()
    
    var input = Input()
    var cancellable = Set<AnyCancellable>()
    
    init(
        movieDetailService: MovieDetailService,
        networkMonitor: NetworkMonitor,
        movieId: Int
    ) {
        self.movieDetailService = movieDetailService
        self.networkMonitor = networkMonitor
        self.movieId = movieId
        super.init()
        transform()
    }
}

extension MovieDetailViewModel {
    struct Input {
        var viewOnTask = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var networkConnect = true
        var isShowAlert = false
        var movieDetail = MovieInfo(id: 0, title: "", overview: "", genres: [], runtime: 0, rating: 0.0, releaseDate: "")
        var creditInfo = [CreditInfo]()
        var movieSimilars = [MovieSimilar.Movie]()
        var movieImages = MovieImages(backdrops: [], posters: [])
        var movieVideos = [MovieVideo]()
    }
    
    func transform() {
        input.viewOnTask
            .sink { [weak self] in
                guard let self else { return }
                fetchMovieInfo()
            }
            .store(in: &cancellable)
    }
}

extension MovieDetailViewModel {
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

extension MovieDetailViewModel {
    private func fetchMovieInfo() {
        guard networkMonitor.networkType != .notConnect else {
            output.networkConnect = false
            return
        }
        output.networkConnect = true
        
        fetchDetail()
        fetchCredit()
        fetchSimilar(isRandomed: true, totalPage: 1)
        fetchImages()
        fetchVideos(isRetry: false)
    }
    
    private func fetchDetail() {
        let query = MovieDetailQuery(movieId: movieId, language: "longLanguageCode".localized)
        let publisher = movieDetailService.fetchMovieDetail(query: query)
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let movieInfo):
                    output.movieDetail = movieInfo
                case .failure(let error):
                    if !output.isShowAlert { output.isShowAlert = true }
                }
            }
            .store(in: &cancellable)
    }
    
    private func fetchCredit() {
        let query = MovieCreditQuery(movieId: movieId, language: "longLanguageCode".localized)
        let publisher = movieDetailService.fetchMovieCredit(query: query)
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let creditInfo):
                    output.creditInfo = creditInfo
                case .failure(let error):
                    if !output.isShowAlert { output.isShowAlert = true }
                }
            }
            .store(in: &cancellable)
    }
    
    private func fetchSimilar(
        isRandomed: Bool,
        totalPage: Int
    ) {
        let query = MovieSimilarQuery(
            movieId: movieId,
            language: "longLanguageCode".localized,
            page: isRandomed ? Int.random(in: 1...totalPage) : 1
        )
        let publisher = movieDetailService.fetchMovieSimilar(query: query)
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let similar):
                    if isRandomed {
                        output.movieSimilars = similar.movies
                    } else {
                        fetchSimilar(
                            isRandomed: true,
                            totalPage: similar.totalPage <= 500 ? totalPage : 500
                        )
                    }
                case .failure(let error):
                    if !output.isShowAlert { output.isShowAlert = true }
                }
            }
            .store(in: &cancellable)
    }
    
    private func fetchImages() {
        let query = MovieImagesQuery(movieId: movieId, imageLanguage: "\("shortLanguageCode".localized),en,null")
        let publisher = movieDetailService.fetchMovieImages(query: query)
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let images):
                    output.movieImages = images
                case .failure(let error):
                    if !output.isShowAlert { output.isShowAlert = true }
                }
            }
            .store(in: &cancellable)
    }
    
    private func fetchVideos(isRetry: Bool) {
        let query = MovieVideosQuery(movieId: movieId, language: !isRetry ? "longLanguageCode".localized : "en-US")
        let publisher = movieDetailService.fetchMovieVideos(query: query)
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let videos):
                    output.movieVideos = videos
                case .failure(let error):
                    if !output.isShowAlert { output.isShowAlert = true }
                }
            }
            .store(in: &cancellable)
    }
}
