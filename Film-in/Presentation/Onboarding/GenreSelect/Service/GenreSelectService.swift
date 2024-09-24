//
//  GenreSelectService.swift
//  Film-in
//
//  Created by Minjae Kim on 9/25/24.
//

import Foundation

protocol GenreSelectService: AnyObject {
    func fetchGenres(query: MovieGenreQuery) async -> Result<[MovieGenre], TMDBError>
}

final class DefaultGenreSelectService: GenreSelectService {
    private let tmdbRepository: TMDBRepository
    
    init(tmdbRepository: TMDBRepository) {
        self.tmdbRepository = tmdbRepository
    }
    
    func fetchGenres(query: MovieGenreQuery) async -> Result<[MovieGenre], TMDBError> {
        return await tmdbRepository.movieGenreRequest(query: query)
    }
}
