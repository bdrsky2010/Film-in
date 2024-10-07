//
//  HomeService.swift
//  Film-in
//
//  Created by Minjae Kim on 9/26/24.
//

import Foundation

protocol HomeService: AnyObject {
    func fetchTrending(query: TrendingQuery) async -> Result<HomeMovie, TMDBError>
    func fetchNowPlaying(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError>
    func fetchUpcoming(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError>
    func fetchDiscover(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError>
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
    
    func fetchTrending(query: TrendingQuery) async -> Result<HomeMovie, TMDBError> {
        return await tmdbRepository.trendingRequest(query: query)
    }
    
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
}
