//
//  MovieListViewModel.swift
//  Film-in
//
//  Created by Minjae Kim on 9/29/24.
//

import Foundation
import Combine

final class MultiListViewModel: BaseObject, ViewModelType {
    private let multiListService: MultiListService
    private let networkMonitor: NetworkMonitor
    
    private var recentPage = 1
    private var isLastPage = false
    
    @Published var output = Output()
    
    var input = Input()
    var cancellable = Set<AnyCancellable>()
    
    let usedTo: UsedTo
    
    init(
        multiListService: MultiListService,
        networkMonitor: NetworkMonitor,
        usedTo: UsedTo
    ) {
        self.multiListService = multiListService
        self.networkMonitor = networkMonitor
        self.usedTo = usedTo
        super.init()
        transform()
    }
}

extension MultiListViewModel {
    struct Input {
        var viewOnTask = PassthroughSubject<Void, Never>()
        var onRefresh = PassthroughSubject<Void, Never>()
        var nextPage = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var networkConnect = true
        var isShowAlert = false
        var isFirstFetch = false
        var isPagination = false
        var movies = HomeMovie(movies: [])
        var people = PagingPeople(page: 1, totalPage: 0, people: [])
    }
    
    func transform() {
        input.viewOnTask
            .sink(with: self) { owner, _ in
                owner.firstFetch()
            }
            .store(in: &cancellable)
        
        input.onRefresh
            .sink(with: self) { owner, _ in
                if owner.output.isShowAlert { owner.output.isShowAlert = false }
                if owner.recentPage == 1 {
                    owner.firstFetch()
                } else {
                    owner.nextFetch()
                }
            }
            .store(in: &cancellable)
        
        input.nextPage
            .sink(with: self) { owner, _ in
                owner.nextFetch()
            }
            .store(in: &cancellable)
    }
}

extension MultiListViewModel {
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
            input.onRefresh.send(())
        case .lastElement:
            input.nextPage.send(())
        }
    }
}

extension MultiListViewModel {
    private func firstFetch() {
        guard networkMonitor.networkType != .notConnect else {
            output.networkConnect = false
            return
        }
        output.networkConnect = true
        output.isFirstFetch = true
        fetchData(page: 1)
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
        fetchData(page: recentPage + 1)
    }
}

extension MultiListViewModel {
    private func fetchData(page: Int) {
        switch usedTo {
        case .nowPlaying:
            fetchNowPlaying(page: page)
        case .upcoming:
            fetchUpcoming(page: page)
        case .recommend:
            fetchRecommend(page: page)
        case .similar(let movieId):
            fetchSimilar(movieId: movieId, page: page)
        case .searchMovie(let query):
            fetchMovieSearch(query: query, page: page)
        case .searchPerson(let query):
            fetchPeopleSearch(query: query, page: page)
        }
    }
    
    private func fetchNowPlaying(page: Int) {
        let query = HomeMovieQuery(
            language: "longLanguageCode".localized,
            page: page,
            region: "regionCode".localized
        )
        let publisher = multiListService.fetchNowPlaying(query: query)
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(with: self) { owner, result in
                owner.resultHandler(result, page: page)
            }
            .store(in: &cancellable)
    }
    
    private func fetchUpcoming(page: Int) {
        let query = HomeMovieQuery(
            language: "longLanguageCode".localized,
            page: page,
            region: "regionCode".localized
        )
        let publisher = multiListService.fetchUpcoming(query: query)
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(with: self) { owner, result in
                owner.resultHandler(result, page: page)
            }
            .store(in: &cancellable)
    }
    
    private func fetchRecommend(page: Int) {
        let query = HomeMovieQuery(
            language: "longLanguageCode".localized,
            page: page,
            region: "regionCode".localized
        )
        let publisher = multiListService.fetchDiscover(query: query)
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(with: self) { owner, result in
                owner.resultHandler(result, page: page)
            }
            .store(in: &cancellable)
    }
    
    private func fetchSimilar(movieId: Int, page: Int) {
        let query = MovieSimilarQuery(
            movieId: movieId,
            language: "longLanguageCode".localized,
            page: page
        )
        let publisher = multiListService.fetchMovieSimilar(query: query)
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(with: self) { owner, result in
                owner.resultHandler(result, page: page)
            }
            .store(in: &cancellable)
    }
    
    private func fetchMovieSearch(query: String, page: Int) {
        guard !query.isEmpty else { return }
        let query = SearchMovieQuery(query: query, page: page)
        let publisher = multiListService.fetchMovieSearch(query: query)
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(with: self) { owner, result in
                owner.resultHandler(result, page: page)
            }
            .store(in: &cancellable)
    }
    
    private func fetchPeopleSearch(query: String, page: Int) {
        guard !query.isEmpty else { return }
        let query = SearchPersonQuery(query: query, page: page)
        let publisher = multiListService.fetchPeopleSearch(query: query)
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(with: self) { owner, result in
                owner.resultHandler(result, page: page)
            }
            .store(in: &cancellable)
    }
}

extension MultiListViewModel {
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
        if output.isFirstFetch { output.isFirstFetch = false }
    }
    
    private func resultHandler(_ result: Result<PagingPeople, TMDBError>, page: Int) {
        switch result {
        case .success(let people):
            if page == 1 {
                output.people = people
            } else {
                output.people.people.append(contentsOf: people.people)
            }
            
            recentPage = people.page
            isLastPage = people.page == people.totalPage
        case .failure(let error):
            print(error)
            if !output.isShowAlert { output.isShowAlert = true }
        }
        if output.isFirstFetch { output.isFirstFetch = false }
    }
}
