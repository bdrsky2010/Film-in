//
//  PersonDetailService.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import Foundation

protocol PersonDetailService {
    func fetchPersonDetail(query: PersonQuery) async -> Result<PersonDetail, TMDBError>
    func fetchPersonMovie(query: PersonQuery) async -> Result<PersonMovie, TMDBError>
}

final class DefaultPersonDetailService: PersonDetailService {
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

extension DefaultPersonDetailService {
    func fetchPersonDetail(query: PersonQuery) async -> Result<PersonDetail, TMDBError> {
        return await tmdbRepository.personDetailRequest(query: query)
    }
    
    func fetchPersonMovie(query: PersonQuery) async -> Result<PersonMovie, TMDBError> {
        return await tmdbRepository.personMovieRequest(query: query)
    }
}
