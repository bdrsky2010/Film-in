//
//  TMDBRepository.swift
//  Film-in
//
//  Created by Minjae Kim on 9/21/24.
//

import Foundation

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
