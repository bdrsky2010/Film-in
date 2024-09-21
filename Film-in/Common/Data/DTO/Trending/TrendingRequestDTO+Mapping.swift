//
//  TrendingRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/21/24.
//

import Foundation

struct TrendingRequestDTO: Encodable {
    let language: String
}

extension TrendingRequestDTO {
    var asParameters: [String: Any] {
        return JSONEncoder.toDictionary(self)
    }
}
