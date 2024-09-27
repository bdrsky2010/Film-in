//
//  MovieInfoService.swift
//  Film-in
//
//  Created by Minjae Kim on 9/27/24.
//

import Foundation

protocol MovieInfoService: AnyObject {
    func fetchMovieDetail(query: MovieDetailQuery) async -> Result<MovieInfo, TMDBError>
    func fetchMovieCredit(query: MovieCreditQuery) async -> Result<[CreditInfo], TMDBError>
    func fetchMovieSimilar(query: MovieSimilarQuery) async -> Result<MovieSimilar, TMDBError>
    func fetchMovieImages(query: MovieImagesQuery) async -> Result<MovieImages, TMDBError>
    func fetchMovieVideos(query: MovieVideosQuery) async -> Result<[MovieVideo], TMDBError>
}

final class DefaultMovieInfoService: MovieInfoService {
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
}

extension DefaultMovieInfoService {
    func fetchMovieDetail(query: MovieDetailQuery) async -> Result<MovieInfo, TMDBError> {
        return await tmdbRepository.detailRequest(query: query)
    }
    
    func fetchMovieCredit(query: MovieCreditQuery) async -> Result<[CreditInfo], TMDBError> {
        return await tmdbRepository.creditRequest(query: query)
    }
    
    func fetchMovieSimilar(query: MovieSimilarQuery) async -> Result<MovieSimilar, TMDBError> {
        return await tmdbRepository.similarRequest(query: query)
    }
    
    func fetchMovieImages(query: MovieImagesQuery) async -> Result<MovieImages, TMDBError> {
        return await tmdbRepository.imagesRequest(query: query)
    }
    
    func fetchMovieVideos(query: MovieVideosQuery) async -> Result<[MovieVideo], TMDBError> {
        return await tmdbRepository.videosRequest(query: query)
    }
}
