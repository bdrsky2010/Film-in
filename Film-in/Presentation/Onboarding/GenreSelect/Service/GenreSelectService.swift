//
//  GenreSelectService.swift
//  Film-in
//
//  Created by Minjae Kim on 9/25/24.
//

import Foundation
import Combine

protocol GenreSelectService: AnyObject {
    func fetchGenres() -> AnyPublisher<Result<[MovieGenre], TMDBError>, Never>
    func createUser(genres: Set<MovieGenre>)
}

final class DefaultGenreSelectService: BaseObject, GenreSelectService {
    private let tmdbRepository: TMDBRepository
    private let databaseRepository: DatabaseRepository
    
    init(
        tmdbRepository: TMDBRepository,
        databaseRepository: DatabaseRepository
    ) {
        self.tmdbRepository = tmdbRepository
        self.databaseRepository = databaseRepository
    }
    
    func fetchGenres() -> AnyPublisher<Result<[MovieGenre], TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result = await tmdbRepository.movieGenreRequest()
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
    
    func createUser(genres: Set<MovieGenre>) {
        databaseRepository.createUser()
        databaseRepository.appendLikeGenres(genres: genres)
    }
}
