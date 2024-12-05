//
//  SearchService.swift
//  Film-in
//
//  Created by Minjae Kim on 12/4/24.
//

import Foundation
import Combine

protocol SearchService: AnyObject {
    func fetchTrendingMovie(query: TrendingQuery) -> AnyPublisher<Result<[MovieData], TMDBError>, Never>
    func fetchPopularPeople(query: PopularQuery) -> AnyPublisher<Result<[PopularPerson], TMDBError>, Never>
}

final class DefaultSearchService: BaseObject {
    private let tmdbRepository: TMDBRepository
    
    init(tmdbRepository: TMDBRepository) {
        self.tmdbRepository = tmdbRepository
    }
}

extension DefaultSearchService: SearchService {
    func fetchTrendingMovie(query: TrendingQuery) -> AnyPublisher<Result<[MovieData], TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result = await tmdbRepository.trendingMovieRequest(query: query)
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
    
    func fetchPopularPeople(query: PopularQuery) -> AnyPublisher<Result<[PopularPerson], TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result = await tmdbRepository.popularPeopleRequest(query: query)
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
