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
    func trendingMovieRequest(query: TrendingQuery) async -> Result<[MovieData], TMDBError>
    func nowPlayingRequest(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError>
    func upcomingRequest(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError>
    func discoverRequest(query: HomeMovieQuery) async -> Result<HomeMovie, TMDBError>
    func searchMultiRequest(query: SearchQuery) async -> Result<[RelatedKeyword], TMDBError>
    func searchMovieRequest(query: SearchMovieQuery) async -> Result<HomeMovie, TMDBError>
    func searchPersonRequest(query: SearchPersonQuery) async -> Result<PagingPeople, TMDBError>
    func detailRequest(query: MovieDetailQuery) async -> Result<MovieInfo, TMDBError>
    func creditRequest(query: MovieCreditQuery) async -> Result<[CreditInfo], TMDBError>
    func similarRequest(query: MovieSimilarQuery) async -> Result<MovieSimilar, TMDBError>
    func similarRequest(query: MovieSimilarQuery) async -> Result<HomeMovie, TMDBError>
    func imagesRequest(query: MovieImagesQuery) async -> Result<MovieImages, TMDBError>
    func videosRequest(query: MovieVideosQuery) async -> Result<[MovieVideo], TMDBError>
    func popularPeopleRequest(query: PopularQuery) async -> Result<[PopularPerson], TMDBError>
    func personDetailRequest(query: PersonQuery) async -> Result<PersonDetail, TMDBError>
    func personMovieRequest(query: PersonQuery) async -> Result<PersonMovie, TMDBError>
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
    
    func trendingMovieRequest(query: TrendingQuery) async -> Result<[MovieData], TMDBError> {
        let requestDTO = TrendingRequestDTO(language: query.language)
        let result = await networkManager.request(.trendingMovie(requestDTO), of: TrendingMovieResponseDTO.self)
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
    
    func searchMultiRequest(query: SearchQuery) async -> Result<[RelatedKeyword], TMDBError> {
        let requestDTO = SearchMultiRequestDTO(
            query: query.query,
            language: "longLanguageCode".localized
        )
        let result = await networkManager.request(.searchMulti(requestDTO), of: SearchMultiResponseDTO.self)
        switch result {
        case .success(let success):
            return .success(success.toEntity())
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func searchMovieRequest(query: SearchMovieQuery) async -> Result<HomeMovie, TMDBError> {
        let requestDTO = SearchMovieRequestDTO(
            query: query.query,
            language: "longLanguageCode".localized,
            page: query.page,
            region: "regionCode".localized
        )
        let result = await networkManager.request(.searchMovie(requestDTO), of: SearchMovieResponseDTO.self)
        switch result {
        case .success(let success):
            return .success(success.toEntity())
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func searchPersonRequest(query: SearchPersonQuery) async -> Result<PagingPeople, TMDBError> {
        let requestDTO = SearchPersonRequestDTO(
            query: query.query,
            language: "longLanguageCode".localized,
            page: query.page
        )
        let result = await networkManager.request(.searchPerson(requestDTO), of: SearchPersonResposeDTO.self)
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
    
    func popularPeopleRequest(query: PopularQuery) async -> Result<[PopularPerson], TMDBError> {
        let requestDTO = PopularPeopleRequestDTO(language: query.language)
        let result = await networkManager.request(.popularPeople(requestDTO), of: PopularPeopleResponseDTO.self)
        switch result {
        case .success(let success):
            return .success(success.toEntity())
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func personDetailRequest(query: PersonQuery) async -> Result<PersonDetail, TMDBError> {
        let requestDTO = PeopleDetailRequestDTO(language: query.language)
        let result = await networkManager.request(
            .peopleDetail(requestDTO, personId: query.personId),
            of: PeopleDetailResponseDTO.self
        )
        switch result {
        case .success(let success):
            return .success(success.toEntity())
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func personMovieRequest(query: PersonQuery) async -> Result<PersonMovie, TMDBError> {
        let requestDTO = PeopleMovieRequestDTO(language: query.language)
        let result = await networkManager.request(
            .peopleMovie(requestDTO, personId: query.personId),
            of: PeopleMovieResponseDTO.self
        )
        switch result {
        case .success(let success):
            return .success(success.toEntity())
        case .failure(let failure):
            return .failure(failure)
        }
    }
}
