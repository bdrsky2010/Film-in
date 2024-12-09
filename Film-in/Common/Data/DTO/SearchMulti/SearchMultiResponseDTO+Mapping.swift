//
//  SearchMultiResponseDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 12/9/24.
//

import Foundation

struct SearchMultiResponseDTO: Decodable {
    let page: Int
    let results: [TMDBMultiResponseDTO]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

extension SearchMultiResponseDTO {
    func toEntity() -> Set<RelatedKeyword> {
        return Set(
            results.compactMap {
                guard $0.mediaType == "movie" || $0.mediaType == "person" else { return nil }
                let isMovie = $0.mediaType == "movie"
                return RelatedKeyword(
                    type: isMovie ? .movie : .person,
                    keyword: isMovie ? $0.title : $0.name
                )
            }
        )
    }
}
