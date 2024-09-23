//
//  SearchPersonRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/23/24.
//

import Foundation

struct SearchPersonRequestDTO: Encodable {
    let query: String
    let language: String
    let page: Int
}

extension SearchPersonRequestDTO {
    var asParameters: [String: Any] {
        return JSONEncoder.toDictionary(self)
    }
}
