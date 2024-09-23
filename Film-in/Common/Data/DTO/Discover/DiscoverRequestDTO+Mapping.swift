//
//  DiscoverRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/22/24.
//

import Foundation

struct DiscoverRequestDTO: Encodable {
    let language: String
    let page: Int
    let releaseDateGte: String = "2000-01-01"
    let region: String
    let sortBy: String = "popularity.desc"
    let voteAvgGte: Double = 5
    let withGenres: String
    
    enum CodingKeys: String, CodingKey {
        case language
        case page
        case releaseDateGte = "primary_release_date.gte"
        case region
        case sortBy = "sort_by"
        case voteAvgGte = "vote_average.gte"
        case withGenres = "with_genres"
    }
}

extension DiscoverRequestDTO {
    var asParameters: [String: Any] {
        return JSONEncoder.toDictionary(self)
    }
}
