//
//  PersonDetailService.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import Foundation
import Combine

protocol PersonDetailService {
    func fetchPersonDetail(query: PersonQuery) -> Future<Result<PersonDetail, TMDBError>, Never>
    func fetchPersonMovie(query: PersonQuery) -> Future<Result<PersonMovie, TMDBError>, Never>
}

final class DefaultPersonDetailService: BaseObject, PersonDetailService {
    private let tmdbRepository: TMDBRepository
    private let databaseRepository: DatabaseRepository
    
    init(
        tmdbRepository: TMDBRepository,
        databaseRepository: DatabaseRepository
    ) {
        self.tmdbRepository = tmdbRepository
        self.databaseRepository = databaseRepository
    }
}

extension DefaultPersonDetailService {
    func fetchPersonDetail(query: PersonQuery) -> Future<Result<PersonDetail, TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result = await tmdbRepository.personDetailRequest(query: query)
                switch result {
                case .success(let success):
                    promise(.success(.success(success)))
                case .failure(let failure):
                    promise(.success(.failure(failure)))
                }
            }
        }
    }
    
    func fetchPersonMovie(query: PersonQuery) -> Future<Result<PersonMovie, TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result = await tmdbRepository.personMovieRequest(query: query)
                switch result {
                case .success(let success):
                    promise(.success(.success(success)))
                case .failure(let failure):
                    promise(.success(.failure(failure)))
                }
            }
        }
    }
}
