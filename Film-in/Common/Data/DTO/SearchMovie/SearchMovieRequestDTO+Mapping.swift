//
//  SearchMovieRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/23/24.
//

import Foundation

struct SearchMovieRequestDTO: Encodable {
    let query: String
    let language: String
    let page: Int
    let region: String
}

extension SearchMovieRequestDTO {
    var asParameters: [String: Any] {
        return JSONEncoder.toDictionary(self)
    }
}
