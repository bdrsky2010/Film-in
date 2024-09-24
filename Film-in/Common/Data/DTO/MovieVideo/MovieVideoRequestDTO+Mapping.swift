//
//  MovieVideoRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/24/24.
//

import Foundation

struct MovieVideoRequestDTO: Encodable {
    let language: String
}

extension MovieVideoRequestDTO {
    var asParameters: [String: Any] {
        return JSONEncoder.toDictionary(self)
    }
}
