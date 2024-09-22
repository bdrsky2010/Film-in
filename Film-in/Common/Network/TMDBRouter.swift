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
}

enum TMDBRouter {
    case genres(_ dto: GenreRequestDTO)
    case trending(_ dto: TrendingRequestDTO)
    case nowPlaying(_ dto: NowPlayingRequestDTO)
    case upcoming(_ dto: UpcomingRequestDTO)
}

extension TMDBRouter: TMDBTargetType {
    var path: String {
        switch self {
        case .genres: return "genre/movie/list"
        case .trending: return "trending/movie/day"
        case .nowPlaying: return "movie/now_playing"
        case .upcoming: return "movie/upcoming"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .genres: return .get
        case .trending: return .get
        case .nowPlaying: return .get
        case .upcoming: return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .genres(let dto):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .trending(let dto):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .nowPlaying(let dto):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        case .upcoming(let dto):
            return .requestParameters(parameters: dto.asParameters, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .genres:
            return [
                TMDBHeader.authorization.rawValue: APIKEY.tmdb,
                TMDBHeader.accept.rawValue: TMDBHeader.json.rawValue
            ]
        case .trending:
            return [
                TMDBHeader.authorization.rawValue: APIKEY.tmdb,
                TMDBHeader.accept.rawValue: TMDBHeader.json.rawValue
            ]
        case .nowPlaying:
            return [
                TMDBHeader.authorization.rawValue: APIKEY.tmdb,
                TMDBHeader.accept.rawValue: TMDBHeader.json.rawValue
            ]
        case .upcoming:
            return [
                TMDBHeader.authorization.rawValue: APIKEY.tmdb,
                TMDBHeader.accept.rawValue: TMDBHeader.json.rawValue
            ]
        }
    }
}
