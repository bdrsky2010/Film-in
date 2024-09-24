//
//  PeopleDetailRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/24/24.
//

import Foundation

struct PeopleDetailRequestDTO: Encodable {
    let language: String
}

extension PeopleDetailRequestDTO {
    var asParameters: [String: Any] {
        return JSONEncoder.toDictionary(self)
    }
}
