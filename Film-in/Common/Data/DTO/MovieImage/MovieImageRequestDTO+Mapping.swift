//
//  MovieImageRequestDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/23/24.
//

import Foundation

struct MovieImageRequestDTO: Encodable {
    let imageLanguage: String
    
    enum CodingKeys: String, CodingKey {
        case imageLanguage = "include_image_language"
    }
}

extension MovieImageRequestDTO {
    var asParameters: [String: Any] {
        return JSONEncoder.toDictionary(self)
    }
}
