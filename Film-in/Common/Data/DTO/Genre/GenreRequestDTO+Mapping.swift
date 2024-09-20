//
//  GenreRequestDTO.swift
//  Film-in
//
//  Created by Minjae Kim on 9/20/24.
//

import Foundation

struct GenreRequestDTO: Encodable {
    let language: String
}

extension GenreRequestDTO {
    var asParameters: [String: Any] {
        return JSONEncoder.toDictionary(self)
    }
}
