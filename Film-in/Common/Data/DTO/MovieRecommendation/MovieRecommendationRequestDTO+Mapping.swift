//
//  MovieRecommendationRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/23/24.
//

import Foundation

struct MovieRecommendationRequestDTO: Encodable {
    let language: String
    let page: Int
}

extension MovieRecommendationRequestDTO {
    var asParameters: [String: Any] {
        return JSONEncoder.toDictionary(self)
    }
}
