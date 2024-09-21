//
//  NowPlayingRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/21/24.
//

import Foundation

struct NowPlayingRequestDTO: Encodable {
    let language: String
    let page: Int
    let region: String
}

extension NowPlayingRequestDTO {
    var asParameters: [String: Any] {
        return JSONEncoder.toDictionary(self)
    }
}
