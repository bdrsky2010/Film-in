//
//  TMDBRepository.swift
//  Film-in
//
//  Created by Minjae Kim on 9/21/24.
//

import Foundation
/*
 {
   "200": "Success",
   "400": "BadRequest",
   "401": "Unauthorized",
   "403": "Forbidden",
   "404": "NotFound",
   "405": "MethodNotAllowed",
   "406": "NotAcceptable",
   "422": "UnprocessableEntity",
   "429": "TooManyRequests",
   "500": "InternalServerError",
   "501": "NotImplemented",
   "502": "BadGateway",
   "503": "ServiceUnavailable",
   "504": "GatewayTimeout"
 }
 */


protocol TMDBRepository: AnyObject {
    func movieGenreRequest(query: MovieGenreQuery) async -> Result<[MovieGenre], TMDBError>
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
}
