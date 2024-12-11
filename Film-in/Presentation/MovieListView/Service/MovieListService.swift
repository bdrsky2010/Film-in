//
//  MovieListService.swift
//  Film-in
//
//  Created by Minjae Kim on 9/29/24.
//

import Foundation
import Combine

protocol MovieListService: AnyObject {
    func fetchNowPlaying(query: HomeMovieQuery) -> Future<Result<HomeMovie, TMDBError>, Never>
    func fetchUpcoming(query: HomeMovieQuery) -> Future<Result<HomeMovie, TMDBError>, Never>
    func fetchDiscover(query: HomeMovieQuery) -> Future<Result<HomeMovie, TMDBError>, Never>
    func fetchMovieSimilar(query: MovieSimilarQuery) -> Future<Result<HomeMovie, TMDBError>, Never>
    func fetchMovieSearch(query: SearchMovieQuery) -> AnyPublisher<Result<HomeMovie, TMDBError>, Never>
    func fetchPeopleSearch(query: SearchPersonQuery) -> AnyPublisher<Result<PagingPeople, TMDBError>, Never>
}

final class DefaultMovieListService: BaseObject, MovieListService {
    private let tmdbRepository: TMDBRepository
    private let databaseRepository: DatabaseRepository
    
    init(
        tmdbRepository: TMDBRepository,
        databaseRepository: DatabaseRepository
    ) {
        self.tmdbRepository = tmdbRepository
        self.databaseRepository = databaseRepository
    }
}

extension DefaultMovieListService {
    func fetchNowPlaying(query: HomeMovieQuery) -> Future<Result<HomeMovie, TMDBError>, Never> {
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
    }
    
    func fetchUpcoming(query: HomeMovieQuery) -> Future<Result<HomeMovie, TMDBError>, Never> {
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
    }
    
    @MainActor
    func fetchDiscover(query: HomeMovieQuery) -> Future<Result<HomeMovie, TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let _query = HomeMovieQuery(
                    language: query.language,
                    page: query.page,
                    region: query.region,
                    withGenres: databaseRepository.user?.selectedGenreIds.map { String($0) }.joined(separator: "|"))
                let result = await tmdbRepository.discoverRequest(query: _query)
                switch result {
                case .success(let success):
                    promise(.success(.success(success)))
                case .failure(let failure):
                    promise(.success(.failure(failure)))
                }
            }
        }
    }
    
    func fetchMovieSimilar(query: MovieSimilarQuery) -> Future<Result<HomeMovie, TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result: Result<HomeMovie, TMDBError> = await tmdbRepository.similarRequest(query: query)
                switch result {
                case .success(let success):
                    promise(.success(.success(success)))
                case .failure(let failure):
                    promise(.success(.failure(failure)))
                }
            }
        }
    }
    
    func fetchMovieSearch(query: SearchMovieQuery) -> AnyPublisher<Result<HomeMovie, TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result = await tmdbRepository.searchMovieRequest(query: query)
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
    
    func fetchPeopleSearch(query: SearchPersonQuery) -> AnyPublisher<Result<PagingPeople, TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result = await tmdbRepository.searchPersonRequest(query: query)
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
