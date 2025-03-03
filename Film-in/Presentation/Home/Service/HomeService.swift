//
//  HomeService.swift
//  Film-in
//
//  Created by Minjae Kim on 9/26/24.
//

import Foundation
import Combine

protocol HomeService: AnyObject {
    func fetchTrending() -> AnyPublisher<Result<HomeMovie, TMDBError>, Never>
    func fetchNowPlaying(query: HomeMovieQuery) -> AnyPublisher<Result<HomeMovie, TMDBError>, Never>
    func fetchUpcoming(query: HomeMovieQuery) -> AnyPublisher<Result<HomeMovie, TMDBError>, Never>
    func fetchDiscover(query: HomeMovieQuery) -> AnyPublisher<Result<HomeMovie, TMDBError>, Never>
}

final class DefaultHomeService: BaseObject, HomeService {
    private let tmdbRepository: TMDBRepository
    private let databaseRepository: DatabaseRepository
    
    init(
        tmdbRepository: TMDBRepository,
        databaseRepository: DatabaseRepository
    ) {
        self.tmdbRepository = tmdbRepository
        self.databaseRepository = databaseRepository
    }
    func fetchTrending() -> AnyPublisher<Result<HomeMovie, TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result = await tmdbRepository.trendingMovieRequest()
                switch result {
                case .success(let success):
                    promise(.success(.success(HomeMovie(movies: success))))
                case .failure(let failure):
                    promise(.success(.failure(failure)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchNowPlaying(query: HomeMovieQuery) -> AnyPublisher<Result<HomeMovie, TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result = await tmdbRepository.nowPlayingRequest(query: query)
                switch result {
                case .success(let success):
                    promise(.success(.success(success)))
                case .failure(let failure):
                    promise(.success(.failure(failure)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchUpcoming(query: HomeMovieQuery) -> AnyPublisher<Result<HomeMovie, TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result = await tmdbRepository.upcomingRequest(query: query)
                switch result {
                case .success(let success):
                    promise(.success(.success(success)))
                case .failure(let failure):
                    promise(.success(.failure(failure)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchDiscover(query: HomeMovieQuery) -> AnyPublisher<Result<HomeMovie, TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result = await tmdbRepository.discoverRequest(query: query)
                switch result {
                case .success(let success):
                    promise(.success(.success(success)))
                case .failure(let failure):
                    promise(.success(.failure(failure)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
