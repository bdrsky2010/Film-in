//
//  TMDBRouter.swift
//  Film-in
//
//  Created by Minjae Kim on 9/20/24.
//

import Foundation
import Moya

protocol TMDBTargetType: TargetType { }

extension TMDBTargetType {
    var baseURL: URL { try! BaseURL.tmdb.asURL() }
    var method: Moya.Method { .get }
    var headers: [String : String]? {
        return [
            TMDBHeader.authorization.rawValue: APIKEY.tmdb,
            TMDBHeader.accept.rawValue: TMDBHeader.json.rawValue
        ]
    }
}

enum TMDBRouter {
    case genres(_ dto: GenreRequestDTO)
    case trendingMovie(_ dto: TrendingRequestDTO)
    case nowPlaying(_ dto: NowPlayingRequestDTO)
    case upcoming(_ dto: UpcomingRequestDTO)
    case discover(_ dto: DiscoverRequestDTO)
    case searchMulti(_ dto: SearchMultiRequestDTO)
    case searchMovie(_ dto: SearchMovieRequestDTO)
    case searchPerson(_ dto: SearchPersonRequestDTO)
    case movieDetail(_ dto: MovieDetailRequestDTO, movieId: Int)
    case movieCredit(_ dto: MovieCreditRequestDTO, movieId: Int)
    case movieSimilar(_ dto: MovieSimilarRequestDTO, movieId: Int)
    case movieRecommendation(_ dto: MovieRecommendationRequestDTO, movieId: Int)
    case movieImage(_ dto: MovieImageRequestDTO, movieId: Int)
    case movieVideo(_ dto: MovieVideoRequestDTO, movieId: Int)
    case popularPeople(_ dto: PopularPeopleRequestDTO)
    case peopleDetail(_ dto: PeopleDetailRequestDTO, personId: Int)
    case peopleMovie(_ dto: PeopleMovieRequestDTO, personId: Int)
}

extension TMDBRouter: TMDBTargetType {
    var path: String {
        switch self {
        case .genres: return "genre/movie/list"
        case .trendingMovie: return "trending/movie/day"
        case .nowPlaying: return "movie/now_playing"
        case .upcoming: return "movie/upcoming"
        case .discover: return "discover/movie"
        case .searchMulti: return "search/multi"
        case .searchMovie: return "search/movie"
        case .searchPerson: return "search/person"
        case .movieDetail(_, let movieId): return "movie/\(movieId)"
        case .movieCredit(_, let movieId): return "movie/\(movieId)/credits"
        case .movieSimilar(_, let movieId): return "movie/\(movieId)/similar"
        case .movieRecommendation(_, let movieId): return "movie/\(movieId)/recommendations"
        case .movieImage(_, let movieId): return "movie/\(movieId)/images"
        case .movieVideo(_, let movieId): return "movie/\(movieId)/videos"
        case .popularPeople: return "person/popular"
        case .peopleDetail(_, let personId): return "person/\(personId)"
        case .peopleMovie(_, let personId): return "person/\(personId)/movie_credits"
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .genres(let dto):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .trendingMovie(let dto):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .nowPlaying(let dto):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .upcoming(let dto):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .discover(let dto):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .searchMulti(let dto):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .searchMovie(let dto):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .searchPerson(let dto):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .movieDetail(let dto, _):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .movieCredit(let dto, _):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .movieSimilar(let dto, _):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .movieRecommendation(let dto, _):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .movieImage(let dto, _):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .movieVideo(let dto, _):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .popularPeople(let dto):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .peopleDetail(let dto, _):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .peopleMovie(let dto, _):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        }
    }
}
