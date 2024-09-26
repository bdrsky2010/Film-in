//
//  TMDBRepository.swift
//  Film-in
//
//  Created by Minjae Kim on 9/21/24.
//

import Foundation

protocol TMDBRepository: AnyObject {
    func movieGenreRequest(query: MovieGenreQuery) async -> Result<[MovieGenre], TMDBError>
    func trendingRequest(query: TrendingQuery) async -> Result<HomeMovie, TMDBError>
    func nowPlayingRequest(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError>
    func upcomingRequest(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError>
    func discoverRequest(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError>
}

final class DefaultTMDBRepository: TMDBRepository {
    static let shared = DefaultTMDBRepository()
    
    private let networkManager: NetworkManager
    
    private init(networkManager: NetworkManager = DefaultNetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func movieGenreRequest(query: MovieGenreQuery) async -> Result<[MovieGenre], TMDBError> {
        let requestDTO = GenreRequestDTO(language: query.language)
        let result = await networkManager.request(.genres(requestDTO), of: GenreResponseDTO.self)
        switch result {
        case .success(let success):
            return .success(success.toEntity)
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func trendingRequest(query: TrendingQuery) async -> Result<HomeMovie, TMDBError> {
        let requestDTO = TrendingRequestDTO(language: query.language)
        let result = await networkManager.request(.trending(requestDTO), of: TrendingResponseDTO.self)
        switch result {
        case .success(let success):
            return .success(success.toEntity)
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func nowPlayingRequest(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError> {
        let requestDTO = NowPlayingRequestDTO(
            language: query.language,
            page: query.page,
            region: query.region
        )
        let result = await networkManager.request(
            .nowPlaying(requestDTO),
            of: NowPlayingResponseDTO.self
        )
        switch result {
        case .success(let success):
            return .success(success.toEntity)
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func upcomingRequest(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError> {
        let requestDTO = UpcomingRequestDTO(
            language: query.language,
            page: query.page,
            region: query.region
        )
        let result = await networkManager.request(
            .upcoming(requestDTO),
            of: UpcomingResponseDTO.self
        )
        switch result {
        case .success(let success):
            return .success(success.toEntity)
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func discoverRequest(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError> {
        let requestDTO = DiscoverRequestDTO(
            language: query.language,
            page: query.page,
            region: query.region,
            withGenres: query.withGenres ?? ""
        )
        let result = await networkManager.request(
            .discover(requestDTO),
            of: DiscoverResponseDTO.self
        )
        switch result {
        case .success(let success):
            return .success(success.toEntity)
        case .failure(let failure):
            return .failure(failure)
        }
    }
}
