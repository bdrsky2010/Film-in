//
//  GenreResponseDTO+Mapping.swift
//  Film-in
//
//  Created by Minjae Kim on 9/20/24.
//

import Foundation

struct GenreResponseDTO: Decodable {
    struct Genre: Decodable {
        let id: Int
        let name: String
    }
    
    let genres: [Genre]
}

extension GenreResponseDTO {
    var toEntity: [MovieGenre] {
        return self.genres
            .map {
                MovieGenre(id: $0.id, name: $0.name)
            }
    }
}
