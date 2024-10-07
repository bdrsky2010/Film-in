//
//  MovieListService.swift
//  Film-in
//
//  Created by Minjae Kim on 9/29/24.
//

import Foundation

protocol MovieListService: AnyObject {
    func fetchNowPlaying(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError>
    func fetchUpcoming(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError>
    func fetchDiscover(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError>
    func fetchMovieSimilar(query: MovieSimilarQuery) async -> Result<HomeMovie, TMDBError>
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
    func fetchNowPlaying(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError> {
        return await tmdbRepository.nowPlayingRequest(query: query)
    }
    
    func fetchUpcoming(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError> {
        return await tmdbRepository.upcomingRequest(query: query)
    }
    
    @MainActor
    func fetchDiscover(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError> {
        let query = HomeMovieQuery(
            language: query.language,
            page: query.page,
            region: query.region,
            withGenres: databaseRepository.user?.selectedGenreIds.map { String($0) }.joined(separator: "|"))
        return await tmdbRepository.discoverRequest(query: query)
    }
    
    func fetchMovieSimilar(query: MovieSimilarQuery) async -> Result<HomeMovie, TMDBError> {
        return await tmdbRepository.similarRequest(query: query)
    }
}
