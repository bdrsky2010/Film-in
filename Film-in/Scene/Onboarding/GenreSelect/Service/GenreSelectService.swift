//
//  GenreSelectService.swift
//  Film-in
//
//  Created by Minjae Kim on 9/25/24.
//

import Foundation

protocol GenreSelectService: AnyObject {
    func fetchGenres(query: MovieGenreQuery) async -> Result<[MovieGenre], TMDBError>
    func createUser(genres: Set<MovieGenre>)
}

final class DefaultGenreSelectService: GenreSelectService {
    private let tmdbRepository: TMDBRepository
    private let databaseRepository: DatabaseRepository
    
    init(
        tmdbRepository: TMDBRepository,
        databaseRepository: DatabaseRepository
    ) {
        self.tmdbRepository = tmdbRepository
        self.databaseRepository = databaseRepository
    }
    
    deinit {
        print("\(String(describing: self)) is deinit")
    }
    
    func fetchGenres(query: MovieGenreQuery) async -> Result<[MovieGenre], TMDBError> {
        return await tmdbRepository.movieGenreRequest(query: query)
    }
    
    func createUser(genres: Set<MovieGenre>) {
        databaseRepository.createUser()
        databaseRepository.appendLikeGenres(genres: genres)
    }
}
