//
//  MovieSimiliarRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/23/24.
//

import Foundation

struct MovieSimiliarRequestDTO: Encodable {
    let language: String
    let page: Int
}

extension MovieSimiliarRequestDTO {
    var asParameters: [String: Any] {
        return JSONEncoder.toDictionary(self)
    }
}
