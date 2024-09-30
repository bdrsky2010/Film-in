//
//  PeopleMovieRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/30/24.
//

import Foundation

struct PeopleMovieRequestDTO: Encodable {
    let language: String
}

extension PeopleMovieRequestDTO {
    var asParameters: [String: Any] {
        return JSONEncoder.toDictionary(self)
    }
}
