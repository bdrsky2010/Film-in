//
//  MovieSimilarRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/23/24.
//

import Foundation

struct MovieSimilarRequestDTO: Encodable {
    let language: String
    let page: Int
}

extension MovieSimilarRequestDTO {
    var asParameters: [String: Any] {
        return JSONEncoder.toDictionary(self)
    }
}
