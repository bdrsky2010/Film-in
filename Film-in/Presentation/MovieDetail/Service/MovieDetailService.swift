//
//  MovieInfoService.swift
//  Film-in
//
//  Created by Minjae Kim on 9/27/24.
//

import Foundation
import Combine

protocol MovieDetailService: AnyObject {
    func fetchMovieDetail(query: MovieDetailQuery) -> AnyPublisher<Result<MovieInfo, TMDBError>, Never>
    func fetchMovieCredit(query: MovieCreditQuery) -> AnyPublisher<Result<[CreditInfo], TMDBError>, Never>
    func fetchMovieSimilar(query: MovieSimilarQuery) -> AnyPublisher<Result<MovieSimilar, TMDBError>, Never>
    func fetchMovieImages(query: MovieImagesQuery) -> AnyPublisher<Result<MovieImages, TMDBError>, Never>
    func fetchMovieVideos(query: MovieVideosQuery) -> AnyPublisher<Result<[MovieVideo], TMDBError>, Never>
}

final class DefaultMovieDetailService: BaseObject, MovieDetailService {
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

extension DefaultMovieDetailService {
    func fetchMovieDetail(query: MovieDetailQuery) -> AnyPublisher<Result<MovieInfo, TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result = await tmdbRepository.detailRequest(query: query)
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
    
    func fetchMovieCredit(query: MovieCreditQuery) -> AnyPublisher<Result<[CreditInfo], TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result = await tmdbRepository.creditRequest(query: query)
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
    
    func fetchMovieSimilar(query: MovieSimilarQuery) -> AnyPublisher<Result<MovieSimilar, TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result: Result<MovieSimilar, TMDBError> = await tmdbRepository.similarRequest(query: query)
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
    
    func fetchMovieImages(query: MovieImagesQuery) -> AnyPublisher<Result<MovieImages, TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result = await tmdbRepository.imagesRequest(query: query)
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
    
    func fetchMovieVideos(query: MovieVideosQuery) -> AnyPublisher<Result<[MovieVideo], TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result = await tmdbRepository.videosRequest(query: query)
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
