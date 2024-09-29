//
//  TMDBRepository.swift
//  Film-in
//
//  Created by Minjae Kim on 9/21/24.
//

import Foundation
// Details, Credits, Similiar, Images, Videos
protocol TMDBRepository: AnyObject {
    func movieGenreRequest(query: MovieGenreQuery) async -> Result<[MovieGenre], TMDBError>
    func trendingRequest(query: TrendingQuery) async -> Result<HomeMovie, TMDBError>
    func nowPlayingRequest(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError>
    func upcomingRequest(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError>
    func discoverRequest(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError>
    func detailRequest(query: MovieDetailQuery) async -> Result<MovieInfo, TMDBError>
    func creditRequest(query: MovieCreditQuery) async -> Result<[CreditInfo], TMDBError>
    func similarRequest(query: MovieSimilarQuery) async -> Result<MovieSimilar, TMDBError>
    func similarRequest(query: MovieSimilarQuery) async -> Result<HomeMovie, TMDBError>
    func imagesRequest(query: MovieImagesQuery) async -> Result<MovieImages, TMDBError>
    func videosRequest(query: MovieVideosQuery) async -> Result<[MovieVideo], TMDBError>
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
            return .success(success.toEntity())
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func trendingRequest(query: TrendingQuery) async -> Result<HomeMovie, TMDBError> {
        let requestDTO = TrendingRequestDTO(language: query.language)
        let result = await networkManager.request(.trending(requestDTO), of: TrendingResponseDTO.self)
        switch result {
        case .success(let success):
            return .success(success.toEntity())
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
            return .success(success.toEntity())
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
            return .success(success.toEntity())
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
            return .success(success.toEntity())
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func detailRequest(query: MovieDetailQuery) async -> Result<MovieInfo, TMDBError> {
        let requestDTO = MovieDetailRequestDTO(language: query.language)
        let result = await networkManager.request(
            .movieDetail(requestDTO, movieId: query.movieId),
            of: MovieDetailResponseDTO.self
        )
        switch result {
        case .success(let success):
            return .success(success.toEntity())
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func creditRequest(query: MovieCreditQuery) async -> Result<[CreditInfo], TMDBError> {
        let requestDTO = MovieCreditRequestDTO(language: query.language)
        let result = await networkManager.request(
            .movieCredit(requestDTO, movieId: query.movieId),
            of: MovieCreditResponseDTO.self
        )
        switch result {
        case .success(let success):
            return .success(success.toEntity())
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func similarRequest(query: MovieSimilarQuery) async -> Result<MovieSimilar, TMDBError> {
        let requestDTO = MovieSimilarRequestDTO(language: query.language, page: query.page)
        let result = await networkManager.request(
            .movieSimiliar(requestDTO, movieId: query.movieId),
            of: MovieSimilarResponseDTO.self
        )
        switch result {
        case .success(let success):
            return .success(success.toEntity())
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func similarRequest(query: MovieSimilarQuery) async -> Result<HomeMovie, TMDBError> {
        let requestDTO = MovieSimilarRequestDTO(language: query.language, page: query.page)
        let result = await networkManager.request(
            .movieSimiliar(requestDTO, movieId: query.movieId),
            of: MovieSimilarResponseDTO.self
        )
        switch result {
        case .success(let success):
            return .success(success.toEntity())
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func imagesRequest(query: MovieImagesQuery) async -> Result<MovieImages, TMDBError> {
        let requestDTO = MovieImageRequestDTO(imageLanguage: query.imageLanguage)
        let result = await networkManager.request(
            .movieImage(requestDTO, movieId: query.movieId),
            of: MovieImageResponseDTO.self
        )
        switch result {
        case .success(let success):
            return .success(success.toEntity())
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func videosRequest(query: MovieVideosQuery) async -> Result<[MovieVideo], TMDBError> {
        let requestDTO = MovieVideoRequestDTO(language: query.language)
        let result = await networkManager.request(
            .movieVideo(requestDTO, movieId: query.movieId),
            of: MovieVideoResponseDTO.self
        )
        switch result {
        case .success(let success):
            return .success(success.toEntity())
        case .failure(let failure):
            return .failure(failure)
        }
    }
}
