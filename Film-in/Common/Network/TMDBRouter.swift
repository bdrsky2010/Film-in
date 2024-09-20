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
}

extension TMDBRouter: TMDBTargetType {
    var path: String {
        switch self {
        case .genres: return "genre/movie/list"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .genres: return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .genres(let dto):
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
        }
    }
}
