//
//  SearchResultService.swift
//  Film-in
//
//  Created by Minjae Kim on 12/4/24.
//

import Foundation
import Combine

protocol SearchResultService: AnyObject {
    func fetchMultiSearch(query: SearchQuery) -> AnyPublisher<Result<[RelatedKeyword], TMDBError>, Never>
    func getRandomMCUMovie() -> String
}

final class DefaultSearchResultService: BaseObject {
    private let tmdbRepository: TMDBRepository
    
    init(tmdbRepository: TMDBRepository) {
        self.tmdbRepository = tmdbRepository
    }
}

extension DefaultSearchResultService: SearchResultService {
    func fetchMultiSearch(query: SearchQuery) -> AnyPublisher<Result<[RelatedKeyword], TMDBError>, Never> {
        return Future { promise in
            Task { [weak self] in
                guard let self else { return }
                let result = await tmdbRepository.searchMultiRequest(query: query)
                switch result {
                case .success(let success):
                    promise(.success(.success(success)))
                case .failure(let failure):
                    promise(.success(.failure(failure)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getRandomMCUMovie() -> String {
        let mcuMovies: [String] = [
            "Iron Man",
            "The Incredible Hulk",
            "Iron Man 2",
            "Thor",
            "Captain America: The First Avenger",
            "The Avengers",
            "Iron Man 3",
            "Thor: The Dark World",
            "Captain America: The Winter Soldier",
            "Guardians of the Galaxy",
            "Avengers: Age of Ultron",
            "Ant-Man",
            "Captain America: Civil War",
            "Doctor Strange",
            "Guardians of the Galaxy Vol. 2",
            "Spider-Man: Homecoming",
            "Thor: Ragnarok",
            "Black Panther",
            "Avengers: Infinity War",
            "Ant-Man and the Wasp",
            "Captain Marvel",
            "Avengers: Endgame",
            "Spider-Man: Far From Home",
            "Black Widow",
            "Shang-Chi and the Legend of the Ten Rings",
            "Eternals",
            "Spider-Man: No Way Home",
            "Doctor Strange in the Multiverse of Madness",
            "Thor: Love and Thunder",
            "Black Panther: Wakanda Forever",
            "Ant-Man and the Wasp: Quantumania",
            "Guardians of the Galaxy Vol. 3",
            "The Marvels"
        ]
        
        return mcuMovies.randomElement() ?? "Spider Man"
    }
}
