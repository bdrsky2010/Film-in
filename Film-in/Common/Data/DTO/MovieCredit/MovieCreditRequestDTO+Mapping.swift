//
//  MovieCreditRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/23/24.
//

import Foundation

struct MovieCreditRequestDTO: Encodable {
    let language: String
}

extension MovieCreditRequestDTO {
    var asParameters: [String: Any] {
        return JSONEncoder.toDictionary(self)
    }
}
